MacroScript SubObject_4
	category:	"Overrides"
	buttonText:	"Polygon/PatchElement"
	tooltip:	"Subobject Level 4"
	Icon:		#("SubObjectIcons", 4)
(
	on Execute do(
		global subsink, isEditingUVs;
		if(isEditingUVs()) then	macros.run "Modifier Stack" "SubObject_3"
		else if(subsink == undefined or (subsink.enabled == false)) then
			macros.run "Modifier Stack" "SubObject_4"
		else with undo off subsink.s4();
	)
)