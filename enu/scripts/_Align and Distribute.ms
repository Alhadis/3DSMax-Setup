try(destroyDialog alignAndDist;)catch();

global alignAndDist;
rollout alignAndDist "Align and Distribute" width:263 height:16(
	local icons		=	"AAN.bmp";
	
	button alignTop		""		tooltip:"Align Top"						pos:[0,0]	width:22 height:17	border:false	images:#(icons,undefined,24,1,1,2,2,true)
	button alignVCen	""		tooltip:"Align Vertical Centres"		pos:[22,0]	width:22 height:17	border:false	images:#(icons,undefined,24,3,3,4,4,true)
	button alignBot		""		tooltip:"Align Bottom"					pos:[44,0]	width:22 height:17	border:false	images:#(icons,undefined,24,5,5,6,6,true)
	button alignLeft	""		tooltip:"Align Left"					pos:[66,0]	width:22 height:17	border:false	images:#(icons,undefined,24,7,7,8,8,true)
	button alignHCen	""		tooltip:"Align Horizontal Centres"		pos:[88,0]	width:22 height:17	border:false	images:#(icons,undefined,24,9,9,10,10,true)
	button alignRght	""		tooltip:"Align Right"					pos:[110,0]	width:22 height:17	border:false	images:#(icons,undefined,24,11,11,12,12,true)
	button distTop		""		tooltip:"Distribute Top"				pos:[132,0]	width:22 height:17	border:false	images:#(icons,undefined,24,13,13,14,14,true)
	button distVCen		""		tooltip:"Distribute Vertical Centres"	pos:[154,0]	width:22 height:17	border:false	images:#(icons,undefined,24,15,15,16,16,true)
	button distBot		""		tooltip:"Distribute Bottom"				pos:[176,0]	width:22 height:17	border:false	images:#(icons,undefined,24,17,17,18,18,true)
	button distLeft		""		tooltip:"Distribute Left"				pos:[198,0]	width:22 height:17	border:false	images:#(icons,undefined,24,19,19,20,20,true)
	button distHCen		""		tooltip:"Distribute Horizontal Centres"	pos:[220,0] width:22 height:17	border:false	images:#(icons,undefined,24,21,21,22,22,true)
	button distRght		""		tooltip:"Distribute Right"				pos:[242,0] width:22 height:17	border:false	images:#(icons,undefined,24,23,23,24,24,true)
	local btns	=	#(alignTop, alignVCen, alignBot, alignLeft, alignHCen, alignRght, distTop, distVCen, distBot, distLeft, distHCen, distRght);

	fn init = (
		for i = 1 to btns.count do(
			local index		=	(i*2)-1
			btns[i].images	=	#(icons,undefined,24,index,index,index+1,index+1,true,true);
		)
	)
	on alignAndDist open do init();
)

createDialog alignAndDist style:#(#style_toolwindow);
cui.RegisterDialogBar alignAndDist minSize:0 maxSize:-1 style:#(#cui_dock_all, #cui_floatable);
cui.DockDialogBar alignAndDist #cui_dock_bottom