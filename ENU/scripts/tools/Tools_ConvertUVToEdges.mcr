MacroScript ConvertUVToEdges
	category: "Tools"
	buttonText: "Convert UVs to Edges"
	tooltip: "Convert UVs to Edges"
(
	on isVisible do subobjectlevel != 2
	on Execute do(
		global isEditingUVs;
		if(isEditingUVs()) then(
			local obj	=	Filters.GetModOrObj();
			local lvl	=	obj.getTVSubObjectMode();
			case lvl of(
				1:	obj.vertToEdgeSelect();
				3:	obj.faceToEdgeSelect();
			)
			subobjectlevel	=	2;
		)
	)
)