MacroScript ConvertUVToVerts
	category: "Tools"
	buttonText: "Convert UVs to Vertices"
	tooltip: "Convert UVs to Vertices"
(
	on isVisible do subobjectlevel != 1
	on Execute do(
		global isEditingUVs;
		if(isEditingUVs()) then(
			local obj	=	Filters.GetModOrObj();
			local lvl	=	obj.getTVSubObjectMode();
			case lvl of(
				2:	obj.edgeToVertSelect();
				3:	obj.faceToVertSelect();
			)
			subobjectlevel	=	1;
		)
	)
)