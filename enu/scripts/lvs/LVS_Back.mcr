MacroScript Back
	category: "LVS"
	buttonText: "Back"
	toolTip: "Back"
(
	on Execute do with undo off(
		global lvs;
		if(lvs != undefined)
			then	lvs.switch #view_back;
			else	actionMan.executeAction 0 "40064"
	)
)