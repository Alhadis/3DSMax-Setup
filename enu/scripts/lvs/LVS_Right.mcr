MacroScript Right
	category: "LVS"
	buttonText: "Right"
	toolTip: "Right"
(
	on Execute do with undo off(
		global lvs;
		if(lvs != undefined)
			then	lvs.switch #view_right;
			else	actionMan.executeAction 0 "40062";
	)
)