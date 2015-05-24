PROGRAM_NAME='FYP Devices'
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE
dvTerminal			= 0:1:1
dvPanel 			= 11001:1:1 	//IPAD MINI RETINA DISPLAY
dvPanelAddPort5			= 11001:5:1	//IPAD MINI RETINA DISPLAY ADDRESS PORT 5

//IR
dvDVD_IR			= 5001:11:1	//SAMSUNG BD-F5100 BLU-RAY DISC
dvAppleTV 			= 5001:13:1	//APPLETV SETTOP
dvTvMon				= 5001:16:1	//SAMSUNG TV MONITOR IR PORT
dvSKY_IR			= 5001:15:1	//SKY RECEIVER IR PORT

dvSKY_RS 			= 5001:1:1	//SKY RECEIVER RS-232 PORT
//vdvHUE1			= 33101:1:1	//VIRTUAL DEVICE

//Relays
dvBlinds			= 5001:21:1	//MOTORISED BLINDS

//IP DEVICES
dvIP 				= 0:4:0		//ETHERNET PORT
dvHue				= 0:5:0		//PHILIPS HUE BULBS
dvCCTV				= 0:6:0		//WEB CAMERA - RASPBERRY PI
