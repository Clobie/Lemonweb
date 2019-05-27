#cs ----------------------------------------------------------------------------
 Script Function:	common functions
 AutoIt Version: 	3.3.10.2
 Author:			Caleb Alexander
#ce ----------------------------------------------------------------------------
; Script Start - Add your code below here

#include-once

Global $__NTDLL_DLL
Global $__WS2_32_DLL

Func __Common_Start()
	__Common_Print("Initializing Common...")
	$__NTDLL_DLL = DllOpen("ntdll.dll")
	$__WS2_32_DLL = DllOpen("ws2_32.dll")
EndFunc

Func __Common_Stop()
	__Common_Print("Stopping Common...")
	DllClose($__NTDLL_DLL)
	DllClose($__WS2_32_DLL)
EndFunc

Func __Common_Exception($sData)
	MsgBox(48, "EXCEPTION", $sData)
	Exit
EndFunc

Func __Common_Print($sData)
	If @Compiled Then
		ConsoleWrite( __Common_GetTimestamp() & "  " & $sData & @CRLF)
	Else
		;MsgBox(0, "", __Common_GetTimestamp() & "  " & $sData)
		;TrayTip("LemonWeb", __Common_GetTimestamp() & "  " & $sData, 16, 1)
	EndIf
EndFunc

Func __Common_Sleep($sMicroSeconds, $__NTDLL_DLL = "ntdll.dll")
	Local $DllStruct
	$DllStruct = DllStructCreate("int64 time;")
	DllStructSetData($DllStruct, "time", -1 * ($sMicroSeconds * 10))
	DllCall($__NTDLL_DLL, "dword", "ZwDelayExecution", "int", 0, "ptr", DllStructGetPtr($DllStruct))
EndFunc

Func __Common_Socket_GetIP($nSocket)
	Local $addrSocket = DllStructCreate("short;ushort;uint;char[8]")
	Local $aRet = DllCall($__WS2_32_DLL, "int", "getpeername", "int", $nSocket, "ptr", DllStructGetPtr($addrSocket), "int*", DllStructGetSize($addrSocket))
	If Not @error And $aRet[0] = 0 Then
		$aRet = DllCall($__WS2_32_DLL, "str", "inet_ntoa", "int", DllStructGetData($addrSocket, 3))
		If Not @error Then $aRet = $aRet[0]
	Else
		$aRet = 0
	EndIf
	$addrSocket = 0
	Return $aRet
EndFunc

Func __Common_GetTimestamp()
	Local $h, $m, $s
	$h = @Hour
	$m = @MIN
	$s = @Sec
	Return $h & ":" & $m & ":" & $s
EndFunc

Func __Common_Log($sFile, $sData)
	Local $hFile = FileOpen($sFile, 1)
	FileWrite($hFile, __Common_GetTimestamp() & " " & $sData & @CRLF)
	FileClose($hFile)
EndFunc