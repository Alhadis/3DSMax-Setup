MacroScript SubObject_2
	category:	"Overrides"
	buttonText:	"Edge/Segment"
	tooltip:	"Subobject Level 2"
	Icon:		#("SubObjectIcons", 2)
(
	on Execute do(
		global subsink, isEditingUVs;
		if(isEditingUVs() or subsink == undefined or (subsink.enabled == false))
			then	macros.run "Modifier Stack" "SubObject_2"
			else	with undo off subsink.s2();
	)
)