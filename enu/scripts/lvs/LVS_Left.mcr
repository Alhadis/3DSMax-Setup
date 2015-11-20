MacroScript Left
	category: "LVS"
	buttonText: "Left"
	toolTip: "Left"
(
	on Execute do with undo off(
		global lvs;
		if(lvs != undefined)
			then	lvs.switch #view_left;
			else	actionMan.executeAction 0 "40061";
	)
)