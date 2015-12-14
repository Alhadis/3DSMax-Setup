MacroScript Divide
	category:"Overrides"
	buttonText:"Divide"
	tooltip:"Divide"
(
	switchTools = off;

	On Execute Do(
		max modify mode
		
		/* Declare Major Variables */
		local obj	= ModPanel.getCurrentObject();
		local index	= undefined;
		
		
		-- Check whether the selection's a Modifier or Base Object
		local isMod	= isKindOf obj Modifier;
		if(isMod) then
			index	= ModPanel.getModifierIndex $ obj
		
		
		/* Editable Mesh */
		if(Filters.Is_EditMesh()) then(
			edgeSel = if(isMod)
						then (getEdgeSelection $ mod)
						else (getEdgeSelection $);

			-- Make sure we're operating at Edge-level first
			if(subobjectlevel == 2) do(

				-- Check if any edges are selected
				if(edgeSel.isEmpty == false) then(
					for edge in edgeSel do
						meshop.divideEdge $ edge 0.5
					update $
					subobjectLevel = 1
				)

				-- If not, switch user to Divide Mode
				else(
					if(switchTools == on) then
						meshOps.startDivide $
				)
			)
		)


		/* Editable Poly */
		else if(Filters.Is_EPoly()) then(
			edgeSel = if(isMod) then obj.getSelection #Edge else polyOp.getEdgeSelection $.baseObject;
			vertSet = #()

			-- Make sure we're operating at Edge-level first
			if(subobjectLevel == 2) then(
				
				--	Modifier
				if(isMod) then(
					if(edgeSel.isEmpty == false) then(
						obj.setSelection #Vertex #{};
						obj.setOperation #InsertVertexInEdge;
						
						for edge in edgeSel do
							obj.divideEdge edge 0.5 node:$
						
						obj.commit();
						obj.refreshScreen();
						subobjectLevel = 1
					)
					else if(switchTools == on) then
						obj.toggleCommandMode #DivideEdge
				)
				
				--	Editable Poly
				else(
					if(edgeSel.isEmpty == false) then(
						for edge in edgeSel do(
							newVert = $.insertVertexInEdge edge 0.5
							append vertSet newVert
						)
						update $
						polyOp.setVertSelection $ vertSet
						subobjectLevel = 1
					)
					else if(switchTools == on) then
						polyOps.startDivideEdge $
				)
			)
			
			/* Polygon Level: Make Pole */
			else if(subobjectLevel == 4) then(
				
				--	TODO: Make a proper "Make Pole" function that uses the proper vertex coefficients
				--	for inserting vertices in the centres of selected faces.
				
				/* Base Object */
				if(obj == $.baseObject) then(
					faces	=	polyOp.getFaceSelection obj;
					if(faces.count > 0) then(
						obj.buttonOp #inset
						obj.collapse #Face
					)
				)
				
				/* Modifier */
				else(
					faces	=	obj.getSelection #CurrentLevel;
					if(faces.count > 0) then(
						obj.setOperation #Inset
						obj.insetAmount = 0.25
						obj.commit();
						obj.buttonOp #CollapseFace
					)
				)
			)
		)
		
		/* Editable Patch */
		else if(Filters.Is_EditPatchSpecifyLevel #{3..5}) then
			macros.run "Editable Patch Object" (if(subobjectlevel == 2) then "EPatch_Subdivide_Edge" else "EPatch_Subdivide_Patch")
		
		-- Lastly, check if we're working on an Editable Spline
		else if(Filters.Is_EditSpline()) then(
			local macroName	= if(subobjectlevel == 1)
					then	"ESpline_Break"
					else	"ESpline_Divide"
			
			macros.run "Editable Spline Object" macroName
		)

	)
)