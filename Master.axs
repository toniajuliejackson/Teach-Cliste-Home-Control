PROGRAM_NAME='Master'
(***********************************************************)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 04/05/2006  AT: 09:00:25        *)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
    $History: $
*)
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE
#include 'FYP Devices.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT
#include 'FYP Constants.axi'
#include 'SNAPI.axi'
(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE
INTEGER nTouchPanelButtons[]	= {
    1,						//FC-CURRENT-TEMP
    2,						//FC-CURRENT-WEATHER-ICON
    3, 						//FC-CURRENT-WEATHER-COND
    4,						//FC-CURRENT-WIND-DIRECTION
    5,						//FC-CURRENT-MOISTURE-CONTENT
    6,						//FC-DATE-RETRIEVED
    7,						//FC-DAY2-ICON
    8,						//FC-DAY2
    9, 						//FC-DAY3-ICON
    10,						//FC-DAY3
    11,						//FC-DAY4-ICON
    12,						//FC-DAY4
    13,						//FC-DAY5-ICON
    14,						//FC-DAY5 
    15						//SYSTEM-LOGS
}

CHAR cBuffer[15000]
CHAR cHueBuffer[15000]
INTEGER nMainMenuItemSelected = 1
INTEGER nConnectionStatus
VOLATILE CHAR cWindDirection
VOLATILE INTEGER nWindDirection
VOLATILE CHAR cWindDirectionPNG[20]
VOLATILE FLOAT fDegrees
VOLATILE DOUBLE dConversion
CHAR cLogs[15000]
INTEGER nVolumeLevel
INTEGER nHueOnline
INTEGER nHueOn
(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)
#include 'FYP Logs.axi'
#include 'FYP Video.axi'
#include 'FYP Lights.axi'
#include 'FYP CCTV.axi'
#include 'FYP AppleTV.axi'
#include 'FYP BluRay.axi'
#include 'FYP SkyReceiver.axi'

/*
 * fnIPConnect function
 *
 * Function to connect to web server
 * Opens the desired port for IP communication with a server
 *
 * Sends String to get the 10 days forecast by geographic coordinates in JSON format
 * GEO. LOCATION OF DUBLIN [ -6.27, 53.34 ]
 * 
 */
DEFINE_FUNCTION fnIPConnect(){
    appendToFile('log.txt','IP Connection to - api.openweathermap.org')
    IP_CLIENT_OPEN(dvIP.port, 'api.openweathermap.org', 80, IP_TCP)
    WAIT 50{
	SEND_STRING dvIP, "'GET /data/2.5/forecast?lat=53&lon=-6 HTTP/1.1',$0D,$0A"
	SEND_STRING dvIP,"'HOST: api.openweathermap.org',$0D,$0A,$0D,$0A"
	
	SEND_STRING 0, "'GET /data/2.5/forecast?lat=53&lon=-6 HTTP/1.1',$0D,$0A"
	SEND_STRING 0,"'HOST: api.openweathermap.org',$0D,$0A,$0D,$0A"
	
    }
    WAIT 70{
	IP_CLIENT_CLOSE(dvIP.port)
    }
}

/*
 * fnIPDisconnect function
 *
 * Calls appendToFile() to log IP Disconnect Connection from api-openweathermap.org
 * Closes Ip Connection
 */
DEFINE_FUNCTION fnIPDisconnect(){
    appendToFile('log.txt','IP Disconnect Connection - api.openweathermap.org')
    IP_CLIENT_CLOSE(dvIP.port)
}

/*
 * ConvertToDegrees function
 * @param nDeg
 *
 * Conversion from kelvin to celcius
 * Outputs result to nTouchPanelButtons[1]
 */
DEFINE_FUNCTION ConvertToDegrees(nDeg){
    fDegrees = nDeg - 273.15
    SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[1],ITOA(fDegrees),$B0"
}

/*
 * DirToBitmap function
 * @param nWindDirection
 *
 * Determines which way the wind is going according to the degrees from the weather fields
 */
DEFINE_FUNCTION DirToBitmap(nWindDirection){
    //NorthEast
    IF (nWindDirection > 22.5 && nWindDirection < 67.5){ 		
	cWindDirectionPNG='wind-direction-ne'
    }
    //East
    ELSE IF (nWindDirection > 67.5 && nWindDirection < 112.5){ 		
	cWindDirectionPNG='wind-direction-e'
    }
    //SouthEast
    ELSE IF (nWindDirection > 112.5 && nWindDirection < 157.5){ 	
	cWindDirectionPNG='wind-direction-se'
    }
    //South
    ELSE IF  (nWindDirection > 157.5 && nWindDirection < 202.5){ 	
	cWindDirectionPNG='wind-direction-s'
    }
    //SouthWest
    ELSE IF (nWindDirection > 202.5 && nWindDirection < 247.5){ 	
	cWindDirectionPNG='wind-direction-sw'
    }
    //West
    ELSE IF (nWindDirection > 247.5 && nWindDirection < 292.5){
	cWindDirectionPNG='wind-direction-w'
    }
    //NorthWest
    ELSE IF (nWindDirection > 292.5 && nWindDirection < 337.6){ 
	cWindDirectionPNG='wind-direction-nw'
    }
    //North
    ELSE { 								
	cWindDirectionPNG='wind-direction-n'
    }
}

/*
 * daysOfWeek function
 *
 * Checks the current day and passes the nTouchPanelButtons[8], nTouchPanelButtons[10], 
 * nTouchPanelButtons[12], nTouchPanelButtons[14] accordingly
 */
DEFINE_FUNCTION daysOfWeek() {
    IF (DAY = 'SUN'){
	SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[8],'mon'"
	SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[10],'tue'"
	SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[12],'wed'"
	SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[14],'thur'"
    } 
    ELSE IF (DAY = 'MON'){
	SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[8],'tue'"
	SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[10],'wed'"
	SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[12],'thur'"
	SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[14],'fri'"
    }
    ELSE IF (DAY = 'TUE'){
	SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[8],'wed'"
	SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[10],'thur'"
	SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[12],'fri'"
	SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[14],'sat'"
    }
    ELSE IF (DAY = 'WED'){
	SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[8],'thur'"
	SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[10],'fri'"
	SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[12],'sat'"
	SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[14],'sun'"
    }
    ELSE IF (DAY = 'THUR'){
	SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[8],'fri'"
	SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[10],'sat'"
	SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[12],'sun'"
	SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[14],'mon'"
    }
    ELSE IF (DAY = 'FRI'){
	SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[8],'sat'"
	SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[10],'sun'"
	SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[12],'mon'"
	SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[14],'tue'"
    }
    ELSE IF (DAY = 'SAT'){
	SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[8],'sun'"
	SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[10],'mon'"
	SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[12],'tue'"
	SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[14],'wed'"
    }
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START
//Own version of data.text
CREATE_BUFFER dvIP, cBuffer
CREATE_BUFFER dvHue, cHueBuffer

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT
/*
 * BUTTON_EVENT
 * PUSH: Checks the button channels for which main menu item was pressed and carries out the appropriate tasks
 */
BUTTON_EVENT[dvPanel, 0]{
    PUSH: {
	SWITCH(button.input.channel){
	    CASE cNavi_Home: {
		nMainMenuItemSelected = 1
		appendToFile('log.txt','Home button was pressed')
		IF(nConnectionStatus == TRUE){
		    fnIPDisconnect()
		}
		ELSE IF (nConnectionStatus == FALSE){
		    fnIPConnect()
		}
	    }
	    CASE cNavi_Video: {
		nMainMenuItemSelected = 2
		appendToFile('log.txt','Video button was pressed')
	    }
	    CASE cNavi_Music: {
		nMainMenuItemSelected = 3
		appendToFile('log.txt','Music button was pressed')
	    }
	    CASE cNavi_Lights: {
		nMainMenuItemSelected = 4
		appendToFile('log.txt','Lights button was pressed')
		fnGetHueStatus()
	    }
	    CASE cNavi_CCTV: {
		nMainMenuItemSelected = 5
		appendToFile('log.txt','CCTV button was pressed')
	    }
	}
    }
}

/*
 * DATA_EVENT for device dvPanel
 *
 * ONLINE	: Sets device to beep when it connects to integrated controller.
		: Sets the default for showing the maximum number of STT results
		: Sets that text to speech can work in offline mode
 * STRING	: Gets speech parses it and finds matches with the cVoiceControl_commands
 */
DATA_EVENT[dvPanel]{
    ONLINE:{
	SEND_COMMAND data.device, "'ADBEEP'"
	SEND_COMMAND data.device, "'TPCCMD-STTDisplayResult,3'"	
	SEND_COMMAND data.device, "'TPCCMD-TTSOfflineMode,true'"
    }
    STRING: {
	STACK_VAR CHAR cTemp[1024]
	STACK_VAR CHAR cVoiceControlText[255]
	STACK_VAR CHAR cVoiceControlText1[255]
	STACK_VAR CHAR cVoiceControlText2[255]
	STACK_VAR INTEGER i
	STACK_VAR INTEGER nVoiceControlMatch
	
	// Echo the response to terminal for debugging
	SEND_STRING dvTerminal, "'D:P:S = ',ITOA(data.device.number),':',ITOA(data.device.port),':',ITOA(data.device.system),' String: ', data.text"
	
	i = FIND_STRING(data.text, 'TPCSTT-', 1)
	
	if (i){
	    cTemp = data.text
	    REMOVE_STRING(cTemp, 'TPCSTT-', 1)
	
	    cVoiceControlText = REMOVE_STRING(cTemp, ';', 1)
	    IF(LENGTH_STRING(cVoiceControlText)){
		SET_LENGTH_STRING(cVoiceControlText, LENGTH_STRING(cVoiceControlText) - 1)
	    }
    
	    cVoiceControlText1 = REMOVE_STRING(cTemp, ';', 1)
	    IF(LENGTH_STRING(cVoiceControlText1)){
		SET_LENGTH_STRING(cVoiceControlText1, LENGTH_STRING(cVoiceControlText1) - 1)
	    }
	
	    cVoiceControlText2 = cTemp
	    IF (RIGHT_STRING(cVoiceControlText2, 1) = ';'){
		cVoiceControlText2 = LEFT_STRING(cVoiceControlText2, (LENGTH_STRING(cVoiceControlText2) - 1))
	    }
       
	    nVoiceControlMatch = 0
	    FOR (i = 1; i <= MAX_LENGTH_ARRAY(cVoiceControl_commands); i++){
		IF ((cVoiceControlText1 = cVoiceControl_commands[i]) || (cVoiceControlText1 = cVoiceControl_commands[i]) || (cVoiceControlText2 = cVoiceControl_commands[i])){
		    nVoiceControlMatch = i
		    BREAK
		}
	    }
	
	    SEND_STRING dvTerminal, "'nVoiceControlMatch: ',ITOA(nVoiceControlMatch)"
	    SWITCH (nVoiceControlMatch){
		CASE 0:{ 
		    SEND_STRING dvTerminal, "'VoiceControl: No match'" 
		}
		
		// DVD PLAYER ON
		CASE 1:
		CASE 2:
		CASE 3:
		CASE 4:{
		    SEND_STRING dvTerminal, "'VoiceControl: match case 1, 2, 3, 4'"
		    SEND_COMMAND data.device, "'TPCTTS-The bluray dvd player is now on;En'"
		    PULSE[dvDvd_IR, cBluRay_Power]
		    nBluRayPower = 1
		}
		// DVD PLAYER OFF
		CASE 5:
		CASE 6:
		CASE 7:
		CASE 8:{
		    SEND_STRING dvTerminal, "'VoiceControl: match case 5, 6, 7, 8'"
		    SEND_COMMAND data.device, "'TPCTTS-The bluray dvd player is now off;En'"
		    PULSE[dvDvd_IR, cBluRay_Power]
		    nBluRayPower = 0
		}
		CASE 9:
		CASE 10: {
		    SEND_STRING dvTerminal, "'VoiceControl: match case 9, 10'"
		    SEND_COMMAND data.device, "'TPCTTS-The DVD is now playing;En'"
		    PULSE[dvDvd_IR, cBluRay_Play]
		    nDvdStatus = cBluRay_Play
		}
		CASE 11:
		CASE 12: {
		    SEND_STRING dvTerminal, "'VoiceControl: match case 11, 12'"
		    SEND_COMMAND data.device, "'TPCTTS-The DVD is now paused;En'"
		    PULSE[dvDvd_IR, cBluRay_Pause]
		    nDvdStatus = cBluRay_Pause
		}
		CASE 13:
		CASE 14: {
		    SEND_STRING dvTerminal, "'VoiceControl: match case 13, 14'"
		    SEND_COMMAND data.device, "'TPCTTS-The DVD is now stopped;En'"
		    PULSE[dvDvd_IR, cBluRay_Stop]
		    nDvdStatus = cBluRay_Stop
		}
		CASE 15:
		CASE 16: {
		    SEND_STRING dvTerminal, "'VoiceControl: match case 15, 16'"
		    SEND_COMMAND data.device, "'TPCTTS-The DVD title menu is now showing;En'"
		    PULSE[dvDvd_IR, cBluRay_Title_Menu_Popup]
		}
		CASE 17:
		CASE 18: {
		    SEND_STRING dvTerminal, "'VoiceControl: match case 17, 18'"
		    SEND_COMMAND data.device, "'TPCTTS-The DVD disc menu is now showing;En'"
		    PULSE[dvDvd_IR, cBluRay_Disc_Menu]
		}
		CASE 19: 
		CASE 20: {
		    SEND_STRING dvTerminal, "'VoiceControl: match case 19, 20'"
		    SEND_COMMAND data.device, "'TPCTTS-DVD up;En'"
		    PULSE[dvDvd_IR, cBluRay_Cursor_UP]
		}
		CASE 21: 
		CASE 22: {
		    SEND_STRING dvTerminal, "'VoiceControl: match case 21, 22'"
		    SEND_COMMAND data.device, "'TPCTTS-DVD down;En'"
		    PULSE[dvDvd_IR, cBluRay_Cursor_v]
		}
		CASE 23: 
		CASE 24: {
		    SEND_STRING dvTerminal, "'VoiceControl: match case 23, 24'"
		    SEND_COMMAND data.device, "'TPCTTS-DVD left;En'"
		    PULSE[dvDvd_IR, cBluRay_Cursor_REV]
		}
		CASE 25: 
		CASE 26: {
		    SEND_STRING dvTerminal, "'VoiceControl: match case 25, 26'"
		    SEND_COMMAND data.device, "'TPCTTS-DVD right;En'"
		    PULSE[dvDvd_IR, cBluRay_Cursor_FWD]
		}
		CASE 27: 
		CASE 28: {
		    SEND_STRING dvTerminal, "'VoiceControl: match case 27, 28'"
		    SEND_COMMAND data.device, "'TPCTTS-DVD select;En'"
		    PULSE[dvDvd_IR, cBluRay_Select]
		}
		CASE 29:
		CASE 30:
		CASE 31: {
		    SEND_STRING dvTerminal, "'VoiceControl: match case 29, 30, 31'"
		    SEND_COMMAND data.device, "'TPCTTS-The Apple TV is turned on;En'"
		    PULSE[dvAppleTV, cAppleTV_Select_Center]
		}
		CASE 32:
		CASE 33: {
		    SEND_STRING dvTerminal, "'VoiceControl: match case 32, 33'"
		    SEND_COMMAND data.device, "'TPCTTS-Apple Tv up;En'"
		    PULSE[dvAppleTV, cAppleTV_Cursor_Up]
		}
		CASE 34:
		CASE 35: {
		    SEND_STRING dvTerminal, "'VoiceControl: match case 34, 35'"
		    SEND_COMMAND data.device, "'TPCTTS-Apple Tv down;En'"
		    PULSE[dvAppleTV, cAppleTV_Cursor_Down]
		}
		CASE 36:
		CASE 37: {
		    SEND_STRING dvTerminal, "'VoiceControl: match case 36, 37'"
		    SEND_COMMAND data.device, "'TPCTTS-Apple Tv left;En'"
		    PULSE[dvAppleTV, cAppleTV_Cursor_Left]
		}
		CASE 38:
		CASE 39: {
		    SEND_STRING dvTerminal, "'VoiceControl: match case 38, 39'"
		    SEND_COMMAND data.device, "'TPCTTS-Apple Tv right;En'"
		    PULSE[dvAppleTV, cAppleTV_Cursor_Right]
		}
		CASE 40:
		CASE 41:
		CASE 42:
		CASE 43:
		CASE 44:
		CASE 45: {
		    SEND_STRING dvTerminal, "'VoiceControl: match case 40, 41, 42, 43, 44, 45'"
		    SEND_COMMAND data.device, "'TPCTTS-Apple Tv play pause;En'"
		    PULSE[dvAppleTV, cAppleTV_PlayPause]
		}
		CASE 46:
		CASE 47:
		CASE 48:
		CASE 49: {
		    SEND_STRING dvTerminal, "'VoiceControl: match case 46, 47, 48, 49'"
		    SEND_COMMAND data.device, "'TPCTTS-Apple Tv select;En'"
		    PULSE[dvAppleTV, cAppleTV_Select_Center]
		}
		CASE 50:
		CASE 51: {
		    SEND_STRING dvTerminal, "'VoiceControl: match case 50, 51'"
		    SEND_COMMAND data.device, "'TPCTTS- Lighting On;En'"
		    IP_CLIENT_OPEN(dvHue.PORT, '192.168.110.100', 80, IP_TCP)
		    fnLightingOn()
		    SEND_COMMAND dvPanel,"'@BMP',cHueOn,'1'"
		}
		CASE 52: 
		CASE 53: {
		    SEND_STRING dvTerminal, "'VoiceControl: match case 52, 53'"
		    SEND_COMMAND data.device, "'TPCTTS- Lighting Off;En'"
		    IP_CLIENT_OPEN(dvHue.PORT, '192.168.110.100', 80, IP_TCP)
		    fnLightingOff()
		    SEND_COMMAND dvPanel,"'@BMP',cHueOn,'0'"
		}
		CASE 54:
		CASE 55: {
		    SEND_STRING dvTerminal, "'VoiceControl: match case 54, 55'"
		    SEND_COMMAND data.device, "'TPCTTS- Lighting Scene Wake Up;En'"
		    IP_CLIENT_OPEN(dvHue.PORT, '192.168.110.100', 80, IP_TCP)
		    fnWakeUpLighting()
		    SEND_COMMAND dvPanel,"'@BMP',cHueOn,'1'"
		}
		CASE 56:
		CASE 57: {
		    SEND_STRING dvTerminal, "'VoiceControl: match case 56, 57'"
		    SEND_COMMAND data.device, "'TPCTTS- Lighting Scene Movie Night;En'"
		    IP_CLIENT_OPEN(dvHue.PORT, '192.168.110.100', 80, IP_TCP)
		    fnMovieNightLighting()
		    SEND_COMMAND dvPanel,"'@BMP',cHueOn,'1'"
		}
		CASE 58:
		CASE 59: {
		    SEND_STRING dvTerminal, "'VoiceControl: match case 58, 59'"
		    SEND_COMMAND data.device, "'TPCTTS- Lighting Scene Reading;En'"
		    IP_CLIENT_OPEN(dvHue.PORT, '192.168.110.100', 80, IP_TCP)
		    fnReadingLighting()
		    SEND_COMMAND dvPanel,"'@BMP',cHueOn,'1'"
		}
		CASE 60:
		CASE 61: {
		    SEND_STRING dvTerminal, "'VoiceControl: match case 60, 61'"
		    SEND_COMMAND data.device, "'TPCTTS- Lighting Scene Good Night;En'"
		    IP_CLIENT_OPEN(dvHue.PORT, '192.168.110.100', 80, IP_TCP)
		    fnGoodnightLighting()
		    SEND_COMMAND dvPanel,"'@BMP',cHueOn,'0'"
		}
	    }
	}
    }
}

/*
 * DATA_EVENT for device dvIP
 *
 * ONLINE	: IP Connection Established 
 * OFFLINE	: IP Connection Terminated
 * ONERROR	: IP Connection Error
 * STRING	: Find strings in the buffer and removes desired string to variables
 * 		  Results are displayed on the panel buttons
 */
DATA_EVENT[dvIP]{
    ONLINE:{
	nConnectionStatus = TRUE
	SEND_STRING 0,"'***TRACE*** IP CONNECTION ESTABLISHED'"
	SEND_COMMAND dvPanel, "'^TXT-50,0,ONLINE'"
    }
    OFFLINE:{
	nConnectionStatus = FALSE
	SEND_STRING 0,"'***TRACE*** IP CONNECTION TERMINATED'"
	SEND_COMMAND dvPanel, "'^TXT-50,0,OFFLINE'"
    }
    ONERROR:{
	SEND_STRING 0,"'***TRACE*** IP CONNECTION ERROR'"
	SWITCH (DATA.NUMBER) {
	    CASE 0:
		SEND_STRING dvTerminal, "";
	    CASE 2:
		SEND_STRING dvTerminal, "'IP ERROR (',ITOA(DATA.NUMBER),'): General Failure (IP_CLIENT_OPEN/IP_SERVER_OPEN)'";
	    CASE 4:
		SEND_STRING dvTerminal, "'IP ERROR (',ITOA(DATA.NUMBER),'): unknown host or DNS error (IP_CLIENT_OPEN)'";
	    CASE 6:
		SEND_STRING dvTerminal, "'IP ERROR (',ITOA(DATA.NUMBER),'): connection refused (IP_CLIENT_OPEN)'";
	    CASE 7:
		SEND_STRING dvTerminal, "'IP ERROR (',ITOA(DATA.NUMBER),'): connection timed out (IP_CLIENT_OPEN)'";
	    CASE 8:
		SEND_STRING dvTerminal, "'IP ERROR (',ITOA(DATA.NUMBER),'): unknown connection error (IP_CLIENT_OPEN)'";
	    CASE 14:
		SEND_STRING dvTerminal, "'IP ERROR (',ITOA(DATA.NUMBER),'): local port already used (IP_CLIENT_OPEN/IP_SERVER_OPEN)'";
	    CASE 16:
		SEND_STRING dvTerminal, "'IP ERROR (',ITOA(DATA.NUMBER),'): too many open sockets (IP_CLIENT_OPEN/IP_SERVER_OPEN)'";
	    CASE 10:
		SEND_STRING dvTerminal, "'IP ERROR (',ITOA(DATA.NUMBER),'): Binding error (IP_SERVER_OPEN)'";
	    CASE 11:
		SEND_STRING dvTerminal, "'IP ERROR (',ITOA(DATA.NUMBER),'): Listening error (IP_SERVER_OPEN)'";
	    CASE 15:
		SEND_STRING dvTerminal, "'IP ERROR (',ITOA(DATA.NUMBER),'): UDP socket already listening (IP_SERVER_OPEN)'";
	    CASE 9:
		SEND_STRING dvTerminal, "'IP ERROR (',ITOA(DATA.NUMBER),'): Already closed (IP_CLIENT_CLOSE/IP_SERVER_CLOSE)'";
	    CASE 17:
		SEND_STRING dvTerminal, "'IP ERROR (',ITOA(DATA.NUMBER),'): Local port not open, can not send string (IP_CLIENT_OPEN)'";	
	    DEFAULT:
		SEND_STRING dvTerminal, "'IP ERROR (',ITOA(DATA.NUMBER),'): Unknown'";
	}
    }
    STRING:{
	LOCAL_VAR CHAR cForecastDate[50]
	LOCAL_VAR CHAR cCity[100]
	LOCAL_VAR CHAR cCountry[100]
	LOCAL_VAR CHAR cDayTemp[5]
	LOCAL_VAR INTEGER cTodayTemp[1]
	LOCAL_VAR CHAR cHumidity[5]
	LOCAL_VAR CHAR cWeatherCond[100]
	LOCAL_VAR CHAR cIcon[5]
	LOCAL_VAR CHAR cIcon2[5]
	LOCAL_VAR CHAR cIcon3[5]
	LOCAL_VAR CHAR cIcon4[5]
	LOCAL_VAR CHAR cIcon5[5]
	LOCAL_VAR CHAR cDeg[5]
	LOCAL_VAR CHAR cX[5]
	LOCAL_VAR CHAR cDate1[13]
	LOCAL_VAR CHAR cDate2[12]
	LOCAL_VAR CHAR cDate2Icon[5]
	LOCAL_VAR CHAR cDate3[15]
	LOCAL_VAR CHAR cDate3Icon[5]
	LOCAL_VAR CHAR cDate4[15]
	LOCAL_VAR CHAR cDate4Icon[5]
	LOCAL_VAR CHAR cDate5[15]
	LOCAL_VAR CHAR cDate5Icon[5]
	LOCAL_VAR INTEGER Find
	
	SELECT{
	    ACTIVE(FIND_STRING(cBuffer, 'Date: ', 1)):{
		REMOVE_STRING(cBuffer, 'Date: ', 1)
		cForecastDate = REMOVE_STRING(cBuffer, 'GMT',1)
		SET_LENGTH_STRING(cForecastDate, LENGTH_STRING(cForecastDate)-3)
		SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[6],cForecastDate"
		
		REMOVE_STRING(cBuffer, '"name":"', 1)
		cCity = REMOVE_STRING(cBuffer, '",',1)
		SET_LENGTH_STRING(cCity, LENGTH_STRING(cCity)-2)
		//Set the length of a CHAR or WIDECHAR string.
		//This function is retained for compatibility with previous versions of NetLinx. 
		//It provides the same functionality as SET_LENGTH_ARRAY.
		
		REMOVE_STRING(cBuffer, '"country":"', 1)
		cCountry = REMOVE_STRING(cBuffer, '",',1)
		SET_LENGTH_STRING(cCountry, LENGTH_STRING(cCountry)-2)
		
		REMOVE_STRING(cBuffer, '"temp_min":', 1)
		cDayTemp = REMOVE_STRING(cBuffer, ',',1)
		SET_LENGTH_STRING(cDayTemp, LENGTH_STRING(cDayTemp)-1)
		ConvertToDegrees(ATOI(cDayTemp))
		
		REMOVE_STRING(cBuffer, '"humidity":', 1)
		cHumidity = REMOVE_STRING(cBuffer, ',',1)
		SET_LENGTH_STRING(cHumidity, LENGTH_STRING(cHumidity)-1)
		SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[5],cHumidity,'%'"
		
		REMOVE_STRING(cBuffer, '"description":"', 1)
		cWeatherCond = REMOVE_STRING(cBuffer, '",',1)
		SET_LENGTH_STRING(cWeatherCond, LENGTH_STRING(cWeatherCond)-2)
		SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[3],cWeatherCond"
		
		REMOVE_STRING(cBuffer, '"deg":', 1)
		cDeg = REMOVE_STRING(cBuffer, ',',1)
		SET_LENGTH_STRING(cDeg, LENGTH_STRING(cDeg)-1)
		DirToBitmap(ATOI(cDeg))
		SEND_STRING 0,"'@BMP',nTouchPanelButtons[4],cWindDirectionPNG"
		SEND_COMMAND dvPanelAddPort5,"'@BMP',nTouchPanelButtons[4],cWindDirectionPNG"
		
		REMOVE_STRING(cBuffer, '"icon":"', 1)
		cIcon = REMOVE_STRING(cBuffer, '",',1)
		SET_LENGTH_STRING(cIcon, LENGTH_STRING(cIcon)-2)
		SEND_COMMAND dvPanelAddPort5,"'@BMP',nTouchPanelButtons[2],cIcon"
		SEND_STRING 0, "'Days of Week'"
		daysOfWeek()
		SEND_STRING 0, "'Days of Week END'"
	
		//DAY 2
		find = FIND_STRING(cBuffer, '"dt_txt":"', 1)
		REMOVE_STRING(cBuffer, '"dt_txt":"', 1)
		cDate2 = REMOVE_STRING(cBuffer, '12:00:00"},',1)
		SET_LENGTH_STRING(cDate2, LENGTH_STRING(cDate2)-2)
		
		FIND_STRING(cBuffer, '"icon":"', 1)
		REMOVE_STRING(cBuffer, '"icon":"', 1)
		cDate2Icon = REMOVE_STRING(cBuffer, '",',1)
		SET_LENGTH_STRING(cDate2Icon, LENGTH_STRING(cDate2Icon)-2)
		SEND_STRING 0, "cDate2Icon"
		SEND_COMMAND dvPanelAddPort5,"'@BMP',nTouchPanelButtons[7],cDate2Icon"*/
		
		//DAY 3
		REMOVE_STRING(cBuffer, '"dt_txt":"', 1)
		cDate3 = REMOVE_STRING(cBuffer, '00:00:00",',1)
		SET_LENGTH_STRING(cDate3, LENGTH_STRING(cDate3)-2)
		REMOVE_STRING(cBuffer, '"icon":"', 1)
		cDate3Icon = REMOVE_STRING(cBuffer, '",',1)
		SET_LENGTH_STRING(cDate3Icon, LENGTH_STRING(cDate3Icon)-2)
		SEND_COMMAND dvPanelAddPort5,"'@BMP',nTouchPanelButtons[9],cDate3Icon"
		
		//DAY 4
		REMOVE_STRING(cBuffer, '"dt_txt":"', 1)
		cDate4 = REMOVE_STRING(cBuffer, '00:00:00",',1)
		SET_LENGTH_STRING(cDate4, LENGTH_STRING(cDate4)-2)
		REMOVE_STRING(cBuffer, '"icon":"', 1)
		cDate4Icon = REMOVE_STRING(cBuffer, '",',1)
		SET_LENGTH_STRING(cDate4Icon, LENGTH_STRING(cDate4Icon)-2)
		SEND_COMMAND dvPanelAddPort5,"'@BMP',nTouchPanelButtons[11],cDate4Icon"
		
		//DAY 5
		REMOVE_STRING(cBuffer, '"dt_txt":"', 1)
		cDate5 = REMOVE_STRING(cBuffer, '00:00:00",',1)
		SET_LENGTH_STRING(cDate5, LENGTH_STRING(cDate5)-2)
		REMOVE_STRING(cBuffer, '"icon":"', 1)
		cDate5Icon = REMOVE_STRING(cBuffer, '",',1)
		SET_LENGTH_STRING(cDate5Icon, LENGTH_STRING(cDate5Icon)-2)
		SEND_COMMAND dvPanelAddPort5,"'@BMP',nTouchPanelButtons[13],cDate5Icon"
	    }
	}
    }
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
