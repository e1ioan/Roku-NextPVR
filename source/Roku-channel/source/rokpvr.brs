Sub Main()
    theme = CreateObject("roAssociativeArray")
    theme.OverhangOffsetSD_X = "72"
    theme.OverhangOffsetSD_Y = "31"
    theme.OverhangSliceSD = "pkg:/images/Overhang_Background_SD.jpg"
    theme.OverhangLogoSD  = "pkg:/images/Overhang_Logo_SD.png"
    theme.OverhangOffsetHD_X = "125"
    theme.OverhangOffsetHD_Y = "35"
    theme.OverhangSliceHD = "pkg:/images/Overhang_Background_HD.jpg"
    theme.OverhangLogoHD  = "pkg:/images/Overhang_Logo_HD.png"
    theme.BreadcrumbTextRight = "#000033"
	'theme.BackgroundColor="#006699"
    app = CreateObject("roAppManager")
    app.SetTheme(theme)
	serverURL = RegRead("NPVR_URL")
	if (serverURL = invalid) then
	   checkServerUrl() 
	endif
	ShowShows()
End Sub

Sub ShowShows()
    port = CreateObject("roMessagePort")
    screen = CreateObject("roPosterScreen")
    screen.SetListStyle("flat-category")
    screen.SetMessagePort(port)
    records = LoadShows()
    screen.SetContentList(records)
	if records.Count() > 2 then
	  screen.SetFocusedListItem(2)
	else
	  screen.SetFocusedListItem(1)
    endif 
	screen.SetBreadcrumbText("", "show list")
    screen.Show()
    while true
        msg = wait(0, port)
        if type(msg) = "roPosterScreenEvent" then
            if msg.isScreenClosed() then
                return
            else if msg.isListItemSelected() then
              idx = msg.GetIndex()
              if idx = 0 then
			    checkServerUrl()
              else 
                if idx = 1 then
	  		      srch = showSearchScreen()
				  if srch <> "" then
                    showPrograms(srch)
				  endif
                else 
                  if ShowEpisodes(records[idx]["basename"]) = 1 then
  			        records.delete(idx)
                    screen.SetContentList(records)
	   			    screen.SetFocusedListItem(records.Count() - 1)
                    screen.Show()
				  endif
				endif
			  endif
            endif
        endif
    end while
End Sub

Function LoadShows() As Object
    http = NewHttp(GetScriptURL())
    rsp = http.GetToStringWithRetry()
    xml = CreateObject("roXMLElement")
    xml.Parse(rsp)
    records = xml.GetChildElements()
    results = CreateObject("roArray", 0, true)

    item = CreateObject("roAssociativeArray")
    item.Title = "Configure"
    item.ShortDescriptionLine1 = "Configuration"
	item.ShortDescriptionLine2 = "Configure your server IP"
    item.Type = "series"
    item.SDPosterURL = "pkg:/images/config-sd.png"
    item.HDPosterURL = "pkg:/images/config-hd.png"
    item.basename = "config"
    results.Push(item)
	
    item = CreateObject("roAssociativeArray")
    item.Title = "Search"
    item.ShortDescriptionLine1 = "Search and Record"
	item.ShortDescriptionLine2 = "Find and record your preffered shows"
    item.Type = "series"
    item.SDPosterURL = "pkg:/images/search-sd.png"
    item.HDPosterURL = "pkg:/images/search-hd.png"
    item.basename = "search"
    results.Push(item)

    for each rec in records
        item = CreateObject("roAssociativeArray")
        item.Title = rec@title
        item.ShortDescriptionLine1 = rec@title
        item.Type = "series"
        item.SDPosterURL = "pkg:/images/folder-sd.png"
        item.HDPosterURL = "pkg:/images/folder-hd.png"
        item.basename = rec@basename
        results.Push(item)
    next

    return results
End Function

function ShowEpisodes(basename As String) as integer
    port = CreateObject("roMessagePort")
    screen = CreateObject("roPosterScreen")
    screen.SetListStyle("flat-category")
    screen.SetMessagePort(port)
    records = LoadEpisodes(basename)
	screen.SetBreadcrumbText("", "episode list")
    screen.SetContentList(records)
    screen.Show()
    endcode = 0
    while true
        msg = wait(0, port)
        if type(msg) = "roPosterScreenEvent" then
            if msg.isScreenClosed() then
                return 0
            else if msg.isListItemSelected() then
              idx = msg.GetIndex()
              if ShowEpisodeDetail(records[idx]["basename"]) = 1 then
			    records.delete(idx)
				print "records ";records.Count()
				if records.Count() > 0 then
                  screen.SetContentList(records)
				  screen.SetFocusedListItem(records.Count() - 1)
                  screen.Show()
				else
				  endcode = 1
				  exit while
				endif
			  endif
            endif
        endif
    end while
    return endcode
End Function

Function LoadEpisodes(basename As String) As Object
    url = GetScriptURL()
    url = url + "?action=get_episode_list&basename="
    url = url + basename
    http = NewHttp(url)
    rsp = http.GetToStringWithRetry()
    xml = CreateObject("roXMLElement")
    xml.Parse(rsp)
    records = xml.GetChildElements()
    results = CreateObject("roArray", 0, true)

    for each rec in records
        item = CreateObject("roAssociativeArray")
        item.Title = rec@title
        item.ShortDescriptionLine1 = rec@airdate
        item.ShortDescriptionLine2 = rec@subtitle
        item.Type = "episode"
        item.SDPosterURL = rec@sd_img
        item.HDPosterURL = rec@hd_img
        item.basename = rec@basename
        results.Push(item)
    next
    return results
End Function

function ShowEpisodeDetail(basename As String) as Integer
    port = CreateObject("roMessagePort")
    screen = CreateObject("roSpringboardScreen")
    screen.SetMessagePort(port)
	screen.SetStaticRatingEnabled(False)
    record = GetEpisodeDetail(basename)
    screen.SetContent(record)
    screen.AddButton(1, "play from beginning")

    resume = RegRead(basename)
    start = 0

    if resume <> invalid then
        screen.AddButton(2, "resume")
        start = resume.ToInt()
    end if
	
    screen.SetContent(record)
    screen.AddButton(3, "delete episode")
    screen.Show()
	
	endcode = 0
    while true
        msg = wait(0, port)
        if type(msg) = "roSpringboardScreenEvent" then
            if msg.isScreenClosed() then
                exit while
            else if msg.isButtonPressed() then
			    button = msg.GetIndex()
				if button = 3 then
				    if DeleteEpisode(basename) = 1 then
					   endcode = 1
					   exit while
					endif
				else					
                    if button = 1 then
                       start = 0
                    endif
                    PlayEpisode(basename, start)
				endif
            endif
        endif
    end while
	return endcode
End function

Function GetEpisodeDetail(basename As String) As Object
    url = GetScriptURL()
    url = url + "?action=get_episode_details&basename="
    url = url + basename
    http = NewHttp(url)
    
	rsp = http.GetToStringWithRetry()
    xml = CreateObject("roXMLElement")
    xml.Parse(rsp)
    records = xml.GetChildElements()
	
    urls = CreateObject("roArray", 0, true)
    urls.Push(records[0]@stream_url)

    quals = CreateObject("roArray", 0, true)
    quals.Push(records[0]@quality)

    rates = CreateObject("roArray", 0, true)
    rates.Push(0)

    ids = CreateObject("roArray", 0, true)
    ids.Push(basename)

    item = CreateObject("roAssociativeArray")
    item.Title = records[0]@title
    item.ShortDescriptionLine1 = records[0]@subtitle
    item.ShortDescriptionLine2 = records[0]@description
    item.Description = records[0]@description
    item.ContentType = "episode"
    item.SDPosterURL = records[0]@sd_img
    item.HDPosterURL = records[0]@hd_img
    item.basename = basename
    item.StreamUrls = urls
    item.StreamQualities = quals
    item.StreamBitrates = rates
    item.StreamFormat = "mp4"
    item.SubtitleUrl = records[0]@srt_url
    item.HDBifUrl = records[0]@bif_hd_url
    item.SDBifUrl = records[0]@bif_sd_url	
    item.IsHD = true
    item.StreamContentIDs = ids
    return item
End Function

function DeleteEpisode(basename As String) as Integer
	if ShowDialog2Buttons("Delete", "Are you sure you want to delete?", "no", "yes") = 1 then
	  url = GetScriptURL()
	  url = url + "?action=delete_episode&basename="
	  url = url + basename
	  http = NewHttp(url)  
	  rsp = http.GetToStringWithRetry()
	  return 1
	else
	  return 0
	endif
End Function

Sub PlayEpisode(basename As String, start As Integer)
    port = CreateObject("roMessagePort")
    screen = CreateObject("roVideoScreen")
    screen.SetMessagePort(port)
    screen.SetPositionNotificationPeriod(30)
    record = GetEpisodeDetail(basename)
    record.PlayStart = start
    screen.SetContent(record)
    screen.Show()
    while true
        msg = wait(0, port)
        if type(msg) = "roVideoScreenEvent" then
            if msg.isScreenClosed() then
                exit while
            else if msg.isPlaybackPosition() then
                Dbg("write index to registry")
                RegWrite(basename, msg.GetIndex().toStr())
            endif
        endif
    end while
End Sub


Sub showPrograms(basename As String)
    waitDlg = ShowBusy("retrieving...")
    port = CreateObject("roMessagePort")
    screen = CreateObject("roPosterScreen")
    screen.SetListStyle("flat-category")
    screen.SetMessagePort(port)
    records = LoadPrograms(basename)
	screen.SetBreadcrumbText("", basename)
    screen.SetContentList(records)
    screen.Show()
	waitDlg.Close()
    while true
        msg = wait(0, port)
        if type(msg) = "roPosterScreenEvent" then
            if msg.isScreenClosed() then
                return
            else if msg.isListItemSelected() then
                records[msg.GetIndex()] = SetRecording(records[msg.GetIndex()])
				screen.SetContentList(records)
            endif
        endif
    end while
End Sub

Function LoadPrograms(basename As String) As Object
    url = GetScriptURL()
    url = url + "?action=searchname&q="
    url = url + HttpEncode(basename)
	http = NewHttp(url)
    rsp = http.GetToStringWithRetry()
	xml = CreateObject("roXMLElement")
	xml.Parse(rsp)
    records = xml.GetChildElements()
	results = CreateObject("roArray", 0, true)
    for each rec in records
        item = CreateObject("roAssociativeArray")
        item.Title = rec@title
        item.ShortDescriptionLine1 = rec@airdate
		item.ShortDescriptionLine2 = rec@subtitle
        item.Type = "series"
		item.Scheduled = rec@scheduled
		if item.Scheduled = "yes"
          item.SDPosterURL = "pkg:/images/record-sd.png"
          item.HDPosterURL = "pkg:/images/record-hd.png"
		else
          item.SDPosterURL = "pkg:/images/videos-sd.png"
          item.HDPosterURL = "pkg:/images/videos-hd.png"
		endif
        item.basename = rec@oid
        results.Push(item)
    next
    return results
End Function

function SetRecording(arec As Object) As Object
    if not arec.scheduled = "yes"
	  if ShowDialog2Buttons("Record", "Record this episode?", "yes", "no") = 0 then
	    print "scheduling: "; arec.basename
        url = GetScriptURL()
        url = url + "?action=schedule&oid="
        url = url + arec.basename
	    http = NewHttp(url)
        rsp = http.GetToStringWithRetry()
	    xml = CreateObject("roXMLElement")
	    xml.Parse(rsp)
        records = xml.GetChildElements()
	
	    if records[0]@Status = "OK" then
          arec.SDPosterURL = "pkg:/images/record-sd.png"
          arec.HDPosterURL = "pkg:/images/record-hd.png"
		else
		  ShowDialog1Button("Not scheduled!", "Unable to schedule recording... possible time conflict with another scheduled recording", "ok")
	    endif
		
	  endif
	endif
	return arec
End function