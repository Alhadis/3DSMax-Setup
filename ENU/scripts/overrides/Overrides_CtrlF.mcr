MacroScript CtrlF
	category:"Overrides"
	tooltip:"Flip / Fillet"
	buttonText:"Flip / Fillet"
(
	-- Performs one of two functions depending on current selection
	on Execute do(
		local version	= maxVersion();
		local obj		= Filters.GetModOrObj();
		local so		= subobjectlevel;
		
		-- Editable Splines: Enter "Fillet Vertex" mode
		if(Filters.Is_EditSpline()) then(
			-- Valid only in Vertex Subobject Level
			if(so == 1) then(
				max modify mode
				ApplyOperation Edit_Spline splineOps.startFillet
			)
		)


		-- Editable Poly: Run the "Flip Face Normals" macro
		else if(Filters.Is_EPoly()) then(
			-- Only valid in either Polygon or Element Subobject Level
			if(so == 4 or so == 5) then(
				max modify mode
				macros.run "Editable Polygon Object" "EPoly_FFlip"
			)
			
			-- UPDATE 28/08/2009: Added support for Segmented Chamfers in 3DS Max 2008 and newer
			else if(so == 2 and (version[1] > 9000)) then(
				local segments		=	obj.edgeChamferSegments;

				--	Could've just picked the same property name, guys...
				if(obj == $.baseObject)
					then	obj.edgeChamferOpen	=	false;
					else	obj.chamferEdgeOpen	=	false;

				if(segments < 3)
					then obj.edgeChamferSegments = 3;
				macros.run "Editable Polygon Object" "EPoly_Chamfer";
			)
			
		)


		-- Editable Mesh:	Apply flipNormal() operation
		else if(Filters.Is_EditMesh()) then
			ApplyOperation Edit_Mesh meshOps.flipNormal


		-- Editable Patch
		else if(Filters.Is_EditPatch()) then(
			-- Valid only at Polygon and Element subobject levels
			if(so == 3 or so == 4) then
			ApplyOperation Edit_Patch PatchOps.FlipNormal
		)


		--	Various Fallbacks
		else(
			global reverseSplineBase;
			
			--	Weren't in Modify mode? Force command panel switching and redeclare some variables to be safe.
			if(selection.count > 0 and getCommandPanelTaskMode() != #modify) then(
				max modify mode;
				obj	=	Filters.getModOrObj();
				so	=	subobjectlevel;
			)
			
			local type	=	classOf obj;
			local super	=	superclassOf obj;
			
			if(type == NormalModifier or type == Symmetry)	then	obj.flip			=	not(obj.flip);
			else if(type == Lathe)							then	obj.flipNormals		=	not(obj.flipNormals);
			else if(type == Melt)							then	obj.Negative_Axis	=	if(obj.Negative_Axis != 0) then 0 else 1;
			else if(type == Extrude)						then	reverseSplineBase $;
			
			--	Various deformation modifiers
			else if(obj != undefined and hasProperty obj "Flip_deformation_axis")
				then	obj.Flip_deformation_axis = if(obj.Flip_deformation_axis != 0) then 0 else 1;
			
			--	V-Ray Lights: Swap height and width values for Planar Lights
			else if(VRayLight != undefined and type == VRayLight and obj.type == 0)
				then	swap obj.size0 obj.size1
		)
	
	)
)