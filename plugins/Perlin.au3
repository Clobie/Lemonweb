#cs ----------------------------------------------------------------------------
 Script Function:	Perlin
 AutoIt Version: 	3.3.10.2
 Author:			Caleb Alexander
#ce ----------------------------------------------------------------------------
; Script Start - Add your code below here

#include-once
#include "../libs/common/common.au3"

Global Const 	$__Plugin_Perlin_Name = 		"Perlin"
Global Const 	$__Plugin_Perlin_Usage = 		"Usage:<br>/perlin.au3?data=10"
Global Const 	$__Plugin_Perlin_Error = 		"Improperly Formatted Parameters<br><br>" & $__Plugin_Perlin_Usage
Global Const 	$__Plugin_Perlin_Params[1] = 	["data"]
Global 			$__Plugin_Perlin_Data[1]

Func __Plugin_Perlin_Setup()
	;
EndFunc

Func __Plugin_Perlin_Main($args)
	If StringLower($args[0]) == $__Plugin_Perlin_Name & ".au3" Then
		Return $__Plugin_Perlin_Usage
	EndIf
	If UBound($args) == UBound($__Plugin_Perlin_Params) Then
		For $i = 0 To UBound($__Plugin_Perlin_Params)-1
			If NOT StringInStr($args[$i], "=") Then Return $__Plugin_Perlin_Error
			Local $split = StringSplit($args[$i], "=", 3)
			$__Plugin_Perlin_Data[$i] = $split[1]
			If $split[0] <> $__Plugin_Perlin_Params[$i] Then Return $__Plugin_Perlin_Error
		Next

		Local $data = BinaryToString( INetRead( "http://noise.shora.net/noise/" & $__Plugin_Perlin_Data[0] & "/" & $__Plugin_Perlin_Data[0] ) )

		Return $data
	EndIf
	Return $__Plugin_Perlin_Error
EndFunc