'*************************************************************
'** GenerateSearchSuggestions()
'*************************************************************
Function GenerateSearchSuggestions(partSearchText As String) As Object
    url = GetScriptURL()
    url = url + "?action=search&q=" 
    url = url + HttpEncode(partSearchText)

    http = NewHttp(url)

    rsp = http.GetToStringWithRetry()

    xml = CreateObject("roXMLElement")

    xml.Parse(rsp)

    records = xml.GetChildElements()

    results = CreateObject("roArray", 0, true)

    suggestions = CreateObject("roArray", 1, true)
    for each rec in records
        suggestions.Push(rec@title)
    next
    return suggestions
End Function

'*************************************************************
'** showSearchScreen()
'*************************************************************
Function showSearchScreen() As String
   screen = CreateObject("roSearchScreen")
   history = CreateObject("roSearchHistory")
   inHistoryMode = true
   port    = CreateObject("roMessagePort")

   screen.SetMessagePort(port)

   screen.SetBreadcrumbText("Search", "With History")
   screen.SetSearchTermHeaderText("Recent Searches")
   screen.SetSearchButtonText("Search")
   screen.SetClearButtonText("Clear history")
   screen.SetClearButtonEnabled(true) 'enable for search history
   screen.SetSearchTerms(history.GetAsArray())
   screen.SetEmptySearchTermsText("No searches available")

   screen.Show()
   while true
        waitformsg:
        msg = wait(0, screen.GetMessagePort())
        print "message received"

        if type(msg) <> "roSearchScreenEvent" then
            print "Unexpected message class: "; type(msg)
            goto waitformsg
        endif

        if msg.isScreenClosed() return ""

        if msg.isPartialResult()
            partialResult = msg.GetMessage()
            print "partial result "; partialResult
            if not isnullorempty(partialResult)
                searchSuggestions = GenerateSearchSuggestions(partialResult)
                printList(searchSuggestions)
                if searchSuggestions <> invalid
                    'do SetSearchTerms() before SetEmptySearchTermsText() so that the new empty
                    'search terms text doesn't flash on screen
                    screen.SetSearchTerms(searchSuggestions)

                    if inHistoryMode
                        'do only on 1st mode switch
                        screen.SetSearchTermHeaderText("Search Suggestions")
                        screen.SetEmptySearchTermsText("No suggestions available")
                        screen.SetClearButtonEnabled(false) 'user cannot clear search suggestions
                        inHistoryMode = false
                    endif
                endif
            endif
        else if msg.isFullResult()
            fullSearchResult = msg.GetMessage()
            print "full result: "; fullSearchResult
            if not isnullorempty(fullSearchResult)
                history.Push(fullSearchResult)
            endif
            return fullSearchResult
        else if msg.isCleared()
            print "history cleared"
            history.Clear()
        endif
        
        
   end while
End Function
