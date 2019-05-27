#cs ----------------------------------------------------------------------------
 Script Function:	TEMPLATE - find/replace 'TEMPLATE' with plugin name, then code away!
 AutoIt Version: 	3.3.10.2
 Author:			Caleb Alexander
#ce ----------------------------------------------------------------------------
; Script Start - Add your code below here

#include-once
#include "../libs/common/common.au3"

Global Const 	$__Plugin_TEMPLATE_Name = 		"TEMPLATE"
Global Const 	$__Plugin_TEMPLATE_Usage = 		"Usage:<br>/TEMPLATE.au3?data=test"
Global Const 	$__Plugin_TEMPLATE_Error = 		"Improperly Formatted Parameters<br><br>" & $__Plugin_TEMPLATE_Usage
Global Const 	$__Plugin_TEMPLATE_Params[1] = 	["data"]
Global 			$__Plugin_TEMPLATE_Data[1]

Func __Plugin_TEMPLATE_Setup()
	;
EndFunc

Func __Plugin_TEMPLATE_Main($args)
	If StringLower($args[0]) == $__Plugin_TEMPLATE_Name & ".au3" Then
		Return $__Plugin_TEMPLATE_Usage
	EndIf
	If UBound($args) == UBound($__Plugin_TEMPLATE_Params) Then
		For $i = 0 To UBound($__Plugin_TEMPLATE_Params)-1
			If NOT StringInStr($args[$i], "=") Then Return $__Plugin_TEMPLATE_Error
			Local $split = StringSplit($args[$i], "=", 3)
			$__Plugin_TEMPLATE_Data[$i] = $split[1]
			If $split[0] <> $__Plugin_TEMPLATE_Params[$i] Then Return $__Plugin_TEMPLATE_Error
		Next
	EndIf
	Return $__Plugin_TEMPLATE_Error
EndFunc