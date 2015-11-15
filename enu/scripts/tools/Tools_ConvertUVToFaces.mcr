MacroScript ConvertUVToFaces
	category: "Tools"
	buttonText: "Convert UVs to Faces"
	tooltip: "Convert UVs to Faces"
(
	on isVisible do subobjectlevel != 3
	on Execute do(
		global isEditingUVs;
		if(isEditingUVs()) then(
			local obj	=	Filters.GetModOrObj();
			local lvl	=	obj.getTVSubObjectMode();
			case lvl of(
				1:	obj.vertToFaceSelect();
				2:	obj.edgeToFaceSelect();
			)
			subobjectlevel	=	3;
		)
	)
)