MacroScript SubObject_1
	category:	"Overrides"
	buttonText:	"Vertex\Knot"
	tooltip:	"Subobject Level 1"
	Icon:		#("SubObjectIcons", 1)
(
	on Execute do(
		global subsink, isEditingUVs;
		if(isEditingUVs() or subsink == undefined or (subsink.enabled == false))
			then	macros.run "Modifier Stack" "SubObject_1"
			else	with undo off subsink.s1();
	)
)