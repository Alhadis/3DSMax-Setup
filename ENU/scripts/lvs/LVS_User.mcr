MacroScript User
	category: "LVS"
	buttonText: "User"
	toolTip: "User"
(
	on Execute do with undo off(
		global lvs;
		if(lvs != undefined)
			then	lvs.switch #view_iso_user;
			else	actionMan.executeAction 0 "40183";
	)
)