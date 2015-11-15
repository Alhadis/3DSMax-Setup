MacroScript SubObject_3
	category:	"Overrides"
	buttonText:	"Face/Border/Spline/Patch"
	tooltip:	"Subobject Level 3"
	Icon:		#("SubObjectIcons", 3)
(
	on Execute do(
		global subsink, isEditingUVs;
		if(isEditingUVs() or subsink == undefined or (subsink.enabled == false))
			then	macros.run "Modifier Stack" "SubObject_3"
			else	with undo off subsink.s3();
	)
)