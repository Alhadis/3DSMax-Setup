MacroScript Perspective
	category: "LVS"
	buttonText: "Perspective"
	toolTip: "Perspective"
(
	on Execute do with undo off(
		global lvs;
		if(lvs != undefined)
			then	lvs.switch #view_persp_user;
			else	actionMan.executeAction 0 "40182";
	)
)