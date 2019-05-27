#cs ----------------------------------------------------------------------------
 Script Function:	http server header functions
 AutoIt Version: 	3.3.10.2
 Author:			Caleb Alexander
#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

#include-once
#include "../common/constants.au3"
#include "../common/tokenizer.au3"

Func __Http_Header_GetData($sHeader)
	Local $aToken = __Tokenizer_TokenizeString(StringStripCR($sHeader), @LF)
	Local $aRet[5]
	For $i = 0 To UBound($aToken)-1
		Local $aToken2 = __Tokenizer_TokenizeString($aToken[$i])
		Switch StringReplace($aToken2[0], ":", "")
			Case $HTTP_REQUEST_METHOD_GET
				$aRet[0] = $HTTP_REQUEST_METHOD_GET
				$aRet[1] = $aToken2[1]
			Case $HTTP_REQUEST_METHOD_POST
				$aRet[0] = $HTTP_REQUEST_METHOD_POST
				$aRet[1] = $aToken2[1]
			Case $HTTP_REQUEST_HEADER_HOST
				$aRet[2] = $aToken2[1]
			Case $HTTP_REQUEST_HEADER_CONTENT_LENGTH
				$aRet[4] = Number($aToken[1])
		EndSwitch
	Next
	Return $aRet
EndFunc

Func __Http_Header_GetRequestType($sHeader)
	Local $aToken = __Tokenizer_TokenizeString($sHeader)
	If UBound($aToken) == 3 Then
		Return $aToken[0]
	EndIf
	Return ""
EndFunc

Func __Http_Header_GetRequestData($sHeader)
	Local $aToken = __Tokenizer_TokenizeString($sHeader)
	If UBound($aToken) == 3 Then
		Return $aToken[1]
	EndIf
	Return ""
EndFunc

Func __Http_Header_GetHttpVersion($sHeader)
	Local $aToken = __Tokenizer_TokenizeString($sHeader)
	If UBound($aToken) == 3 Then
		Return $aToken[2]
	EndIf
	Return ""
EndFunc

Func __Http_Header_GetHost($sHeader)
	Local $aToken = __Tokenizer_TokenizeString($sHeader)
	If UBound($aToken) == 2 Then
		Return $aToken[1]
	EndIf
	Return ""
EndFunc

Func __Http_Header_GetUserAgent($sHeader)
	Local $aToken = __Tokenizer_TokenizeString($sHeader)
	If UBound($aToken) == 2 Then
		Return $aToken[1]
	EndIf
	Return ""
EndFunc

Func __Http_Header_BuildHeaderResponse($nDataLen, $sServerName, $sMime = "text/html", $sReply = "200 OK")
	Local $sHeader = 	"HTTP/1.1 " & $sReply & @CRLF & _
						"Server: " & $sServerName & @CRLF & _
						"Connection: keep-alive" & @CRLF & _
						"Content-Length: " & $nDataLen & @CRLF & _
						"Content-Type: " & $sMime & @CRLF & @CRLF
	Return $sHeader
EndFunc