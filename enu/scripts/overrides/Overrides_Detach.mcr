MacroScript Detach
	category: "Overrides"
	buttonText: "Detach"
	tooltip: "Detach"
(
	/**
	 * Detach a subobject to an independent object.
	 * Holding shift breaks it off as a copy instead.
	*/
	
	on Execute do(
		local obj	=	Filters.GetModOrObj();
		
		--	Poly
		if(Filters.Is_EPolySpecifyLevel #{2..6}) then(
			global polyDetach;
			
			--	Base Object
			if(obj == $.baseObject) then
				polyDetach $ subobjectlevel del:(not keyboard.shiftPressed);
			
			--	Modifiers
			else(
				if(keyboard.shiftPressed) then(
					local selType	=	case subobjectlevel of(
						1: #Vertex
						2: #Edge
						3: #Edge
						default: #Face
					);
					local sel	=	obj.getSelection selType;
					if(not sel.isEmpty) then(
						local index	=	getModifierIndex $;
						local o		=	#();
						local so	=	subobjectlevel;
						
						with redraw off(
							maxOps.cloneNodes $ cloneType:#copy newNodes:&o
							pruneModifiers o[1] index;
							convertTo o[1] Editable_Poly;
							modPanel.setCurrentObject obj;
							subobjectlevel = so;
							polyDetach o[1] so del:true;
							delete o[1];
						)
					)
				)
				else obj.detachToObject (uniqueName "Object");
			)
		)
		
		
		-- Mesh
		else if(Filters.Is_EditMeshSpecifyLevel #{2,4..6}) then(
			global meshDetach;
			
			--	Base Object
			if(obj == $.baseObject) then
				meshDetach $ subobjectlevel del:(not keyboard.shiftPressed);
			
			--	Modifiers
			else(
				local sel	=	if(subobjectlevel == 1)
					then	getVertSelection $ obj;
					else	getFaceSelection $ obj;
				
				--	Subobject selection exists
				if(not sel.isEmpty) then(
					local index	=	getModifierIndex $;
					local o		=	#();
					local so	=	subobjectlevel;
					
					with redraw off(
						maxOps.cloneNodes $ cloneType:#copy newNodes:&o
						pruneModifiers o[1] index;
						convertToMesh o[1];
						modPanel.setCurrentObject obj;
						subobjectlevel = so;
						meshDetach o[1] so del:true;
						delete o[1];
					)
					if(not keyboard.shiftPressed) then
						max delete;
				)
			)
		)
		
		
		-- Spline
		else if(Filters.Is_EditSplineSpecifyLevel #{2..4}) then(
			global splineConv;
			
			--	Base Object
			if(obj == $.baseObject) then(
				if(subobjectlevel == 1)
					then splineConv.segmentsByKnots $ (splineConv.getSelectedKnots $);
				
				try(applyOperation Edit_Spline splineOps.detach) catch();
				/*
				local sel	=	case subobjectlevel of(
					2:	splineConv.getSelectedSegments $
					3:	getSplineSelection $
				)
				
				local o		=	#();
				local so	=	subobjectlevel;
				
				with redraw off(
					maxOps.cloneNodes $ cloneType:#copy newNodes:&o;
					pruneModifiers o[1] index;
					convertTo o[1] SplineShape;
					modPanel.setCurrentObject obj;
					subobjectlevel = so;
					
					--	Segments
					if(so == 2) then for i = 1 to numSplines o[1] do(
						setSegSelection o[1] i -((sel[i] as Array) as BitArray)
					)
					
					--	Splines
					else for i = 1 to o[1].numSplines do(
						
					)
				)*/
			)
		)
		
	)
)