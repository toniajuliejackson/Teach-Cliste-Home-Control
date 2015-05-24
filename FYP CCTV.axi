PROGRAM_NAME='FYP CCTV'
(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)

DEFINE_FUNCTION fnLoadSnapshots(){
    
}

DEFINE_FUNCTION fnTakeSnapshot(){
    
}
(***********************************************************)
(*                  THE EVENTS GO BELOW                    *)
(***********************************************************)
DEFINE_EVENT
BUTTON_EVENT[dvPanel, 0]{
    PUSH: {
	SWITCH(button.input.channel){
	    CASE cCamera_Photos_Btn: {
		fnLoadSnapshots()
	    }
	    CASE cCamera_Snapshot_Btn: {
		fnTakeSnapshot()
	    }
	}
    }
}
