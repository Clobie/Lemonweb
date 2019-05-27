#cs ----------------------------------------------------------------------------
 Script Function:	tokenizer
 AutoIt Version: 	3.3.10.2
 Author:			Caleb Alexander
#ce ----------------------------------------------------------------------------
#include-once
#include <Array.au3>

Global Const 	$TOKENIZER_TRIM_NONE = 0
Global Const 	$TOKENIZER_TRIM_WS = 1

Func __Tokenizer_TokenizeString($sText, $sDelim = " ", $trim = $TOKENIZER_TRIM_NONE)
	Local $aToken = StringSplit($sText, $sDelim, 3)

	Switch $trim
		Case $TOKENIZER_TRIM_WS
			For $i = 0 To UBound($aToken)-1
				$aToken[$i] = StringStripWS($aToken[$i], 3)
			Next
		Case Else
			; NO
	EndSwitch

	Return $aToken
EndFunc

Func __Tokenizer_TokenizeOnlyFirstToken( $sText, $sDelim = " ", $sFakeDelim = 0x0, $trim = $TOKENIZER_TRIM_NONE )
	If StringInStr( $sText, $sFakeDelim ) Then Return ["ERROR"]
	Return __Tokenizer_TokenizeString( StringReplace( $sText, $sDelim, $sFakeDelim, 1 ), $sFakeDelim, $trim )
EndFunc