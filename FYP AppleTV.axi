PROGRAM_NAME='FYP AppleTV'
(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE
INTEGER nAppleTVPlayPause

(***********************************************************)
(*                  THE EVENTS GO BELOW                    *)
(***********************************************************)
DEFINE_EVENT
/*
 * Button Event for apple tv control buttons
 */
BUTTON_EVENT[dvPanel, 0]{
    PUSH: {
	SWITCH(button.input.channel){
	    CASE cAppleTV_PlayPause_Btn: {
		IF (nAppleTVPlayPause = PLAY){
		   TO[dvAppleTV, cAppleTV_PlayPause]
		    nAppleTVPlayPause = PAUSE
		}
		ELSE {
		    TO[dvAppleTV, cAppleTV_PlayPause]
		    nAppleTVPlayPause = PLAY
		}
	    }
	    CASE cAppleTV_Menu_Btn: {
		TO[dvAppleTV, cAppleTV_Menu]
	    }
	    CASE cAppleTV_Cursor_Up_Btn: {
		TO[dvAppleTV, cAppleTV_Cursor_Up]
	    }
	    CASE cAppleTV_Cursor_Down_Btn: {
		TO[dvAppleTV, cAppleTV_Cursor_Down]
	    }
	    CASE cAppleTV_Cursor_Left_Btn: {
		TO[dvAppleTV, cAppleTV_Cursor_Left]
	    }
	    CASE cAppleTV_Cursor_Right_Btn: {
		TO[dvAppleTV, cAppleTV_Cursor_Right]
	    }
	    CASE cAppleTV_Select_Center_Btn: {
		TO[dvAppleTV, cAppleTV_Select_Center]
	    }
	}
    }
}

/*
 * Data event for the apple tv to set mode to IR and carrier frequency
 */
DATA_EVENT[dvAppleTV]{
    ONLINE: {
	SEND_COMMAND dvAppleTV, "'SET MODE IR'"
	SEND_COMMAND dvAppleTV, "'CARON'"
    }
    ONERROR: {
	SWITCH(DATA.TEXT){
	    CASE 'NO DEVICE':{
		SEND_COMMAND dvAppleTV, "'^TXT-500,0, Warning: Wiring problem on IR Port #', dvAppleTV.port"
	    }
	}
    }
}
