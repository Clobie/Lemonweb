#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Res\Icon.ico
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Comment=LemonWeb http server
#AutoIt3Wrapper_Res_Description=LemonWeb http server
#AutoIt3Wrapper_Res_Fileversion=2.0.0.0
#AutoIt3Wrapper_Res_LegalCopyright=© 2014 Caleb Alexander.  All rights reserved.
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------
 Script Function:	http server
 AutoIt Version: 	3.3.10.2
 Author:			Caleb Alexander
#ce ----------------------------------------------------------------------------
; Script Start - Add your code below here

#include "libs/http/http.au3"

__Http_SetPort(80)
__Http_Start()
__Common_Start()


__Http_RegisterVHost("dream-e2.tk")
__Http_RegisterVHost("www.dream-e2.tk")

Main()

Func Main()
	__Common_Print("Initialized!")
	While 1
		__Http_GetConnection()
		__Http_GetPacket()
		;__Http_ProcessFileQueue()
		__Common_Sleep(1000)
	WEnd

	__Http_Stop()
	__Common_Stop()
EndFunc