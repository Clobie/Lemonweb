#cs ----------------------------------------------------------------------------
 Script Function:	php
 AutoIt Version: 	3.3.10.2
 Author:			Caleb Alexander
#ce ----------------------------------------------------------------------------
; Script Start - Add your code below here

#include-once
#include "../libs/common/common.au3"
#include "Constants.au3"

Global Const 	$__Plugin_php_Name = 		"php"
Global Const 	$__Plugin_php_Usage = 		"Usage:<br>/php.au3?script=test.php"
Global Const 	$__Plugin_php_Error = 		"Improperly Formatted Parameters<br><br>" & $__Plugin_php_Usage
Global Const 	$__Plugin_php_Params[1] = 	["script"]
Global 			$__Plugin_php_Data[1]

Func __Plugin_php_Setup()
	;
	;MsgBox( 0, "", "php" )
EndFunc

Func __Plugin_php_Main($args)
	If StringLower($args[0]) == $__Plugin_php_Name & ".au3" Then
		Return $__Plugin_php_Usage
	EndIf
	If UBound($args) == UBound($__Plugin_php_Params) Then
		For $i = 0 To UBound($__Plugin_php_Params)-1
			If NOT StringInStr($args[$i], "=") Then Return $__Plugin_php_Error
			Local $split = StringSplit($args[$i], "=", 3)
			$__Plugin_php_Data[$i] = $split[1]
			If $split[0] <> $__Plugin_php_Params[$i] Then Return $__Plugin_php_Error
		Next

		Local $iPID = Run(@scriptdir & "\php\php.exe" & " " & @ScriptDir & "\php\" & $__Plugin_php_Data[0], "", @SW_HIDE, $STDOUT_CHILD + $STDERR_CHILD)
		Local $sOutput
		While 1
			$sOutput &= StdoutRead($iPID)
			If @error Then ExitLoop
			Sleep(10)
		WEnd
		;MsgBox($MB_SYSTEMMODAL, "Stdout Read:", $sOutput)

		local $Return = "pid: " & $iPID & "<br>" & "data: " & $sOutput

		ProcessClose( $iPID )

		Return $Return
		;Local $sOutput = StdoutRead($iPID)
		;return $sOutput
	EndIf
	Return $__Plugin_php_Error
EndFunc