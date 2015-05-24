PROGRAM_NAME='FYP Device Energy Consumption'

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE
INTEGER nEnergyConsumption_Time_Label[] = {
    102,
    103,
    104,
    105,
    106,
    107,
    108,
    109,
    110,
    111
}

INTEGER nEnergyConsumption_Level[] = {
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14
}
CHAR cTime[10]
INTEGER cPrice[10]

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)
/*
 * appendToFile function
 * @param cFileName, cLogString
 * 
 * Stores a tage to represent the file or the returned error code (slFileHandle)
 * Number of bytes written stored or the returned error code (slResult)
 * Opens old file or creates a new one if it doesnt exist
 * slFileHandler will be a positive number if the file is successfully opened
 * FILE_WRITE_LINE is called to write to the file and then it is closed
 * If the log file could not be created an error string will be returned
 */
DEFINE_FUNCTION appendToFile (CHAR cFileName[],CHAR cLogString[]){
   STACK_VAR SLONG slFileHandle
   LOCAL_VAR SLONG slResult
   
   LOCAL_VAR CHAR cTimestampLog
   //cTimestampLog = "DATE, cLogString"
   
   slFileHandle = FILE_OPEN(cFileName,FILE_RW_APPEND)   
   IF(slFileHandle>0){
	slResult = FILE_WRITE_LINE(slFileHandle,cLogString,LENGTH_STRING(cLogString))
	FILE_CLOSE(slFileHandle)
    }           
    ELSE {
	SEND_STRING 0,"'FILE OPEN ERROR:',ITOA(slFileHandle)"    
    }
}

/*
 * readStuffFromFile function
 * @param cFileName
 * 
 * Stores a tag to represent the file or the returned error code (slFileHandle)
 * Number of bytes written stored or the returned error code (slResult)
 * Buffer is utilised to reading one line at a time (oneline[2000])
 * The file is opened from the begining, if successful a slFileHandle will be a positive number
 * A FILE_READ_LINE is carried out to pull a individual line
 * Outputs the line to the nTouchPanelButtons[15]
 * Closes the file
 */
DEFINE_FUNCTION readStuffFromFile(CHAR cFileName[]){
    SEND_STRING 0, "'Read stuff'"
    STACK_VAR SLONG slFileHandle
    LOCAL_VAR SLONG slResult
    STACK_VAR CHAR  oneline[2000]
    slFileHandle = FILE_OPEN(cFileName,FILE_READ_ONLY)

    IF(slFileHandle>0) {
	slResult = 1
	WHILE(slResult>0){
	    SEND_STRING 0, "'loop'"
	    slResult = FILE_READ_LINE(slFileHandle,oneline,MAX_LENGTH_STRING(oneline))
	    SEND_STRING 0, slResult
	    //cLogs = "cLogs,13,10, oneline"
	}
	//SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[15],cLogs"
	FILE_CLOSE(slFileHandle)
    }           
    ELSE {
	SEND_STRING 0,"'FILE OPEN ERROR:',ITOA(slFileHandle)"
	//SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[15],'FILE OPEN ERROR:',ITOA(slFileHandle)"
    }
}

/*
 * deleteLogFile function
 * @param cFileName
 * 
 * Deletes log file
 */
DEFINE_FUNCTION deleteLogFile(CHAR cFileName[]){
    LOCAL_VAR SLONG slResult
    slResult = FILE_DELETE(cFileName)
    //SEND_COMMAND dvPanelAddPort5,"'!T',nTouchPanelButtons[15],'<logs>'"
}

DEFINE_FUNCTION fnAppleTVLog(){
    
}

DEFINE_FUNCTION fnSkyReceiverLog(){
    
}

DEFINE_FUNCTION fnDVDPlayerLog(){
}

DEFINE_FUNCTION fnPhilipsHueLog(){
    
}

DEFINE_FUNCTION fnEnergyConsumptionGrid() {
    for (i = 0; i <= 10; i++){
	SEND_COMMAND dvPanel,"'!T', nEnergyConsumption_Time_Label[i], cTime[i]"
	SEND_LEVEL dvPanel, nEnergyConsumption_Level[1], cPrice[i]
    }
}

(***********************************************************)
(*                 STARTUP CODE GOES BELOW                 *)
(***********************************************************)
DEFINE_START

(***********************************************************)
(*                  THE EVENTS GO BELOW                    *)
(***********************************************************)
DEFINE_EVENT
BUTTON_EVENT[dvPanel, 0]{
    PUSH: {
	SWITCH(button.input.channel){
	    CASE cEnergyConsumption_apple_tv: {
		
	    }
	    CASE cEnergyConsumption_dvd: {
		readStuffFromFile('dvdlog.txt')
	    }
	    CASE cEnergyConsumption_sky: {
		
	    }
	    CASE cEnergyConsumption_hue: {
		
	    }
	}	
    }
}
