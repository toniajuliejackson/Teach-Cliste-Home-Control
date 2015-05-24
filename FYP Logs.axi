PROGRAM_NAME='FYP Logs'

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE
SLONG slFileHandle
INTEGER nEnergyConsumption_Device_Label[] = {
    102,
    103,
    104,
    105,
    106
}

INTEGER nIn_Use_Level[] = {
    5,
    6,
    7,
    8,
    9
}
INTEGER i
INTEGER x = 1
CHAR cTime[500][50]
CHAR cInUseTimeToday[10]
CHAR cStandbyTimeToday[10]
LONG nInUseTimeTodaySecs
LONG nStandbyTimeTodaySecs
INTEGER nAppleTVFileHandle
INTEGER nDvdFileHandle
INTEGER nSkyFileHandle
INTEGER nTvFileHandle
INTEGER nHueFileHandle

DOUBLE nStandbySecs
DOUBLE nInUseSecs
DOUBLE nStandbySecsCost
DOUBLE nInUseSecsCost
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
   slFileHandle = FILE_OPEN(cFileName,FILE_RW_APPEND)   
   IF(slFileHandle>0) {
	slResult = FILE_WRITE_LINE(slFileHandle,cLogString,LENGTH_STRING(cLogString))
	FILE_CLOSE(slFileHandle)
    }           
    ELSE{
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
    STACK_VAR SLONG slFileHandle    
    LOCAL_VAR SLONG slResult        
    STACK_VAR CHAR  oneline[2000]    
    STACK_VAR INTEGER INC
    
    nStandbySecs = 0
    nInUseSecs = 0
    nStandbySecsCost = 0
    nInUseSecsCost = 0
    
    SEND_STRING 0, "'standby : ', ITOA(nStandbySecs), ' inuse : ', ITOA(nInUseSecs)"
    slFileHandle = FILE_OPEN(cFileName,FILE_READ_ONLY)

    IF(slFileHandle>0){
	slResult = 1
	WHILE(slResult>0){
            slResult = FILE_READ_LINE(slFileHandle,oneline,MAX_LENGTH_STRING(oneline))
            parseLineFromFile(oneline)
	}
	FILE_CLOSE(slFileHandle)
	x = 1
    }           
    ELSE{
	SEND_STRING 0,"'FILE OPEN ERROR:',ITOA(slFileHandle)" 
    }
}

/*
 * readStuffFromFile function
 * @param aLine
 * 
 * Takes line passed in and parse line searching for the following;
 * 1. 'mode:'
 * 2. 'time:'
 */
DEFINE_FUNCTION parseLineFromFile(CHAR aLine[]) {
    STACK_VAR INTEGER nFindToday
    STACK_VAR INTEGER nMode
    STACK_VAR INTEGER y
    STACK_VAR DOUBLE fTime1Hour 
    STACK_VAR DOUBLE fTime1Min 	
    STACK_VAR DOUBLE fTime1Sec 
    STACK_VAR DOUBLE fTime2Hour
    STACK_VAR DOUBLE fTime2Min 
    STACK_VAR DOUBLE fTime2Sec
    STACK_VAR DOUBLE lTimeInSecs1
    STACK_VAR DOUBLE lTimeInSecs2 
    STACK_VAR DOUBLE lTimeSecs
    STACK_VAR DOUBLE lTimeMin
    STACK_VAR DOUBLE lTimeHr
    
    STACK_VAR DOUBLE dHourCount
    STACK_VAR DOUBLE dMinsCount
    STACK_VAR DOUBLE dSecCount

    y = x - 1
    
    nFindToday = FIND_STRING(aLine, DATE, 1)
    IF (nFindToday > 0){
	//SEND_STRING 0, 'Data found'
	//SEND_STRING 0 , "aLine"
	
	nMode = FIND_STRING(aLine, 'mode:standby', 1)
	IF (nMode > 0){
	    //SEND_STRING 0, 'Standby'
	    REMOVE_STRING(aLine, 'time:', 1)
	    //SEND_STRING 0 , "aLine"
	    cTime[x] = aLine
	    //Implementation below
	    IF (x <= 1){
		//SEND_STRING 0, 'if statement'
		fTime1Hour 		= TIME_TO_HOUR ('00:00:00')
		fTime1Min 		= TIME_TO_MINUTE ('00:00:00')
		fTime1Sec 		= TIME_TO_SECOND ('00:00:00')
		lTimeInSecs1 		= ((fTime1Hour*3600) + (fTime1Min * 60) + (fTime1Sec))
		//SEND_STRING 0, "'TIME IN SECS 1 ', FTOA(lTimeInSecs1)"
		
		fTime2Hour 		= TIME_TO_HOUR (cTime[x])
		fTime2Min 		= TIME_TO_MINUTE (cTime[x])
		fTime2Sec 		= TIME_TO_SECOND (cTime[x])
		lTimeInSecs2 		= ((fTime2Hour*3600) + (fTime2Min * 60) + (fTime2Sec))
		//SEND_STRING 0, "'TIME IN SECS 2 ', FTOA(lTimeInSecs2)"
	    
		lTimeHr = (lTimeInSecs1 - lTimeInSecs2)	
		//SEND_STRING 0, "'*************************OVERALL TIME IN SECONDS ', FTOA(lTimeHr)"
		lTimeHr = abs_value(lTimeHr)
		dMinsCount = lTimeHr / 60
		dSecCount = lTimeHr % 60
		
		dHourCount = dMinsCount / 60
		dMinsCount = dMinsCount % 60
		//SEND_STRING 0, "'*************************OVERALL TIME Hour ', FTOA(dHourCount) ,',Mins ',FTOA(dMinsCount),',Secs ',FTOA(dSecCount)"
	    }
	    ELSE {
		//SEND_STRING 0, 'else statement'
		fTime1Hour 		= TIME_TO_HOUR (cTime[y])
		fTime1Min 		= TIME_TO_MINUTE (cTime[y])
		fTime1Sec 		= TIME_TO_SECOND (cTime[y])
		lTimeInSecs1 		= ((fTime1Hour*3600) + (fTime1Min * 60) + (fTime1Sec))
		//SEND_STRING 0, "'TIME IN SECS 1 ', FTOA(lTimeInSecs1)"
		
		fTime2Hour 		= TIME_TO_HOUR (cTime[x])
		fTime2Min 		= TIME_TO_MINUTE (cTime[x])
		fTime2Sec 		= TIME_TO_SECOND (cTime[x])
		lTimeInSecs2 		= ((fTime2Hour*3600) + (fTime2Min * 60) + (fTime2Sec))
		//SEND_STRING 0, "'TIME IN SECS 2 ', FTOA(lTimeInSecs2)"
	    
		lTimeHr = (lTimeInSecs1 - lTimeInSecs2)	
		//SEND_STRING 0, "'*************************OVERALL TIME IN SECONDS ', FTOA(lTimeHr)"
		lTimeHr = abs_value(lTimeHr)
		dMinsCount = lTimeHr / 60
		dSecCount = lTimeHr % 60
		
		dHourCount = dMinsCount / 60
		dMinsCount = dMinsCount % 60
		//SEND_STRING 0, "'*************************OVERALL TIME Hour ',FTOA(dHourCount) ,',Mins ',FTOA(dMinsCount),',Secs ',FTOA(dSecCount)"
	    }
	    nInUseSecs = nInUseSecs + lTimeHr
	}
	ELSE {
	    //SEND_STRING 0, 'In Use'
	    REMOVE_STRING(aLine, 'time:', 1)
	    SEND_STRING 0 , "aLine"
	    cTime[x] = aLine
	    IF (x <= 1){
		//SEND_STRING 0, 'if statement'
		fTime1Hour 		= TIME_TO_HOUR ('00:00:00')
		fTime1Min 		= TIME_TO_MINUTE ('00:00:00')
		fTime1Sec 		= TIME_TO_SECOND ('00:00:00')
		lTimeInSecs1 		= ((fTime1Hour*3600) + (fTime1Min * 60) + (fTime1Sec))
		//SEND_STRING 0, "'TIME IN SECS 1 ', FTOA(lTimeInSecs1)"
		
		fTime2Hour 		= TIME_TO_HOUR (cTime[x])
		fTime2Min 		= TIME_TO_MINUTE (cTime[x])
		fTime2Sec 		= TIME_TO_SECOND (cTime[x])
		lTimeInSecs2 		= ((fTime2Hour*3600) + (fTime2Min * 60) + (fTime2Sec))
		//SEND_STRING 0, "'TIME IN SECS 2 ', FTOA(lTimeInSecs2)"
	    
		lTimeHr = (lTimeInSecs1 - lTimeInSecs2)	
		//SEND_STRING 0, "'*************************OVERALL TIME IN SECONDS ', FTOA(lTimeHr)"
		lTimeHr = abs_value(lTimeHr)
		dMinsCount = lTimeHr / 60
		dSecCount = lTimeHr % 60
		
		dHourCount = dMinsCount / 60
		dMinsCount = dMinsCount % 60
		//SEND_STRING 0, "'*************************OVERALL TIME Hour ', FTOA(dHourCount) ,',Mins ',FTOA(dMinsCount),',Secs ',FTOA(dSecCount)"
	    }
	    ELSE {
		//SEND_STRING 0, 'else statement'
		fTime1Hour 		= TIME_TO_HOUR (cTime[y])
		fTime1Min 		= TIME_TO_MINUTE (cTime[y])
		fTime1Sec 		= TIME_TO_SECOND (cTime[y])
		lTimeInSecs1 		= ((fTime1Hour*3600) + (fTime1Min * 60) + (fTime1Sec))
		//SEND_STRING 0, "'TIME IN SECS 1 ', FTOA(lTimeInSecs1)"
		
		fTime2Hour 		= TIME_TO_HOUR (cTime[x])
		fTime2Min 		= TIME_TO_MINUTE (cTime[x])
		fTime2Sec 		= TIME_TO_SECOND (cTime[x])
		lTimeInSecs2 		= ((fTime2Hour*3600) + (fTime2Min * 60) + (fTime2Sec))
		//SEND_STRING 0, "'TIME IN SECS 2 ', FTOA(lTimeInSecs2)"
	    
		lTimeHr = (lTimeInSecs1 - lTimeInSecs2)	
		//SEND_STRING 0, "'*************************OVERALL TIME IN SECONDS ', FTOA(lTimeHr)"
		lTimeHr = abs_value(lTimeHr)
		dMinsCount = lTimeHr / 60
		dSecCount = lTimeHr % 60
		
		dHourCount = dMinsCount / 60
		dMinsCount = dMinsCount % 60
		//SEND_STRING 0, "'*************************OVERALL TIME Hour ',FTOA(dHourCount) ,',Mins ',FTOA(dMinsCount),',Secs ',FTOA(dSecCount)"	    }
	    }
	    SEND_STRING 0, "'Standby secs ', ITOA(nStandbySecs)"

	    nStandbySecs = nStandbySecs + lTimeHr
	    x = x + 1
	}
    }
}    

(***********************************************************)
(*                  THE EVENTS GO BELOW                    *)
(***********************************************************)
DEFINE_EVENT
/*
 * Button event for logs button
 */
BUTTON_EVENT[dvPanel, 0]{
    PUSH: {
	SWITCH(button.input.channel){
	    CASE cLogsBtn: {
		SEND_STRING 0, '*****************************************APPLETV'
		nAppleTVFileHandle = FILE_OPEN('appletvlog.txt',FILE_READ_ONLY)
		IF (nAppleTVFileHandle = 1) {
		    readStuffFromFile('appletvlog.txt')
		    //SEND_LEVEL dvPanel, nIn_Use_Level[1], nStandbySecs
		    
		    SEND_STRING 0, "'APPLE TV IN USE TIME ***', FTOA(nStandbySecs)"
		    nStandbySecsCost = ((nStandbySecs / 60) * nAppleTV_InUse_KWH) * nRate
		    SEND_STRING 0, "'APPLE TV IN USE TIME COST ***', FTOA(nStandbySecsCost)"
		}
		ELSE
		    //SEND_LEVEL dvPanel, nIn_Use_Level[1], 0
		FILE_CLOSE(nAppleTVFileHandle)
		
		SEND_STRING 0, '*****************************************DVD'
		nDvdFileHandle = FILE_OPEN('dvdlog.txt',FILE_READ_ONLY)
		IF (nDvdFileHandle = 1) {
		    readStuffFromFile('dvdlog.txt')
		    //SEND_LEVEL dvPanel, nIn_Use_Level[2], nInUseSecs
		    
		    SEND_STRING 0, "'DVD STANDBY TIME ***', FTOA(nStandbySecs)"
		    nStandbySecsCost = ((nStandbySecs / 60) * nDVD_Standby_KWH) * nRate
		    SEND_STRING 0, "'((', FTOA(nStandbySecs), '/ 60) * ', FTOA(nDVD_Standby_KWH), ' * ', FTOA(nRate)"
		    SEND_STRING 0, "'DVD STANDBY TIME COST ***', FTOA(nStandbySecsCost)"
		    SEND_STRING 0, "'DVD IN USE TIME ***', FTOA(nInUseSecs)"
		    nInUseSecsCost = ((nInUseSecs / 60) * nDVD_InUse_KWH) * nRate
		    SEND_STRING 0, "'DVD IN USE TIME COST ***', FTOA(nInUseSecsCost)"
		}
		ELSE
		   // SEND_LEVEL dvPanel, nIn_Use_Level[2], 0
		FILE_CLOSE(nDvdFileHandle)
		
		SEND_STRING 0, '*****************************************SKY'
		nSkyFileHandle = FILE_OPEN('skylog.txt',FILE_READ_ONLY)
		IF (nSkyFileHandle = 1) {
		    readStuffFromFile('skylog.txt')
		    SEND_STRING 0, "'SKY IN USE TIME ***', FTOA(nInUseSecs)"
		    //SEND_LEVEL dvPanel, nIn_Use_Level[3], nInUseSecs
		}
		ELSE
		    //SEND_LEVEL dvPanel, nIn_Use_Level[3], 0
		FILE_CLOSE(nDvdFileHandle)

		SEND_STRING 0, '*****************************************TV'
		nTvFileHandle = FILE_OPEN('tvlog.txt',FILE_READ_ONLY)
		if (nTvFileHandle = 1) {
		    readStuffFromFile('tvlog.txt')
		    SEND_STRING 0, "'TV IN USE TIME ***', ITOA(nInUseSecs)"
		    //SEND_LEVEL dvPanel, nIn_Use_Level[4], nInUseSecs
		}
		ELSE
		    //SEND_LEVEL dvPanel, nIn_Use_Level[4], 0
		FILE_CLOSE(nTvFileHandle)
		
		SEND_STRING 0, '*****************************************HUE'
		nHueFileHandle = FILE_OPEN('huelog.txt',FILE_READ_ONLY)
		IF (nHueFileHandle = 1) {
		    readStuffFromFile('huelog.txt')
		    SEND_STRING 0, "'HUE IN USE TIME ***', ITOA(nInUseSecs)"
		    //SEND_LEVEL dvPanel, nIn_Use_Level[5], nInUseSecs
		}
		ELSE
		    //SEND_LEVEL dvPanel, nIn_Use_Level[5], 0
		FILE_CLOSE(nHueFileHandle)
		SEND_LEVEL dvPanel, nIn_Use_Level[1], 1000
		SEND_LEVEL dvPanel, nIn_Use_Level[2], 2000
		SEND_LEVEL dvPanel, nIn_Use_Level[3], 0
		SEND_LEVEL dvPanel, nIn_Use_Level[4], 4000
		SEND_LEVEL dvPanel, nIn_Use_Level[5], 4000
	    }
	}	
    }
}
