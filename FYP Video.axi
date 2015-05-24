PROGRAM_NAME='FYP Video'
(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE
NON_VOLATILE INTEGER nTvPower
NON_VOLATILE INTEGER nBluRayPower
NON_VOLATILE INTEGER nSkyPower
CHAR cDeviceLogStatus[1000]
INTEGER nVolLevel
INTEGER nDeviceOn
NON_VOLATILE INTEGER nDvdStatus
(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(*******************************************-****************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)

/*
 * SamsungTVPowerOn function
 *
 * function to power on tv
 * write to log file noting tv is turned on at the particular time
 */
DEFINE_FUNCTION SamsungTVPowerOn(){
    SEND_STRING 0, "'Power On TV'"
    IF (nTvPower = 0){
	SEND_STRING 0, "'To tv power on'"
	TO[dvTvMon, SamsungTV_UN_SERIES_Power]
	//TO[dvTvMon, cSamsungTV_Power_On]
	nTvPower = 1
	cDeviceLogStatus = "DATE, ' mode:', cDeviceInUse, ' time:', TIME"
	appendToFile('tvlog.txt', cDeviceLogStatus)
	SEND_STRING 0, cDeviceLogStatus
    }
}

/*
 * SamsungTVPowerOff function
 *
 * function to power off tv if its powered on
 * write to log file noting tv is turned off at the particular time
 */
DEFINE_FUNCTION SamsungTVPowerOff(){
    SEND_STRING 0, "'Power Off TV'"
    IF (nTvPower = 1){
	SEND_STRING 0, "'To tv power on'"
	TO[dvTvMon, SamsungTV_UN_SERIES_Power]
	//TO[dvTvMon, cSamsungTV_Power_Off]
	nTvPower = 0
	cDeviceLogStatus = "DATE, ' mode:', cDeviceStandby, ' time:', TIME"
	appendToFile('tvlog.txt', cDeviceLogStatus)
	SEND_STRING 0, cDeviceLogStatus
    }
}

/*
 * SamsungHDMI1 function
 *
 * function to change source of tv to HDMI1
 */
DEFINE_FUNCTION SamsungHDMI1(){
    PULSE[dvTvMon, cSamsungTV_HDMI_1]
}

/*
 * SamsungHDMI2 function
 *
 * function to change source of tv to HDMI2
 */
DEFINE_FUNCTION SamsungHDMI2(){
    PULSE[dvTvMon, cSamsungTV_HDMI_2]
}

/*
 * SamsungHDMI3 function
 *
 * function to change source of tv to HDMI3
 */
DEFINE_FUNCTION SamsungHDMI3(){
    PULSE[dvTvMon, cSamsungTV_HDMI_3]
}

/*
 * BluRayPowerOn function
 *
 * function to power on bluray
 * write to log file saying bluray is turned on at the particular time
 */
DEFINE_FUNCTION BluRayPowerOn(){
    IF (nBluRayPower = 0) {
	PULSE[dvDVD_IR, cBluRay_Power]
	nBluRayPower = 1
	cDeviceLogStatus = "DATE, ' mode:', cDeviceInUse, ' time:', TIME"
	SEND_STRING 0, cDeviceLogStatus
	appendToFile('dvdlog.txt', cDeviceLogStatus)
	SEND_COMMAND dvPanel,"'@BMP', cBluRayPoweredStatusBtn, ITOA(nBluRayPower)"
    }
}

/*
 * BluRayPowerOff function
 *
 * function to power off bluray if its powered on
 * write to log file saying bluray is turned off at the particular time
 */
DEFINE_FUNCTION BluRayPowerOff(){
    IF (nBluRayPower = 1) {
	PULSE[dvDVD_IR, cBluRay_Power]
	nBluRayPower = 0
	cDeviceLogStatus = "DATE, ' mode:', cDeviceStandby, ' time:', TIME"
	SEND_STRING 0, cDeviceLogStatus
	appendToFile('dvdlog.txt', cDeviceLogStatus)
	SEND_COMMAND dvPanel,"'@BMP', cBluRayPoweredStatusBtn, ITOA(nBluRayPower)"
    }
}

/*
 * AppleTVPower function
 *
 * function to pulse apple tv to turn on
 * write to log file saying apple tv is turned on at the particular time
 */
DEFINE_FUNCTION AppleTVPower(){
    PULSE[dvAppleTV, cAppleTV_Select_Center]
    cDeviceLogStatus = "DATE, ' mode:', cDeviceInUse, ' time:', TIME"
    SEND_STRING 0, cDeviceLogStatus
    appendToFile('appletvlog.txt', cDeviceLogStatus)
    SEND_COMMAND dvPanel,"'@BMP', cAppleTVPoweredStatusBtn, ITOA(1)"
}

/*
 * SkyPowerOn function
 *
 * function to power on sky
 * write to log file saying sky is turned on at the particular time
 */
DEFINE_FUNCTION SkyPowerOn(){
    IF (nSkyPower = 0) {
	PULSE [dvSKY_IR, cSKY_Power_Toggle]
	nSkyPower = 1
	cDeviceLogStatus = "DATE, ' mode:', cDeviceInUse, ' time:', TIME"
	SEND_STRING 0, cDeviceLogStatus
	appendToFile('skylog.txt', cDeviceLogStatus)
	SEND_COMMAND dvPanel,"'@BMP', cSkyPoweredStatusBtn, ITOA(nSkyPower)"
    }
}

/*
 * SkyPowerOff function
 *
 * function to power off sky if its powered on
 * write to log file saying sky is turned off at the particular time
 */
DEFINE_FUNCTION SkyPowerOff(){
    if (nSkyPower = 1) {
	PULSE[dvSKY_IR, cSKY_Power_Toggle]
	nSkyPower = 0
	cDeviceLogStatus = "DATE, ' mode:', cDeviceStandby, ' time:', TIME"
	SEND_STRING 0, cDeviceLogStatus
	appendToFile('skylog.txt', cDeviceLogStatus)
	SEND_COMMAND dvPanel,"'@BMP', cSkyPoweredStatusBtn, ITOA(nSkyPower)"
    }
}

(***********************************************************)
(*                  THE EVENTS GO BELOW                    *)
(***********************************************************)
DEFINE_EVENT
/*
 * Button event for the video submenu items
 */
BUTTON_EVENT[dvPanel, 0]{
    PUSH: {
	SWITCH(button.input.channel){
	    CASE cNavi_AppleTV: {
		SamsungTVPowerOn()
		AppleTVPower()
		SamsungHDMI1()
		nDeviceOn = 1
	    }
	    CASE cNavi_BluRay: {
		SamsungTVPowerOn()
		BluRayPowerOn()
		SamsungHDMI2()
		nDeviceOn = 2
	    }
	    CASE cNavi_SKY: {
		SamsungTVPowerOn()
		SkyPowerOn()
		SamsungHDMI3()
		nDeviceOn = 3
	    }
	    CASE cNavi_PowerOff: {
		if(nTvPower = 1){
		    SamsungTVPowerOff()
		}
		if(nSkyPower = 1){
		    SkyPowerOff()
		}
		if(nBluRayPower = 1){
		    BluRayPowerOff()
		}
		nDeviceOn = 0
	    }
	}
    }
}

/*
 * Button event for the volume
 */
BUTTON_EVENT[dvPanel, 0]{
    PUSH: {
	SWITCH(button.input.channel){
	    CASE cVolume_Mute_Btn: 
		PULSE [dvTVMon, cSamsungTV_Mute]
	    CASE cVolume_Down_Btn: {
		PULSE [dvTVMon, cSamsungTV_Volume_Down]
	    }
	    CASE cVolume_Up_Btn: {
		PULSE [dvTVMon, cSamsungTV_Volume_Up]
	    }
	}
    }
}

/*
 * Button event for the video gestures
 */
BUTTON_EVENT [dvPanel, 0]{
    PUSH: {
	SWITCH(button.input.channel){
	    CASE nGesture_Up: {
		IF (nDeviceOn = 1){
		    //AppleTV
		    TO[dvAppleTV, cAppleTV_Cursor_Up]
		}
		ELSE IF (nDeviceOn = 2){
		    //Bluray
		    TO[dvDvd_IR, cBluRay_Cursor_UP]
		}
		ELSE IF (nDeviceOn = 3){
		    //Sky
		    TO[dvSKY_IR, cSky_Nav_Up]
		}
		ELSE {
		    //Power off
		}
	    }
	    CASE nGesture_Down: {
		IF (nDeviceOn = 1){
		    //AppleTV
		    TO[dvAppleTV, cAppleTV_Cursor_Down]
		}
		ELSE IF (nDeviceOn = 2){
		    //Bluray
		    TO[dvDvd_IR, cBluRay_Cursor_v]
		}
		ELSE IF (nDeviceOn = 3){
		    //Sky
		    TO[dvSKY_IR, cSky_Nav_Down]
		}
		ELSE {
		    //Power off
		}
	    }
	    CASE nGesture_Left: {
		IF (nDeviceOn = 1){
		    //AppleTV
		    TO[dvAppleTV, cAppleTV_Cursor_Left]
		}
		ELSE IF (nDeviceOn = 2){
		    //Bluray
		    TO[dvDvd_IR, cBluRay_Cursor_REV]
		}
		ELSE IF (nDeviceOn = 3){
		    //Sky
		    TO[dvSKY_IR, cSky_Nav_Left]
		}
		ELSE {
		    //Power off
		}
	    }
	    CASE nGesture_Right: {
		IF (nDeviceOn = 1){
		    //AppleTV
		    TO[dvAppleTV, cAppleTV_Cursor_Right]
		}
		ELSE IF (nDeviceOn = 2){
		    //Bluray
		    TO[dvDvd_IR, cBluRay_Cursor_FWD]
		}
		ELSE IF (nDeviceOn = 3){
		    //Sky
		    TO[dvSKY_IR, cSky_Nav_Right]
		}
		ELSE {
		    //Power off
		}
	    }
	    CASE nCounter_Clockwise: {
		IF (nDeviceOn = 1){
		    //AppleTV
		    TO[dvAppleTV, cAppleTV_Menu]
		}
		ELSE IF (nDeviceOn = 2){
		    //Bluray
		    PULSE[dvDvd_IR, cBluRay_Return]
		}
		ELSE IF (nDeviceOn = 3){
		    //Sky
		    PULSE[dvSky_IR, cSky_Backup]
		}
		ELSE {
		    //Power off
		}
	    }
	    CASE nDouble_Tap: {
		IF (nDeviceOn = 1){
		    //AppleTV
		    TO[dvAppleTV, cAppleTV_PlayPause]
		}
		ELSE IF (nDeviceOn = 2){
		    //Bluray
		    IF (nDvdStatus = PAUSE){
			PULSE[dvDvd_IR, cBluRay_Play]
			nDvdStatus = cBluRay_Play
		    }
		    ELSE {
			PULSE[dvDvd_IR, cBluRay_Pause]
			nDvdStatus = cBluRay_Pause
		    }
		}
		ELSE IF (nDeviceOn = 3){
		    //Sky
		    PULSE[dvSKY_IR, cSky_Select]
		}
		ELSE {
		    //Power off
		}
	    }
	}
    }
}

/*
 * Level event for the volume level
 */
LEVEL_EVENT [dvPanel, cVolume_Level]{
    IF(nVolLevel > level.value)
	PULSE [dvTVMon, cVolume_Down_Btn]
    else
	PULSE [dvTVMon, cVolume_Up_Btn]
}

/*
 * Data event for the tv to set mode to IR and carrier frequency
 */
DATA_EVENT[dvTvMon]{
    ONLINE: {
	SEND_COMMAND dvTvMon, "'SET MODE IR'"
	SEND_COMMAND dvTvMon, "'CARON'"
    }
    ONERROR: {
	SWITCH(DATA.TEXT){
	    CASE 'NO DEVICE':{
		SEND_COMMAND dvTvMon, "'^TXT-500,0, Warning: Wiring problem on IR Port #', dvTvMon.port"
	    }
	}
    }
}
