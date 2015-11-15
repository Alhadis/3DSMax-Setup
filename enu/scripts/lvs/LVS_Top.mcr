MacroScript Top
	category: "LVS"
	buttonText: "Top"
	toolTip: "Top"
(
	on Execute do with undo off(
		global lvs;
		if(lvs != undefined)
			then	lvs.switch #view_top;
			else	actionMan.executeAction 0 "40059";
	)
)