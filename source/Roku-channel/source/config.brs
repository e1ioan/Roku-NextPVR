Function GetScriptURL() As String
	serverURL = RegRead("NPVR_URL")
	if (serverURL = invalid) then
	   checkServerUrl()
	else
	   return "http://"+ RegRead("NPVR_URL")
	endif
End Function
