PROGRAM_NAME='FYP BluRay'
(***********************************************************)
(*                  THE EVENTS GO BELOW                    *)
(***********************************************************)
DEFINE_EVENT
/*
 * Button event for the dvd user interface controls
 */
BUTTON_EVENT[dvPanel, 0]{
    PUSH: {
	SWITCH(button.input.channel){
	    CASE cBluRay_Play_Btn: {
		IF (nDvdStatus = PAUSE){
		    PULSE[dvDvd_IR, cBluRay_Play]
		    nDvdStatus = cBluRay_Play
		}
		ELSE {
		    PULSE[dvDvd_IR, cBluRay_Pause]
		    nDvdStatus = cBluRay_Pause
		}
	    }
	    CASE cBluRay_Stop_Btn: {
		PULSE[dvDvd_IR, cBluRay_Stop]
	    }
	    CASE cBluRay_FastForward_Btn: { 
		TO[dvDvd_IR, cBluRay_FastForward]
	    }
	    CASE cBluRay_FastReverse_Btn: {
		TO[dvDvd_IR, cBluRay_FastReverse]
	    }
	    CASE cBluRay_SFastForward_Btn: {
		TO[dvDvd_IR, cBluRay_SFastForward]
	    }
	    CASE cBluRay_SFastReverse_Btn: {
		TO[dvDvd_IR, cBluRay_SFastReverse]
	    }
	    CASE cBluRay_Cursor_UP_Btn: {
		TO[dvDvd_IR, cBluRay_Cursor_UP]
	    }
	    CASE cBluRay_Cursor_v_Btn: {
		TO[dvDvd_IR, cBluRay_Cursor_v]
	    }
	    CASE cBluRay_Cursor_REV_Btn: {
		TO[dvDvd_IR, cBluRay_Cursor_REV]
	    }
	    CASE cBluRay_Cursor_FWD_Btn: {
		TO[dvDvd_IR, cBluRay_Cursor_FWD]
	    }
	    CASE cBluRay_Select_Btn: {
		PULSE[dvDvd_IR, cBluRay_Select]
	    }
	     CASE cBluRay_Title_Menu_Popup_BTN: {
		TO[dvDvd_IR, cBluRay_Title_Menu_Popup]
	    }
	    CASE cBluRay_Return_Btn: {
		PULSE[dvDvd_IR, cBluRay_Return]
	    }
	     CASE cBluRay_Disc_Menu_Btn: {
		PULSE[dvDvd_IR, cBluRay_Disc_Menu]
	    }
	    CASE cBluRay_Info_Btn: {
		PULSE[dvDvd_IR, cBluRay_Info]
	    }
	}
    }
}

/*
 * Data event for the dvd to set mode to IR and carrier frequency
 */
DATA_EVENT[dvDvd_IR]{
    ONLINE: {
	// Send a command to the IR Port to tell it to use IR for communication.
	// This port can also be utilised for one way serial. 
	SEND_COMMAND dvDvd_IR, "'SET MODE IR'"
	// Turn on the carrier frequency.
	SEND_COMMAND dvDvd_IR, "'CARON'"
    }
    ONERROR: {
	SWITCH(DATA.TEXT){
	    CASE 'NO DEVICE':{
		appendToFile('log.txt','Warning: Wiring problem on IR Port #11')
		SEND_COMMAND dvAppleTV, "'^TXT-500,0, Warning: Wiring problem on IR Port #', dvDVD_IR.port"
	    }
	}
    }
}
