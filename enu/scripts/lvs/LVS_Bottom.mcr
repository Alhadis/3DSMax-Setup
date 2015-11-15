MacroScript Bottom
	category: "LVS"
	buttonText: "Bottom"
	toolTip: "Bottom"
(
	on Execute do with undo off(
		global lvs;
		if(lvs != undefined)
			then	lvs.switch #view_bottom;
			else	actionMan.executeAction 0 "40063";
	)
)