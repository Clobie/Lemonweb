#cs ----------------------------------------------------------------------------
 Script Function:	Echo
 AutoIt Version: 	3.3.10.2
 Author:			Caleb Alexander
#ce ----------------------------------------------------------------------------
; Script Start - Add your code below here

#include-once
#include "../libs/common/common.au3"

Global Const 	$__Plugin_Echo_Name = 		"Echo"
Global Const 	$__Plugin_Echo_Usage = 		"Usage:<br>/echo.au3?data=test"
Global Const 	$__Plugin_Echo_Error = 		"Improperly Formatted Parameters<br><br>" & $__Plugin_Echo_Usage
Global Const 	$__Plugin_Echo_Params[1] = 	["data"]
Global 			$__Plugin_Echo_Data[1]

Func __Plugin_Echo_Setup()
	;
EndFunc

Func __Plugin_Echo_Main($args)
	If StringLower($args[0]) == $__Plugin_Echo_Name & ".au3" Then
		Return $__Plugin_Echo_Usage
	EndIf
	If UBound($args) == UBound($__Plugin_Echo_Params) Then
		For $i = 0 To UBound($__Plugin_Echo_Params)-1
			If NOT StringInStr($args[$i], "=") Then Return $__Plugin_Echo_Error
			Local $split = StringSplit($args[$i], "=", 3)
			$__Plugin_Echo_Data[$i] = $split[1]
			If $split[0] <> $__Plugin_Echo_Params[$i] Then Return $__Plugin_Echo_Error
		Next
		Return $__Plugin_Echo_Data[0]
	EndIf
	Return $__Plugin_Echo_Error
EndFunc