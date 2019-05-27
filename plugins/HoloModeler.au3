#cs ----------------------------------------------------------------------------
 Script Function:	An API to Upload/Download hologram models for sharing.
 AutoIt Version: 	3.3.10.2
 Author:			Caleb Alexander
#ce ----------------------------------------------------------------------------
; Script Start - Add your code below here

#include-once
#include "../libs/common/common.au3"

Global Const 	$__Plugin_HoloModeler_Name = 		"HoloModeler"
Global Const 	$__Plugin_HoloModeler_Usage = 		"Usage:<br>" & _
													"/HoloModeler.au3?request=version<br>" & _
													"/HoloModeler.au3?request=list<br>" & _
													"/HoloModeler.au3?request=update<br>" & _
													"/HoloModeler.au3?request=download?file=filename.txt<br>" & _
													"/HoloModeler.au3?request=upload?file=filename.txt?data=filedata<br>" & _
													""

Global Const 	$__Plugin_HoloModeler_Error = 		"Improperly Formatted Parameters<br><br>" & $__Plugin_HoloModeler_Usage
Global Const 	$__Plugin_HoloModeler_Params[1] = 	["request"]
Global 			$__Plugin_HoloModeler_Data[5]
Global Const 	$__Plugin_HoloModeler_Root = 			@ScriptDir & "\resources\HoloModeler\"
Global Const 	$__Plugin_HoloModeler_SettingsFile = 	$__Plugin_HoloModeler_Root + "Settings.ini"
Global Const 	$__Plugin_HoloModeler_DataFile = 		$__Plugin_HoloModeler_Root + "Data.ini"
Global Const 	$__Plugin_HoloModeler_Version = 		"6.3"

Func __Plugin_HoloModeler_RequestModelList()
	local $R = _FileListToArrayRec( @ScriptDir & "\resources\models\", "*", 1, 1, 2, 1 )
	_ArrayDelete( $R, 0 )
	Return _ArrayToString( $R, @LF )
EndFunc

Func __Plugin_HoloModeler_RequestModelFile( $file )
	If FileExists( @ScriptDir & "\resources\models\" & $file ) Then
		Return FileRead( @ScriptDir & "\resources\models\" & $file )
	EndIf
	Return "ERR_NO_FILE"
EndFunc

Func _URIDecode($sData)
    ; Prog@ndy
    Local $aData = StringSplit(StringReplace($sData,"+"," ",0,1),"%")
    $sData = ""
    For $i = 2 To $aData[0]
        $aData[1] &= Chr(Dec(StringLeft($aData[$i],2))) & StringTrimLeft($aData[$i],2)
    Next
    Return BinaryToString(StringToBinary($aData[1],1),4)
EndFunc

Func __Plugin_HoloModeler_Version()
	Return $__Plugin_HoloModeler_Version
EndFunc

Func __Plugin_HoloModeler_RequestUpdate()
	local $File = @ScriptDir & "\resources\" & "hologram_modeler.txt"
	Return FileRead( $File )
EndFunc

Func __Plugin_HoloModeler_Upload( $file, $data, $steam )

	If FileExists( @ScriptDir & "\resources\models\" & $steam & "\" & $file ) Then
		Return "Model already exists, use a different name."
	EndIf

	Local $FileData = _URIDecode( $data )
	$FileData = StringReplace( $FileData, "$p", "+", 0, 1 )
	$FileData = StringReplace( $FileData, "$e", "=", 0, 1 )

	If StringLen( $file ) < 256 Then
		If StringInStr( $file, ".txt" ) Then
			Local $FOpen = FileOpen( @ScriptDir & "\resources\models\" & $steam & "\" & $file, 10 )
			FileWrite( $FOpen, $FileData )
			FileClose( $FOpen )
			;FileWrite( @ScriptDir & "\resources\models\" & $file, $FileData )
		EndIf
	EndIf

EndFunc

Func __Plugin_HoloModeler_Setup()
	;
EndFunc

Func __Plugin_HoloModeler_Main($args)

	Switch UBound($args)
		Case 2
			local $arg1 = StringSplit( $args[0], "=" )
			local $arg2 = StringSplit( $args[1], "=" )

			If UBound( $arg1 ) + UBound( $arg2 ) == 6 Then
				If $arg2[1] == "steamid" Then
					local $steam = $arg2[2]
					If $arg1[1] == "request" Then
						If $arg1[2] == "list" Then
							Return __Plugin_HoloModeler_RequestModelList()
						EndIf
						If $arg1[2] == "version" Then
							Return __Plugin_HoloModeler_Version()
						EndIf
						If $arg1[2] == "update" Then
							Return __Plugin_HoloModeler_RequestUpdate()
						EndIf
					EndIf
				EndIf
				Return $__Plugin_HoloModeler_Usage
			EndIf
			Return
		Case 3
			local $arg1 = StringSplit( $args[0], "=" )
			local $arg2 = StringSplit( $args[1], "=" )
			local $arg3 = StringSplit( $args[2], "=" )
			local $steam = ""

			;MsgBox( 0, "",  $arg1[1] & " = " & $arg1[2] & @CRLF & _
			;				$arg2[1] & " = " & $arg2[2] & @CRLF & _
			;				$arg3[1] & " = " & $arg3[2] & @CRLF )

			If UBound( $arg1 ) + UBound( $arg2 ) + UBound( $arg3 ) == 9 Then
				If $arg1[1] == "request" Then
					If $arg1[2] == "download" Then
						If $arg2[1] == "steamid" Then
							$steam = StringReplace( $arg2[2], ":", "" )
							If $arg3[1] == "file" Then
								If FileExists( @ScriptDir & "\resources\models\" & $steam & "\" & $arg3[2] ) Then
									local $Read = FileRead( @ScriptDir & "\resources\models\" & $steam & "\" & $arg3[2] )
									Return $Read
								EndIf
								If FileExists( @ScriptDir & "\resources\models\" & $arg3[2] ) Then
									local $Read = FileRead( @ScriptDir & "\resources\models\" & $arg3[2] )
									Return $Read
								EndIf
								Return "ERR_NO_FILE"
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf

		Case 4
			local $arg1 = StringSplit( $args[0], "=" )
			local $arg2 = StringSplit( $args[1], "=" )
			local $arg3 = StringSplit( $args[2], "=" )
			local $arg4 = StringSplit( $args[3], "=" )

			local $steam = ""

			If UBound( $arg1 ) + UBound( $arg2 ) + UBound( $arg3 ) + UBound( $arg4 ) == 12 Then
				If $arg1[1] == "request" Then
					If $arg1[2] == "upload" Then
						If $arg2[1] == "steamid" Then
							$steam = StringReplace( $arg2[2], ":", "" )
							If $arg3[1] == "file" Then
								If StringInStr( $arg3[2], ".txt" ) Then
									If $arg4[1] = "data" Then
										Local $FDATA = StringReplace( $arg4[2], "-eq", "=" )
										$FDATA = StringReplace( $arg4[2], "-pl", "+" )
										__Plugin_HoloModeler_Upload( $arg3[2], $FDATA, $steam )
										Return "success " & StringLen( $arg4[2] )
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
	EndSwitch

	Return $__Plugin_HoloModeler_Error

EndFunc

