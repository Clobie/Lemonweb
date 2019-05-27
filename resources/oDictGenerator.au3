#cs ----------------------------------------------------------------------------
 Script Function:	http server header functions
 AutoIt Version: 	3.3.10.2
 Author:			Caleb Alexander
#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

#include-once
#include <Array.au3>

Global $__Dictionary_List = 	ObjCreate("Scripting.Dictionary")
Global $__Array_Words_Normal = StringSplit(FileRead(@ScriptDir & "\wordlist.txt"), @CRLF, 3)
Global $__Array_Words_Alpha = StringSplit(FileRead(@ScriptDir & "\wordlist-alpha.txt"), @CRLF, 3)
Global $__Array_Displayer[UBound($__Array_Words_Normal)]
_Main()
Func _Main()
	For $i = 0 To UBound($__Array_Words_Normal)-1
		Local $aWord = StringSplit($__Array_Words_Normal[$i], "", 3)
		_ArraySort($aWord)
		Local $sWordAlpha = _ArrayToString( $aWord, "" )

		If $__Dictionary_List.Exists($sWordAlpha) Then
			If StringInStr($__Array_Words_Normal[$i], $__Dictionary_List.Item($sWordAlpha)) Then
				ContinueLoop
			Else
				$__Dictionary_List.Item($sWordAlpha) = $__Dictionary_List.Item($sWordAlpha) & "," & $__Array_Words_Normal[$i]
			EndIf
		Else
			$__Dictionary_List.Add($sWordAlpha, $__Array_Words_Normal[$i])
		EndIf
	Next

	Local $nPos = 0
	For $sKey In $__Dictionary_List
		$__Array_Displayer[$nPos] = $sKey & ": " & $__Dictionary_List.Item($sKey)
		$nPos += 1
	Next
	FileWrite(@ScriptDir & "\oDict.txt", _ArrayToString($__Array_Displayer, @CRLF))
EndFunc