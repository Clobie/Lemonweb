#cs ----------------------------------------------------------------------------
 Script Function:	http server functions
 AutoIt Version: 	3.3.10.2
 Author:			Caleb Alexander
#ce ----------------------------------------------------------------------------
; Script Start - Add your code below here

#include-once
#include "../common/common.au3"
#include "../plugin/plugin.au3"
#include "header.au3"
#include <File.au3>

Global $__Http_ServerName = 			"LemonWeb (" & @OSVersion & ") AutoIt (" & @AutoItVersion & ")"
Global $__Http_VirtualHosts = 			ObjCreate("Scripting.Dictionary")
Global $__Http_ListenAddress = 			"0.0.0.0"
Global $__Http_ListenPort = 			80
Global $__Http_ListenSocket = 			-1
Global $__Http_MaxPendingConnections = 	64
Global $__Http_MaxConnections = 		64
Global $__Http_Connection[$__Http_MaxConnections+1][6]
Global $__Http_FileChunkSize = 			50
Global $__Http_MaxPacketReceiveSize = 	1000
Global $__Http_DefaultIndex = 			__Tokenizer_TokenizeString("index.htm, index.html, index.au3, index.php", ", ")
Global $__Http_DefaultDocumentRoot = 	@ScriptDir & "\www\default"
Global $__Http_Count_Connections = 		0
Global $__Http_AccessLogFile =			@ScriptDir & "\Logs\http-access.log"

; Notes
; $__Http_Connection[?][0] = SOCKET									DEFAULT: -1
; $__Http_Connection[?][1] = IN-BUFFER								DEFAULT: ""
; $__Http_Connection[?][2] = FILE SEND PROGRESS ( pos in bytes )	DEFAULT: -1
; $__Http_Connection[?][3] = FILE SIZE								DEFAULT: -1
; $__Http_Connection[?][4] = FILE HANDLE WHEN SENDING DATA			DEFAULT: -1
; $__Http_Connection[?][5] = NEEDS POST DATA						DEFAULT: -1
; $__Http_Connection[?][6] = BYTES OF POST DATA NEEDED				DEFAULT: -1

Func __Http_Start()
	__Common_Print("Initializing HTTP...")
	For $i = 0 To UBound($__Http_Connection)-1
		$__Http_Connection[$i][0] = -1
		$__Http_Connection[$i][1] = ""
		$__Http_Connection[$i][2] = -1
		$__Http_Connection[$i][3] = -1
		$__Http_Connection[$i][4] = -1
		$__Http_Connection[$i][5] = -1
	Next

	TCPStartup()
	$__Http_ListenSocket = TCPListen($__Http_ListenAddress, $__Http_ListenPort, $__Http_MaxPendingConnections)
	If @error Then
		__Common_Exception("Unable to listen on port: " & $__Http_ListenPort)
	EndIf
	__Common_Print("Listening on port: " & $__Http_ListenPort)
EndFunc

Func __Http_Stop()
	__Common_Print("Stopping HTTP...")
	If $__Http_ListenSocket Then TCPCloseSocket($__Http_ListenSocket)
	TCPShutdown()
EndFunc

Func __Http_SetPort($nPort)
	$__Http_ListenPort = $nPort
EndFunc

Func __Http_GetConnection()
	If $__Http_Count_Connections >= $__Http_MaxConnections Then Return
	Local $__Http_Accept = TCPAccept($__Http_ListenSocket)
	If $__Http_Accept == -1 Then Return
	$__Http_Connection[$__Http_Count_Connections][0] = $__Http_Accept
	$__Http_Count_Connections += 1
EndFunc

Func __Http_RemoveConnection($nSlot)
	TCPCloseSocket($__Http_Connection[$nSlot][0])
	For $h = 0 To UBound($__Http_Connection, 2)-1
		$__Http_Connection[$nSlot][$h] = -1
	Next
	$__Http_Connection[$nSlot][1] = ""
	Local $aTemp[UBound($__Http_Connection, 1)][UBound($__Http_Connection, 2)]
	Local $nCount = 0
	For $i = 0 To UBound($__Http_Connection)-1
		If $__Http_Connection[$i][0] == -1 Then ContinueLoop
		For $j = 0 To UBound($__Http_Connection, 2)-1
			$aTemp[$nCount][$j] = $__Http_Connection[$i][$j]
		Next
		$nCount += 1
	Next
	For $k = $nCount To UBound($__Http_Connection, 1)-1
		For $l = 0 To UBound($__Http_Connection, 2)-1
			$aTemp[$k][$l] = -1
		Next
		$aTemp[$k][1] = ""
	Next
	$__Http_Connection = $aTemp
	$__Http_Count_Connections = $nCount
EndFunc

Func __Http_GetPacket()
	If $__Http_Count_Connections < 1 Then Return
	Local $sRecv
	For $i = 0 To $__Http_Count_Connections-1
		If $__Http_Connection[$i][0] == -1 Then ContinueLoop
		$sRecv = TCPRecv($__Http_Connection[$i][0], $__Http_MaxPacketReceiveSize)
		If @error Then __Http_RemoveConnection($i)
		If $sRecv <> "" Then $__Http_Connection[$i][1] &= $sRecv
		If StringInStr(StringStripCR($__Http_Connection[$i][1]), @LF & @LF) Then
			$sPackets = StringSplit(StringStripCR( $__Http_Connection[$i][1] ), @LF & @LF, 3 )
			Local $sCompletePacket = $sPackets[0]
			_ArrayDelete($sPackets, 0)
			$__Http_Connection[$i][1] = _ArrayToString($sPackets)
			__Http_ProcessPacket($i, $sCompletePacket)
			__Http_RemoveConnection($i)
		EndIf
	Next
EndFunc

Func __Http_ProcessPacket($nSlot, $sData)
	Local $aToken = __Http_Header_GetData($sData)
	For $i = 0 To UBound($aToken)-1
		__Http_AsciiDecode($aToken[$i])
	Next
	__Http_RemoveRequestVulnerabilities($aToken[1])
	Local $sLogData = __Common_Socket_GetIP($__Http_Connection[$nSlot][0]) & @TAB & $aToken[0] & @TAB & $aToken[2] & $aToken[1]
	__Common_Print($sLogData)
	__Common_Log($__Http_AccessLogFile, $sLogData)
	Local $sDocumentRoot = $__Http_DefaultDocumentRoot
	$aToken[1] = StringReplace($aToken[1], "/", "\")
	If $__Http_VirtualHosts.Exists($aToken[2]) Then $sDocumentRoot = $__Http_VirtualHosts.Item($aToken[2])
	Switch $aToken[0]
		Case $HTTP_REQUEST_METHOD_GET
			__Http_ProcessGET($nSlot, $aToken[2], $sDocumentRoot, $aToken[1], $aToken[2] & $aToken[1])
		Case $HTTP_REQUEST_METHOD_POST
			If $aToken[4] >= 1 Then
				$__Http_Connection[$nSlot][6] = $aToken[4]
				$__Http_Connection[$nSlot][5] = True
				$__Http_Connection[$nSlot][1] = StringRight( $__Http_Connection[$nSlot][1], StringInStr( $__Http_Connection[$nSlot][1], @CRLF & @CRLF ) )
				$__Http_Connection[$nSlot][6] = $__Http_Connection[$nSlot][6] - StringLen($__Http_Connection[$nSlot][1])
				MsgBox(0, "debug", $__Http_Connection[$nSlot][1] & @CRLF & $__Http_Connection[$nSlot][6])
			Else
				$__Http_Connection[$nSlot][1] = ""
			EndIf
	EndSwitch
EndFunc

Func __Http_ProcessGET($nSlot, $sHost, $sDocumentRoot, $sPathRequest, $sDomainRequest)
	Local $aToken = __Tokenizer_TokenizeString($sPathRequest, "?")
	Local $sFile = $sDocumentRoot & $aToken[0]
	If UBound($aToken) > 1 Then
		; TODO:  Params!
	EndIf

	If $__Plugin_Extension.Exists(StringReplace($aToken[0], "\", "")) Then
		$aToken = __Tokenizer_TokenizeString(__Http_AsciiDecode($sPathRequest), "?")
		$aToken[0] = StringReplace($aToken[0], "\", "")
		Local $sPlugin = $aToken[0]
		If UBound($aToken) > 1 Then
			_ArrayDelete($aToken, 0)
		EndIf
		Local $sRet = __Plugin_Call($__Plugin_Extension.Item($sPlugin), $aToken)
		Local $sResponseHeader = __Http_Header_BuildHeaderResponse(BinaryLen($sRet), $__Http_ServerName, "text/html")
		__Http_SendData($__Http_Connection[$nSlot][0], $sResponseHeader & $sRet & @CRLF & @CRLF)
		Return
	EndIf

	If StringInStr($aToken[0], "\\") Then
		Local $sRep = StringReplace($sDomainRequest, "\\", "\")
		While StringInStr($sRep, "\\")
			$sRep = StringReplace($sRep, "\\", "\")
		WEnd
		;Local $sRep = StringRegExpReplace($sDomainRequest, "\{2}", "")
		__Http_Redirect($__Http_Connection[$nSlot][0], StringReplace($sRep, "\", "/"))
		Return
	EndIf

	If StringRight($aToken[0], 1) == "\" AND StringInStr(FileGetAttrib($sFile), "D") Then
		Local $bFoundIndex = false
		For $i = 0 To UBound($__Http_DefaultIndex)-1
			If FileExists($sFile & $__Http_DefaultIndex[$i]) Then
				$sFile &= $__Http_DefaultIndex[$i]
				$bFoundIndex = true
				ExitLoop
			EndIf
		Next

		If $bFoundIndex == False Then
			Local $sDirListPage = __Http_SendDirectoryList($sFile, $sDomainRequest)
			Local $sResponseHeader = __Http_Header_BuildHeaderResponse(BinaryLen($sDirListPage), $__Http_ServerName, "text/html")
			__Http_SendData($__Http_Connection[$nSlot][0], $sResponseHeader)
			__Http_SendData($__Http_Connection[$nSlot][0], $sDirListPage & @CRLF & @CRLF)
			TCPCloseSocket($__Http_Connection[$nSlot][0])
			Return
		EndIf
	EndIf

	If StringRight($aToken[0], 1) <> "\" AND StringInStr(FileGetAttrib($sFile), "D") Then
		__Http_Redirect($__Http_Connection[$nSlot][0], StringReplace($sDomainRequest, "\", "/") & '/')
		Return
	EndIf

	Local $sMimeType = __Http_GetFileMimeType(StringReplace(StringRight($sFile, 4), ".", ""))
	If FileExists($sFile) AND NOT StringInStr(FileGetAttrib($sFile), "D") Then

		Local $sResponseHeader = __Http_Header_BuildHeaderResponse(FileGetSize($sFile), $__Http_ServerName, $sMimeType)
		__Http_SendData($__Http_Connection[$nSlot][0], $sResponseHeader)

		If StringRight( $sFile, 4 ) == ".php" Then
			Local $iPID = Run( @ScriptDir & "\php\php.exe" & " " & $sFile, "", @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
			Local $sOutput
			While 1
				$sOutput &= StdoutRead($iPID)
				If @error Then ExitLoop
				Sleep(10)
			WEnd
			;MsgBox($MB_SYSTEMMODAL, "Stdout Read:", $sOutput)
			__Http_SendData($__Http_Connection[$nSlot][0], $sOutput & @CRLF & @CRLF)
		Else
			Local $hFile = FileOpen($sFile)
			__Http_SendData($__Http_Connection[$nSlot][0], FileRead($hFile) & @CRLF & @CRLF)
			FileClose($hFile)
		EndIf
		Return
	Else
		Local $s404 = "<!DOCTYPE HTML><html><body>404 - not found</body></html>" & @CRLF & @CRLF
		Local $sResponseHeader = __Http_Header_BuildHeaderResponse(BinaryLen($s404), $__Http_ServerName, "text/html")
		__Http_SendData($__Http_Connection[$nSlot][0], $sResponseHeader)
		__Http_SendData($__Http_Connection[$nSlot][0], $s404)
	EndIf
EndFunc

Func __Http_ProcessPOST($nSocket, $sData)
	; TODO
EndFunc

Func __Http_CheckPOST()
	For $i = 0 To $__Http_Count_Connections-1
		If $__Http_Connection[$i][5] Then
			$__Http_Connection[$i][1] &= TCPRecv( $__Http_Connection[$i][0], $__Http_Connection[$i][6] )
			$__Http_Connection[$nSlot][6] = $__Http_Connection[$nSlot][6] - StringLen($__Http_Connection[$nSlot][1])
			If $__Http_Connection[$nSlot][6] <= 0 Then
				$__Http_Connection[$nSlot][5] = False
				__Http_ProcessPOST( $i, $__Http_Connection[$i][1] )
			EndIf
		EndIf
	Next
EndFunc

Func __Http_Redirect($nSock, $sDest)
	Local $htmlData = '<!DOCTYPE HTML><html lang="en-US"><head><meta charset="UTF-8">'
    $htmlData &= '<meta http-equiv="refresh" content="1;' & "http://" & $sDest & '"><script type="text/javascript">window.location.href = "' & "http://" & $sDest & '"</script>'
    $htmlData &= '<title>Page Redirection</title></head><body>If you are not redirected automatically, follow this <a href="' & "http://" & $sDest & '">link</a></body></html>'
	Local $sResponseHeader = __Http_Header_BuildHeaderResponse(BinaryLen($htmlData), $__Http_ServerName, "text/html")
	__Http_SendData($nSock, $sResponseHeader)
	__Http_SendData($nSock, $htmlData & @CRLF & @CRLF)
EndFunc

Func __Http_SendData($nSock, $sData)
	Return TCPSend($nSock, Binary($sData))
EndFunc

Func __Http_ProcessFileQueue()
	For $i = 0 To $__Http_Count_Connections-1
		If $__Http_Connection[$i][3] <> -1 Then
			__Http_SendData($__Http_Connection[$i][0], FileRead($__Http_Connection[$i][4], $__Http_FileChunkSize))
			If FileGetPos($__Http_Connection[$i][4]) >= $__Http_Connection[$i][3] Then
				__Http_SendData($__Http_Connection[$i][0], @CRLF & @CRLF)
				FileClose($__Http_Connection[$i][4])
				__Http_RemoveConnection($i)
			EndIf
		EndIf
	Next
EndFunc

Func __Http_AsciiEncode($sData)
	; TODO
EndFunc

Func __Http_AsciiDecode($sData)
	Local $sRet = ""
	Local $sSplit = StringSplit($sData, "", 3)
	For $I = 0 To UBound($sSplit)-1
		If $sSplit[$I] == "%" Then
			$sRet &= Chr(Dec($sSplit[$I+1] & $sSplit[$I+2]))
			$I += 2
		Else
			$sRet &= $sSplit[$I]
		EndIf
	Next
	Return BinaryToString(StringToBinary(StringReplace($sRet, '+', ' ')), 4)
EndFunc

Func __Http_RegisterVHost($sHost, $sDir = "")
	If Stringlen($sDir) < 1 Then $sDir = @ScriptDir & "\www\" & $sHost
	If $__Http_VirtualHosts.Exists($sHost) Then Return False
	$__Http_VirtualHosts.Add($sHost, $sDir)
	If NOT FileExists($sDir) Then
		DirCreate($sDir)
		FileWrite($sDir & "\" & "index.html", "<!DOCTYPE html><html><body>Freshly registered Virtual Host!<br>(default generated index.html)</body></html>")
	EndIf
	Return True
EndFunc

Func __Http_UnregisterVHost($sHost)
	If $__Http_VirtualHosts.Exists($sHost) Then $__Http_VirtualHosts.Remove($sHost)
	Return NOT $__Http_VirtualHosts.Exists($sHost)
EndFunc

Func __Http_RemoveRequestVulnerabilities(ByRef $sData)
	$sData = StringReplace(StringReplace(StringReplace(StringReplace($sData, "../", ""), "..\", ""), "./", ""), ".\", "")
EndFunc

Func __Http_GetFileMimeType($sR4)
	Local $sRet
	Switch $sR4
		Case "jpg", "jpeg", "gif", "png", "tiff", "bmp"
			$sRet = "image/" & $sR4
		Case "txt", "log", "au3"
			$sRet = "text/" & $sR4
		Case "htm", "html"
			$sRet = "text/html"
		Case "php"
			$sRet = "text/php"
		Case "phps"
			$sRet = "application/x-httpd-php-source"
		Case "css"
			$sRet = "text/css"
		Case "ico"
			$sRet = "image/x-icon"
		Case "js"
			$sRet = "application/javascript"
		Case Else
			$sRet = "application/octet-stream"
	EndSwitch
	Return $sRet
EndFunc

Func __Http_SendDirectoryList($sFileLoc, $sWebLoc)
	Local $htmlPageInsertData = ""
	Local $htmlDirectoryData = '<tr><td>Name</td><td>Modified</td><td>Size</td></tr>'
	Local $htmlPageData = ""
	$htmlPageData &= '<html><body><h1>Directory Listing For<br>PATH</h1><table width="750" border="0"><strong><tr><td width="450">Name</td>'
    $htmlPageData &= '<td width="200">Last Modified</td><td width="140">Size (KB)</td></tr></strong>REPEAT'
	$htmlPageData &= '</table><p>Powered By <strong>LemonWeb</strong></p></body></html>'
	Local $FileListArray = _FileListToArray($sFileLoc)
	For $i = 1 To UBound($FileListArray)-1
		Local $aModified = FileGetTime($sFileLoc & $FileListArray[$i], $FT_MODIFIED, 0)
		Local $sModified = $aModified[0] & "/" & $aModified[1] & "/" & $aModified[2] & "  " & $aModified[3] & ":" & $aModified[4] & ":" & $aModified[5]
		Local $curData = $htmlDirectoryData
		$curData = StringReplace($curData, "Name", '<a href="http://' & $sWebLoc & $FileListArray[$i] & '">' & $FileListArray[$i] & '</a>')
		$curData = StringReplace($curData, "Modified", $sModified)
		$curData = StringReplace($curData, "Size", Round(FileGetSize($sFileLoc & $FileListArray[$i])/1024, 2))
		$htmlPageInsertData &= $curData
	Next
	$htmlPageData = StringReplace($htmlPageData, "PATH", StringReplace($sWebLoc, "\", "/"))
	$htmlPageData = StringReplace($htmlPageData, "REPEAT", $htmlPageInsertData)
	Return $htmlPageData
EndFunc















