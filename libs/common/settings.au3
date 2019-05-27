#cs ----------------------------------------------------------------------------
 Script Function:	http server settings functions
 AutoIt Version: 	3.3.10.2
 Author:			Caleb Alexander
#ce ----------------------------------------------------------------------------
#include-once

Const $__Settings_File = 	@ScriptDir & "\" & "settings.ini"

Func __Settings_Start()
	If NOT FileExists($__Settings_File) Then
		IniWrite($__Settings_File, "Setup", "FirstRun", 1)
	Else
		IniWrite($__Settings_File, "Setup", "FirstRun", 0)
	EndIf
EndFunc