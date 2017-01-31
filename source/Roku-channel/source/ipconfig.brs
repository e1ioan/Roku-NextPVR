'************************************************************
' ** Check the registry for the server URL
' ** Prompt the user to enter the URL or IP if it is not
' ** found and write it to the registry.
'************************************************************
Function checkServerUrl() as Void
	serverURL = RegRead("NPVR_URL")
	if (serverURL = invalid) then
		print "ServerURL not found in the registry"
		serverURL = "192.168.1.xx:8000"
	endif
	
	screen = CreateObject("roKeyboardScreen")
	port = CreateObject("roMessagePort")
	screen.SetMessagePort(port)
	screen.SetTitle("Video Server URL")
	screen.SetText(serverURL)
	screen.SetDisplayText("Enter Host Name or IP Address and Port (192.168.1.55:8000)")
	screen.SetMaxLength(25)
	screen.AddButton(1, "finished")
	screen.Show()
	
	while true
		msg = wait(0, screen.GetMessagePort())
		print "message received"
		if type(msg) = "roKeyboardScreenEvent"
			if msg.isScreenClosed()
				return
			else if msg.isButtonPressed() then
				print "Evt: ";msg.GetMessage();" idx:"; msg.GetIndex()
				if msg.GetIndex() = 1
					searchText = screen.GetText()
					print "search text: "; searchText
					RegWrite("NPVR_URL", searchText)
					return
				endif
			endif
		endif
	end while
End Function