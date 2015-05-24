PROGRAM_NAME='FYP Lights'

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE
sTEMP[1000]
INTEGER nOnline
INTEGER nBriLevel
INTEGER nHueLevel
INTEGER nSatLevel
INTEGER nBri
INTEGER nHue
INTEGER nSat
INTEGER nBlindPosition

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)

/*
 * fnGetHueStatus function
 *
 * Opens ip connection with tcp utilising port 80 to hue server
 * Sends a get http call 
 */
DEFINE_FUNCTION fnGetHueStatus(){
    IP_CLIENT_OPEN(dvHue.PORT, cIPAddressPhilipsHue, 80, IP_TCP)
    wait 10 {
	IF(nHueOnline = TRUE) {
	    SEND_STRING dvHue, "'GET /api/amxtesting/lights/1 HTTP/1.1',13,10"
	    SEND_STRING dvHue, "' HOST: ', cIPAddressPhilipsHue,13,10,13,10"
	}
	ELSE {
	    SEND_STRING dvTerminal, "'HueOnline false'"
	}
    }
}

/*
 * fnIPDisconnectHUE function
 *
 * terminates the ip connection with server via ip_client_close 
 */
DEFINE_FUNCTION fnIPDisconnectHUE(){
    nOnline = FALSE
    SEND_STRING 0,  "'FNC DISCONNECT HUE'"
    appendToFile('iplog.txt','IP connection disconnect from philips hue')
    IP_CLIENT_CLOSE(dvHue.port)
}

/*
 * fnWakeUpLighting function
 *
 * sends a put request specifing the elements of wake up lighting scene
 * Brightness = 100, saturation = 44, hue = 33849
 */
DEFINE_FUNCTION CHAR[800] fnWakeUpLighting(){
    SEND_STRING dvTerminal, "'fnWakeUpLighting'"
    WAIT 10 {
	IF(nHueOnline = TRUE){
	    SEND_STRING dvTerminal, "'fnWakeUpLighting TRUE'"
	    SEND_STRING dvHue, "'PUT /api/amxtesting/lights/1/state HTTP/1.1',13,10"
	    SEND_STRING dvHue, "'Host: ', cIPAddressPhilipsHue,13,10"
	    SEND_STRING dvHue, "'Content-Type: application/x-www-form-urlencoded',13,10"
	    SEND_STRING dvHue, "'Content-Length: 42',13,10,13,10"
	    SEND_STRING dvHue, "'{"hue":33849,"sat":44,"bri":100,"on":true}',13,10"
	    SEND_LEVEL dvPanel, 2, 100
	    SEND_LEVEL dvPanel, 3, 33849
	    SEND_LEVEL dvPanel, 4, 44
	    SEND_COMMAND dvPanel,"'@BMP',cHueOn,'1'"
	    nHueOn = TRUE
	}
	else {
	    SEND_STRING dvTerminal, "'fnWakeUpLighting FALSE'"
	}
    }
}

/*
 * fnMovieNightLighting function
 *
 * sends a put request specifing the elements of movie night lighting scene
 * Brightness = 93, saturation = 255, hue = 47185
 */
DEFINE_FUNCTION CHAR[800] fnMovieNightLighting(){
    WAIT 10 {
	IF(nHueOnline = TRUE){
	    SEND_STRING dvTerminal, "'fnMovieNightLighting TRUE'"
	    SEND_STRING dvHue, "'PUT /api/amxtesting/lights/1/state HTTP/1.1',13,10"
	    SEND_STRING dvHue, "'Host: ', cIPAddressPhilipsHue,13,10"
	    SEND_STRING dvHue, "'Content-Type: application/x-www-form-urlencoded',13,10"
	    SEND_STRING dvHue, "'Content-Length: 42',13,10,13,10"
	    SEND_STRING dvHue, "'{"hue":47185,"sat":255,"bri":93,"on":true}',13,10"
	    SEND_LEVEL dvPanel, 2, 93
	    SEND_LEVEL dvPanel, 3, 47185
	    SEND_LEVEL dvPanel, 4, 255
	    SEND_COMMAND dvPanel,"'@BMP',cHueOn,'1'"
	    nHueOn = TRUE
	}
	else {
	    SEND_STRING dvTerminal, "'fnMovieNightLighting FALSE'"
	}
    }
}

/*
 * fnReadingLighting function
 *
 * sends a put request specifing the elements of reading lighting scene
 * Brightness = 255, saturation = 44, hue = 33849
 */
DEFINE_FUNCTION CHAR[800] fnReadingLighting(){
    WAIT 10 {
	IF(nHueOnline = TRUE){
	    SEND_STRING dvTerminal, "'fnReadingLighting TRUE'"
	    SEND_STRING dvHue, "'PUT /api/amxtesting/lights/1/state HTTP/1.1',13,10"
	    SEND_STRING dvHue, "'Host: ', cIPAddressPhilipsHue,13,10"
	    SEND_STRING dvHue, "'Content-Type: application/x-www-form-urlencoded',13,10"
	    SEND_STRING dvHue, "'Content-Length: 42',13,10,13,10"
	    SEND_STRING dvHue, "'{"hue":33849,"sat":44,"bri":255,"on":true}',13,10"
	    SEND_LEVEL dvPanel, 2, 255
	    SEND_LEVEL dvPanel, 3, 33849
	    SEND_LEVEL dvPanel, 4, 44
	    SEND_COMMAND dvPanel,"'@BMP',cHueOn,'1'"
	    nHueOn = TRUE
	}
	else {
	    SEND_STRING dvTerminal, "'fnReadingLighting FALSE'"
	}
    }
}

/*
 * fnGoodnightLighting function
 *
 * sends a put request specifing the elements of goodnight lighting scene
 * setting on = false
 */
DEFINE_FUNCTION CHAR[800] fnGoodnightLighting(){
    //appendToFile('log.txt','Good night lighting scene selected')
    WAIT 10 {
	IF(nHueOnline = TRUE){
	    SEND_STRING dvTerminal, "'fnGoodnightLighting TRUE'"
	    SEND_STRING dvHue, "'PUT /api/amxtesting/lights/1/state HTTP/1.1',13,10"
	    SEND_STRING dvHue, "'Host: ', cIPAddressPhilipsHue,13,10"
	    SEND_STRING dvHue, "'Content-Type: application/x-www-form-urlencoded',13,10"
	    SEND_STRING dvHue, "'Content-Length: 12',13,10,13,10"
	    SEND_STRING dvHue, "'{"on":false}',13,10"
	    SEND_LEVEL dvPanel, 2, 0
	    SEND_LEVEL dvPanel, 3, 0
	    SEND_LEVEL dvPanel, 4, 0
	    SEND_COMMAND dvPanel,"'@BMP',cHueOn,'0'"
	    nHueOn = FALSE
	}
	else {
	    SEND_STRING dvTerminal, "'fnGoodnightLighting FALSE'"
	}
    }
}

/*
 * fnLightingOn function
 *
 * sends a put request specifing the lights to power on
 * setting on = true
 */
DEFINE_FUNCTION CHAR[800] fnLightingOn(){
     WAIT 10 {
	IF(nHueOnline = TRUE){
	    SEND_STRING dvTerminal, "'fnLightingOn TRUE'"
	    SEND_STRING dvHue, "'PUT /api/amxtesting/lights/1/state HTTP/1.1',13,10"
	    SEND_STRING dvHue, "'Host: ', cIPAddressPhilipsHue,13,10"
	    SEND_STRING dvHue, "'Content-Type: application/x-www-form-urlencoded',13,10"
	    SEND_STRING dvHue, "'Content-Length: 11',13,10,13,10"
	    SEND_STRING dvHue, "'{"on":true}',13,10"
	    SEND_COMMAND dvPanel,"'@BMP',cHueOn, cDeviceOn"
	    nHueOn = TRUE
	}
	else {
	    SEND_STRING dvTerminal, "'fnLightingOn FALSE'"
	}
    }
}

/*
 * fnLightingOff function
 *
 * sends a put request specifing the lights to power off
 * setting on = false
 */
DEFINE_FUNCTION CHAR[800] fnLightingOff(){
     WAIT 10 {
	IF(nHueOnline = TRUE){
	    SEND_STRING dvTerminal, "'fnLightingOff TRUE'"
	    SEND_STRING dvHue, "'PUT /api/amxtesting/lights/1/state HTTP/1.1',13,10"
	    SEND_STRING dvHue, "'Host: ', cIPAddressPhilipsHue,13,10"
	    SEND_STRING dvHue, "'Content-Type: application/x-www-form-urlencoded',13,10"
	    SEND_STRING dvHue, "'Content-Length: 12',13,10,13,10"
	    SEND_STRING dvHue, "'{"on":false}',13,10"
	    SEND_LEVEL dvPanel, 2, 0
	    SEND_LEVEL dvPanel, 3, 0
	    SEND_LEVEL dvPanel, 4, 0
	    SEND_COMMAND dvPanel,"'@BMP',cHueOn, cDeviceOff"
	    nHueOn = FALSE
	}
	else {
	    SEND_STRING dvTerminal, "'fnLightingOff FALSE'"
	}
    }
}

/*
 * fnCustom function
 *
 * sends a put request specifing the lights to specified level values
 */
DEFINE_FUNCTION CHAR[800] fnCustom(){
    WAIT 10 {
	IF(nHueOnline = TRUE){
	    SEND_STRING dvHue, "'PUT /api/amxtesting/lights/1/state HTTP/1.1',13,10"
	    SEND_STRING dvHue, "'Host: ', cIPAddressPhilipsHue,13,10"
	    SEND_STRING dvHue, "'Content-Type: application/x-www-form-urlencoded',13,10"
	    SEND_STRING dvHue, "'Content-Length: 42',13,10,13,10"
	    SEND_STRING dvHue, "'{"hue":',ITOA(nHueLevel),',"sat":',ITOA(nSatLevel),',"bri":',ITOA(nBriLevel),',"on":true}',13,10"
	    SEND_STRING dvTerminal, "'{"hue":' ,ITOA(nHueLevel) , ',"sat":' , ITOA(nSatLevel) , ',"bri":' , ITOA(nBriLevel) , ',"on":true}',13,10"
	    nHueOn = TRUE
	}
    }
}

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT
/*
 * Button event for lights sub menu items
 */
BUTTON_EVENT[dvPanel, 0]{
    PUSH: {
	SWITCH(button.input.channel){
	    CASE cNavi_wakeUpBtn:{
		IP_CLIENT_OPEN(dvHue.PORT, cIPAddressPhilipsHue, 80, IP_TCP)
		fnWakeUpLighting()
		SEND_COMMAND dvPanelAddPort5, "'@BMP', 15,'true'"
	    }
	    CASE cNavi_movieNightBtn:{
		IP_CLIENT_OPEN(dvHue.PORT, cIPAddressPhilipsHue, 80, IP_TCP)
		fnMovieNightLighting()
		SEND_COMMAND dvPanelAddPort5, "'@BMP', 15,'true'"
	    }
	    CASE cNavi_readingBtn:{
		IP_CLIENT_OPEN(dvHue.PORT, cIPAddressPhilipsHue, 80, IP_TCP)
		fnReadingLighting()
		SEND_COMMAND dvPanelAddPort5, "'@BMP', 15,'true'"
	    }
	    CASE cNavi_goodNightBtn:{
		IP_CLIENT_OPEN(dvHue.PORT, cIPAddressPhilipsHue, 80, IP_TCP)
		fnGoodnightLighting()
		SEND_COMMAND dvPanelAddPort5, "'@BMP', 15,'false'"
	    }
	    CASE cHueOn: {
		IF (nHueOn = FALSE){
		    IP_CLIENT_OPEN(dvHue.PORT, cIPAddressPhilipsHue, 80, IP_TCP)
		    fnLightingOn()
		    SEND_COMMAND dvPanel,"'@BMP',cHueOn,'1'"
		}
		ELSE {
		    IP_CLIENT_OPEN(dvHue.PORT, cIPAddressPhilipsHue, 80, IP_TCP)
		    fnLightingOff()
		    SEND_COMMAND dvPanel,"'@BMP',cHueOn,'0'"
		}
	    }
	    CASE cCustom: {
		IP_CLIENT_OPEN(dvHue.PORT, cIPAddressPhilipsHue, 80, IP_TCP)
		fnCustom()
		SEND_COMMAND dvPanel,"'@BMP',cHueOn,'1'"
		SEND_COMMAND dvPanelAddPort5, "'@BMP', 15,'true'"
	    }
	    CASE cBlindOpen: {
		SEND_STRING 0, 'Blinds Open'
		ON[dvBlinds, nblind_open_position]
		WAIT 50{
		    OFF[dvBlinds, nblind_open_position]
		}
		nBlindPosition = 0
		SEND_LEVEL dvPanel, 10, nBlindPosition
	    }
	    CASE cBlindClose:{
		SEND_STRING 0, 'Blinds Close'

		ON[dvBlinds, nblind_close_position]
		WAIT 50 {
		    OFF[dvBlinds, nblind_close_position]
		}
		nBlindPosition = 100
		SEND_LEVEL dvPanel, 10, nBlindPosition
	    }
	}
    }
}

/*
 * LEVEL_EVENT for device dvPanel, level 2 (brightness)
 */
LEVEL_EVENT[dvPanel, 2]{
	nBriLevel = level.value
}

/*
 * LEVEL_EVENT for device dvPanel, level 3 (hue)
 */
LEVEL_EVENT[dvPanel, 3]{
    nHueLevel = level.value
}

/*
 * LEVEL_EVENT for device dvPanel, level 4 (saturation)
 */
LEVEL_EVENT[dvPanel, 4]{
    nSatLevel = level.value
}

/*
 * LEVEL_EVENT for device dvPanel, level 10 (blinds)
 */
LEVEL_EVENT[dvPanel, 10]{
    IF (level.value = 0){
	ON[dvBlinds, nblind_close_position]
	WAIT 50 {
	    OFF[dvBlinds, nblind_close_position]
	}
	nBlindPosition = 0
	SEND_LEVEL dvPanel, 10, nBlindPosition
    }
    ELSE IF (level.value >= 10){
	IF (level.value >= nBlindPosition){
	    ON[dvBlinds, nblind_close_position]
	    WAIT level.value {
		OFF[dvBlinds, nblind_close_position]
	    }
	    nBlindPosition = level.value
	}
	ELSE {
	    ON[dvBlinds, nblind_open_position]
	    WAIT level.value {
		OFF[dvBlinds, nblind_open_position]
	    }
	    nBlindPosition = level.value
	}
    }
    ELSE IF (level.value >= 20){
	IF (level.value >= nBlindPosition){
	    ON[dvBlinds, nblind_close_position]
	    WAIT level.value {
		OFF[dvBlinds, nblind_close_position]
	    }
	    nBlindPosition = level.value
	}
	ELSE {
	    ON[dvBlinds, nblind_open_position]
	    WAIT level.value {
		OFF[dvBlinds, nblind_open_position]
	    }
	    nBlindPosition = level.value
	}
    }
    ELSE IF (level.value >= 30){
	IF (level.value >= nBlindPosition){
	    ON[dvBlinds, nblind_close_position]
	    WAIT level.value {
		OFF[dvBlinds, nblind_close_position]
	    }
	    nBlindPosition = level.value
	}
	ELSE {
	    ON[dvBlinds, nblind_open_position]
	    WAIT level.value {
		OFF[dvBlinds, nblind_open_position]
	    }
	    nBlindPosition = level.value
	}
    }
    ELSE IF (level.value >= 40){
	IF (level.value >= nBlindPosition){
	    ON[dvBlinds, nblind_close_position]
	    WAIT level.value {
		OFF[dvBlinds, nblind_close_position]
	    }
	    nBlindPosition = level.value
	}
	ELSE {
	    ON[dvBlinds, nblind_open_position]
	    WAIT level.value {
		OFF[dvBlinds, nblind_open_position]
	    }
	    nBlindPosition = level.value
	}
    }
    ELSE IF (level.value >= 50){
	IF (level.value >= nBlindPosition){
	    ON[dvBlinds, nblind_close_position]
	    WAIT level.value {
		OFF[dvBlinds, nblind_close_position]
	    }
	    nBlindPosition = level.value
	}
	ELSE {
	    ON[dvBlinds, nblind_open_position]
	    WAIT level.value {
		OFF[dvBlinds, nblind_open_position]
	    }
	    nBlindPosition = level.value
	}
    }
    ELSE IF (level.value >= 60){
	IF (level.value >= nBlindPosition){
	    ON[dvBlinds, nblind_close_position]
	    WAIT level.value {
		OFF[dvBlinds, nblind_close_position]
	    }
	    nBlindPosition = level.value
	}
	ELSE {
	    ON[dvBlinds, nblind_open_position]
	    WAIT level.value {
		OFF[dvBlinds, nblind_open_position]
	    }
	    nBlindPosition = level.value
	}
    }
    ELSE IF (level.value >= 70){
	IF (level.value >= nBlindPosition){
	    ON[dvBlinds, nblind_close_position]
	    WAIT level.value {
		OFF[dvBlinds, nblind_close_position]
	    }
	    nBlindPosition = level.value
	}
	ELSE {
	    ON[dvBlinds, nblind_open_position]
	    WAIT level.value {
		OFF[dvBlinds, nblind_open_position]
	    }
	    nBlindPosition = level.value
	}
    }
    ELSE IF (level.value >= 80){
	IF (level.value >= nBlindPosition){
	    ON[dvBlinds, nblind_close_position]
	    WAIT level.value {
		OFF[dvBlinds, nblind_close_position]
	    }
	    nBlindPosition = level.value
	}
	ELSE {
	    ON[dvBlinds, nblind_open_position]
	    WAIT level.value {
		OFF[dvBlinds, nblind_open_position]
	    }
	    nBlindPosition = level.value
	}
    }
    ELSE IF (level.value >= 90){
	IF (level.value >= nBlindPosition){
	    ON[dvBlinds, nblind_close_position]
	    WAIT level.value {
		OFF[dvBlinds, nblind_close_position]
	    }
	    nBlindPosition = level.value
	}
	ELSE {
	    ON[dvBlinds, nblind_open_position]
	    WAIT level.value {
		OFF[dvBlinds, nblind_open_position]
	    }
	    nBlindPosition = level.value
	}
    }
    ELSE {
	IF (level.value >= nBlindPosition){
	    ON[dvBlinds, nblind_close_position]
	    WAIT level.value {
		OFF[dvBlinds, nblind_close_position]
	    }
	    nBlindPosition = level.value
	}
	ELSE {
	    ON[dvBlinds, nblind_open_position]
	    WAIT level.value {
		OFF[dvBlinds, nblind_open_position]
	    }
	    nBlindPosition = level.value
	}
    }
}

/*
 * DATA_EVENT for device dvHue
 *
 * ONLINE	: Get the lights current status (GET RESTful request)
 * ONERROR	: Gets the error number and determines which error belongs
 * STRING	: Gets speech parses the returned data
 */
DATA_EVENT[dvHue]{
    ONLINE:{
	nHueOnline = TRUE
    }
    OFFLINE:{
	nHueOnline = FALSE
    }
    ONERROR: {
	nHueOnline = FALSE
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
	LOCAL_VAR CHAR cStatusTEST[160000]
	LOCAL_VAR CHAR cStatus[6]
	LOCAL_VAR CHAR cBri[10]
	LOCAL_VAR CHAR cHue[10]
	LOCAL_VAR CHAR cSat[10]
	
	SEND_STRING dvTerminal, cHueBuffer
	SELECT{
	    ACTIVE(FIND_STRING(cHueBuffer, '{"state": ', 1)):{
		REMOVE_STRING(cHueBuffer, '"on":', 1)
		cStatus = REMOVE_STRING(cHueBuffer, ',',1)
		SET_LENGTH_STRING(cStatus, LENGTH_STRING(cStatus)-1)
		IF (COMPARE_STRING(cStatus, 'true')){
		    nHueOn = TRUE
		    SEND_COMMAND dvPanelAddPort5, "'@BMP', 15, 'true'"
		    cDeviceLogStatus = "DATE, ' mode:', cDeviceInUse, ' time:', TIME"
		    SEND_STRING 0, cDeviceLogStatus
		    appendToFile('huelog.txt', cDeviceLogStatus)
		}
		ELSE {
		    nHueON = FALSE
		    SEND_COMMAND dvPanelAddPort5, "'@BMP', 15,'false'"
		    cDeviceLogStatus = "DATE, ' mode:', cDeviceStandby, ' time:', TIME"
		    SEND_STRING 0, cDeviceLogStatus
		    appendToFile('huelog.txt', cDeviceLogStatus)
		}
	
		REMOVE_STRING(cHueBuffer, '"bri":', 1)
		cBri = REMOVE_STRING(cHueBuffer, ',',1)
		SET_LENGTH_STRING(cBri, LENGTH_STRING(cBri)-1)
		SEND_LEVEL dvPanel, 2, ATOI(cBri)
		
		REMOVE_STRING(cHueBuffer, '"hue":', 1)
		cHue = REMOVE_STRING(cHueBuffer, ',',1)
		SET_LENGTH_STRING(cHue, LENGTH_STRING(cHue)-1)
		SEND_LEVEL dvPanel, 3, ATOI(cHue)
		
		REMOVE_STRING(cHueBuffer, '"sat":', 1)
		cSat = REMOVE_STRING(cHueBuffer, ',',1)
		SET_LENGTH_STRING(cSat, LENGTH_STRING(cSat)-1)
		SEND_LEVEL dvPanel, 4, ATOI(cSat)
	    }
	}
    }
}
