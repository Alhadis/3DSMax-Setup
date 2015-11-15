

if(selection.count > 0) then(
	thresh	=	5.0;
	for i in selection do(
		uvs	=	UVW_Xform U_Offset:(random -(thresh) thresh) V_Offset:(random -(thresh) thresh);
		addModifier i uvs;
	)
)