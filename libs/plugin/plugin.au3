#cs ----------------------------------------------------------------------------
 Script Function:	plugins
 AutoIt Version: 	3.3.10.2
 Author:			Caleb Alexander
#ce ----------------------------------------------------------------------------
; Script Start - Add your code below here

#include-once
#include "../common/common.au3"
#include "../../plugins/unscramble.au3"
#include "../../plugins/echo.au3"
#include "../../plugins/Base64.au3"
#include "../../plugins/HoloModeler.au3"
#include "../../plugins/php.au3"
#include "../../plugins/perlin.au3"

Global $__Plugin_Extension =			ObjCreate("Scripting.Dictionary")
Global $__Plugin_FunctionPrefix = 		"__Plugin_"
Global $__Plugin_FunctionMainSuffix = 	"_Main"
Global $__Plugin_FunctionSetupSuffix = 	"_Setup"

__Plugin_Setup()

Func __Plugin_Setup()
	$__Plugin_Extension.Add("unscramble.au3", "Unscramble")
	$__Plugin_Extension.Add("echo.au3", "Echo")
	$__Plugin_Extension.Add("base64.au3", "Base64")
	$__Plugin_Extension.Add("holomodeler.au3", "HoloModeler")
	$__Plugin_Extension.Add("php.au3", "php")
	$__Plugin_Extension.Add("perlin.au3", "perlin")

	Local $aPlugins = $__Plugin_Extension.keys
	For $i = 0 To UBound($aPlugins)-1
		If $__Plugin_Extension.Exists($aPlugins[$i]) Then
			__Common_Print("Loading " & $__Plugin_Extension.Item($aPlugins[$i]) & "...")
			__Plugin_Initialize($__Plugin_Extension.Item($aPlugins[$i]))
		EndIf
	Next
EndFunc

Func __Plugin_Initialize($sPlugin)
	Local $fPlugin = $__Plugin_FunctionPrefix & $sPlugin & $__Plugin_FunctionSetupSuffix
	Return Call($fPlugin)
EndFunc

Func __Plugin_Call($sPlugin, $args)
	Local $fPlugin = $__Plugin_FunctionPrefix & $sPlugin & $__Plugin_FunctionMainSuffix
	Return Call($fPlugin, $args)
EndFunc