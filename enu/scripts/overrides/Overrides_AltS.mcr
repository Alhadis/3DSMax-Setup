MacroScript AltS
	category:	"Overrides"
	buttonText: "AutoSmooth / Create Shape"
	tooltip:	"AutoSmooth / Create Shape"
(
	on Execute do(
		local so		= subobjectlevel
		local obj		= Filters.GetModOrObj();
		local shift		= keyboard.shiftPressed;
		
		local result;	-- Returned from createShape operations to verify edge was created.
		local soSel;	-- Used for holding the Sub-Object Selection
		local uName;	-- Unique name generated for newly created Shapes
		local isMod		= (isKindOf (Filters.getModOrObj()) Modifier);
		
			
		-- Editable Poly
		if(Filters.Is_EPoly()) then(
			isMod		= Filters.Is_This_EditPolyMod(obj);
			
			-- Polygon/Element:	AutoSmooth
			if(Filters.Is_EPolySpecifyLevel #{5..6}) then(
				if(shift)	then	macros.run "Editable Polygon Object" "EPoly_ClearSmoothing";
							else	macros.run "Editable Polygon Object" "EPoly_Autosmooth";
			)
			
			-- Edge Level: Create Shape From Edges (Linear Shape, no dialog)
			else if(Filters.Is_EPolySpecifyLevel #{3..4}) then(
				uName		= uniqueName("Shape");
				
				-- Modifiers require specific handling of methods. Obviously.
				if(isMod) then(
					soSel	= EditPolyMod.getSelection obj #Edge;
					
					-- Don't create an empty Shape object
					if(soSel.isEmpty == false) then(
						result	= obj.createShape uName;
						if(result == OK and not shift) then(
							newNode	 = getNodeByName uName ignoreCase:false;
							subobjectlevel		=	0;
							select newNode;
							newNode.material	=	undefined;
							subobjectlevel		=	1;
						)
					)
				)
				
				-- Editable Poly (No Modifiers; simply base level)
				else(
					soSel	= polyOp.getEdgeSelection obj;
					
					-- Again, don't create a shape if no edges are selected.
					if(soSel.isEmpty == false) then(
						result = obj.createShape uName off $
						if(result and not shift) then(
							newNode	= getNodeByName uName ignoreCase:false;
							subobjectlevel		=	0;
							select newNode;
							newNode.material	=	undefined;
							subobjectlevel		=	1;
						)
					)
					
				)
			)
			
			-- Vertex Level: Basic behaviour is to add a skew modifier
			else if(Filters.Is_EditPolySpecifyLevel #{2}) then(
				soSel	= if(isMod) then	EditPolyMod.getSelection obj #Edge;
									else	polyOp.getVertSelection obj;
				
				-- If we've got no vertices selected, step out of SO-level before adding modifier
				if(soSel.isEmpty)	then subobjectlevel = 0;

				macros.run "Modifiers" "Skew";
			)
			
			-- Default: Add a Skew Modifier anyway
			else macros.run "Modifiers" "Skew";
		)
		
		
		-- Editable Mesh
		--	*	No automatic instantiation? Screw that. Oh well, guess we'd better settle
		--		for a mandatory Dialog option.
		else if(Filters.Is_EditMesh()) then(
			
			-- Edge: Create shape from edges
			if(Filters.Is_EditMeshSpecifyLevel #{3}) then(
				soSel	= if(isMod)	then	getEdgeSelection $ (Filters.getModOrObj())
									else	getEdgeSelection $;
					
				if(soSel.isEmpty == false) then
					macros.run "Editable Mesh Object" "EMesh_ShapeFromEdges"
			)
			
			
			-- Polygons, Elements, Faces: AutoSmooth / Clear Smoothing Groups
			--	*	Only available at Base Level (collapsed Editable_Mesh nodes)
			else if(Filters.Is_EditMeshSpecifyLevel #{4..6}) then(
				
				if(not isMod) then(
					soSel		= getFaceSelection $;
					if(shift) then(
						for i in soSel do setFaceSmoothGroup $ i 0;
					)
					else	meshOp.autoSmooth obj soSel 45;
					update $;
				)
			)
		)
		
		
		
		-- Editable Patch
		--	*	Again, as with meshes, MaxScript support for Editable Patches is heavily limited.
		else if(Filters.Is_EditPatch()) then(
			
			-- Edges: Create a shape
			if(Filters.Is_EditPatchSpecifyLevel #{3}) then
				macros.run "Editable Patch Object" "EPatch_CreateShapeFromEdges";
			
			
			-- Patch/Element: AutoSmooth
			else if(Filters.Is_EditPatchSpecifyLevel #{4..5}) then(
				
				-- Modifiers: Operations restricted by limited support for Modifier methods
				--	*	Only the "Clear Smoothing Groups" method is functional while working on a modifier
				if(isMod) then(
					if(shift)	then	patchOps.clearallSG obj;
				)
				
				-- Base Level
				else(
					if(shift)	then	patchOps.clearAllSG $;
								else	patch.autoSmooth $ 1.55 true true;
							patch.update $;
				)
			)
			
			-- Default: Add a Skew Modifier instead
			else macros.run "Modifiers" "Skew";
		)
		
		
		-- Additional Smoothing Behaviours
		else(
			local propName	=	case of(
				(hasProperty obj "smooth"):			"smooth"
				(hasProperty obj "smoothResult"):	"smoothResult"
				(hasProperty obj "smooth_on"):		"smooth_on"
				(hasProperty obj "smooth_spring"):	"smooth_spring"
				(hasProperty obj "autoSmooth"):		"autoSmooth"
				(hasProperty obj "smoothing"):		"smoothing"
				default:							undefined
			);
			
			--	If the currently selected object possesses a property named "smooth" or something
			--	noticeably similar, toggle the setting appropriately.
			if(propName != undefined and hasProperty obj propName) then(
				local propValue	=	getProperty obj propName;
				local propType	=	classof propValue;
				
				--	Regular boolean properties
				if(propType == BooleanClass) then
					setProperty obj propName (not(propValue));
				
				--	Compound values; handled on a case-by-case basis
				else if(propType == Integer) then(
					local smoothed =	case type of(
						Torus:		2
						Torus_Knot:	2
						default:	1
					);
					
					setProperty obj propName (if(propValue != 0) then 0 else smoothed);
				)
			)
			
		)
		
	)
)