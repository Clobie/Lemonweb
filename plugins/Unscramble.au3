#cs ----------------------------------------------------------------------------
 Script Function:	Word Unscrambler
 AutoIt Version: 	3.3.10.2
 Author:			Caleb Alexander
#ce ----------------------------------------------------------------------------
; Script Start - Add your code below here

#include-once
#include "../libs/common/common.au3"

Global Const 	$__Plugin_Unscramble_Name = 		"Unscramble"
Global Const 	$__Plugin_Unscramble_Usage = 		"Usage:<br>/unscramble.au3?word=test"
Global Const 	$__Plugin_Unscramble_Error = 		"Improperly Formatted Parameters<br><br>" & $__Plugin_Unscramble_Usage
Global Const 	$__Plugin_Unscramble_Dictionary = ObjCreate("Scripting.Dictionary")
Global Const 	$__Plugin_Unscramble_Params[1] = 	["word"]
Global 			$__Plugin_Unscramble_Data[1]

Func __Plugin_Unscramble_UnscrambleWord( $sWord )
	Local $nTimer = TimerInit()
	Local $aWord = StringSplit($sWord, "", 3)
	_ArraySort($aWord)
	Local $sWordAlpha = _ArrayToString($aWord, "")
	If $__Plugin_Unscramble_Dictionary.Exists($sWordAlpha) Then
		Return $__Plugin_Unscramble_Dictionary.Item($sWordAlpha) & @CRLF & Round(TimerDiff($nTimer), 2) & "s"
	Else
		Return "No matches found: " & $sWordAlpha
	EndIf
EndFunc

Func __Plugin_Unscramble_Setup()
	local $fRead = FileOpen( @ScriptDir & "\resources\oDict.txt" )
	If $fRead == -1 Then
		MsgBox( 0, "Error", "Unable to open dictionary file" )
	EndIf
	Local $aDict = StringSplit( FileRead( $fRead ), @LF, 3)
	FileClose( $fRead )
	For $i = 1 To UBound($aDict)-1
		If StringInStr($aDict[$i], ": ") Then
			Local $aSplit = StringSplit($aDict[$i], ": ", 3)
			If $__Plugin_Unscramble_Dictionary.Exists($aSplit[0]) Then
				ContinueLoop
			Else
				$__Plugin_Unscramble_Dictionary.Add($aSplit[0], $aSplit[1])
			EndIf
		EndIf
	Next
EndFunc

Func __Plugin_Unscramble_Main($args)
	If StringLower($args[0]) == $__Plugin_Unscramble_Name & ".au3" Then
		Return $__Plugin_Unscramble_Usage
	EndIf
	If UBound($args) == UBound($__Plugin_Unscramble_Params) Then
		For $i = 0 To UBound($__Plugin_Unscramble_Params)-1
			If NOT StringInStr($args[$i], "=") Then Return $__Plugin_Unscramble_Error
			Local $split = StringSplit($args[$i], "=", 3)
			$__Plugin_Unscramble_Data[$i] = $split[1]
			If $split[0] <> $__Plugin_Unscramble_Params[$i] Then Return $__Plugin_Unscramble_Error
		Next
	EndIf
	Return __Plugin_Unscramble_UnscrambleWord( $__Plugin_Unscramble_Data[0] )
EndFunc