MacroScript Front
	category: "LVS"
	buttonText: "Front"
	toolTip: "Front"
(
	on Execute do with undo off(
		global lvs;
		if(lvs != undefined)
			then	lvs.switch #view_front;
			else	actionMan.executeAction 0 "40060"
	)
)