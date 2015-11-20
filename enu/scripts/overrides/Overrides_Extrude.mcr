macroScript Extrude
	category:"Overrides"
	buttonText:"Extrude"
	tooltip:"Extrude"
	Icon:#("Standard_Modifiers", 13)
(

	on Execute do(
		local useBevel	= on;
		local shift		= keyboard.shiftPressed;
		local usingAlt	= (shift and useBevel);

		--	Editable Spline: If working at subobjectlevel, enter Outline Mode
		if(Filters.Is_EditSplineSpecifyLevel #{2..4}) then(
			if(subobjectlevel < 3) then(
				macros.run "Tools" "ConvertToSplines"
				subobjectlevel = 3;
			)
			macros.run "Editable Spline Object" "ESpline_Outline";
		)


		--	Shape: Add an Extrude modifier
		else if(mcrUtils.ValidMod Extrude) then
			macros.run "Modifiers" (if(usingAlt) then "Bevel" else "Extrude");

		
		-- Editable Poly
		else if(Filters.Is_EPoly()) then(
			if(subobjectlevel != undefined and subobjectlevel > 0) then(
				if(subobjectlevel != 4)	then usingAlt = false; -- Only Polygons can be bevelled
				macroName = if(usingAlt) then "EPoly_Bevel" else "EPoly_Extrude"
				macros.run "Editable Polygon Object" macroName
			)
			else macros.run "Modifiers" "Shell"
		)
		
		
		-- Editable Mesh
		else if(Filters.Is_EditMesh()) then(
			max modify mode
			
			-- Add a Shell modifier if we're not working at subobject level
			if(subobjectlevel == 0) then	macros.run "Modifiers" "Shell"
			
			-- Valid at any subobject level except Vertex
			else if(Filters.Is_EditMeshSpecifyLevel #{3..6}) then(
				
				-- Resolve the appropriate macro's name depending on SO level
				macroName	= case subobjectlevel of(
					5:			(if(usingAlt) then meshops.startBevel else meshops.startExtrude)
					4:			(if(usingAlt) then "EMesh_PBevel" else "EMesh_PExtrude")
					3:			(if(usingAlt) then "EMesh_FBevel" else "EMesh_FExtrude")
					2:			"EMesh_EExtrude"
					default:	"EMesh_PExtrude"
				)
				
				-- Because the EMesh_PExtrude macro sets the SO-level to Polygon, manually apply operation at Element level 
				if(subobjectlevel == 5)	then ApplyOperation Edit_Mesh macroName
				
				-- Otherwise, execute the respective macro normally
				else	macros.run "Editable Mesh Object" macroName;
			)
		)
		
		
		-- Editable Patch
		else if(Filters.Is_EditPatch()) then(
			-- Patches aren't suitable for Shell modifiers, but we'll add one anyway if not in SO level
			if(inSOL == false) then macros.run "Modifiers" "Shell"
			
			-- Valid at Edge, Patch and Element subobject levels
			else if(Filters.Is_EditPatchSpecifyLevel #{3..5}) then(
				max modify mode
				
				-- Retrieve the name of the macro specific to this subobject level
				macroName	= case so of(
					2:			"EPatch_Extrude_Edge"
					default:	(if(usingAlt) then "EPatch_Bevel_Patch" else "EPatch_Extrude_Patch")
				)
				
				macros.run "Editable Patch Object" macroName
			)
		)
		
		
		-- Otherwise, add a Shell modifier as a last alternative
		else if(mcrUtils.ValidMod Shell) then
			macros.run "Modifiers" "Shell"




	)
)
