MacroScript SubObject_5
	category:	"Overrides"
	buttonText:	"Element"
	tooltip:	"Subobject Level 5"
	Icon:		#("SubObjectIcons", 5)
(
	on Execute do(
		global subsink, isEditingUVs;
		if(isEditingUVs()) then	macros.run "Modifier Stack" "SubObject_3"
		else if(subsink == undefined or (subsink.enabled == false)) then
			macros.run "Modifier Stack" "SubObject_5"
		else with undo off subsink.s5();
	)
)