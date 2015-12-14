MacroScript Weld
	category: "Overrides"
	tooltip: "Weld"
	buttonText: "Weld"
(
	on Execute do(
		local alt		= keyboard.altPressed;
		
		-- Editable Mesh
		if(Filters.Is_EditMesh()) then(
			if(alt and subobjectlevel == 1)
				then	macros.run "Editable Mesh Object" "EMesh_Weld"
				else	macros.run "Editable Mesh Object" "EMesh_Collapse"
		)
		
		-- Editable Polygon
		else if(Filters.Is_EPoly()) then(
			if(alt)
				then	macros.run "Editable Polygon Object" "EPoly_Weld"
				else	macros.run "Editable Polygon Object" "EPoly_Collapse"
		)
		
		-- Editable Splines
		else if(Filters.Is_EditSplineSpecifyLevel #{2,3}) then(
			if(alt)	then	applyOperation Edit_Spline splineOps.Weld;
			else(
				if(subobjectlevel == 2)	then macros.run "Tools" "ConvertToKnots";
				try(
					applyOperation Edit_Spline splineops.Fuse
					applyOperation Edit_Spline splineops.Weld
				) catch()
			)
		)
		
		-- Editable Patch
		else if(Filters.Is_EditPatch()) then(
			-- Valid only in Vertex Subobject level
			if(subobjectlevel == 1) do(
				if(alt) then		ApplyOperation Edit_Patch PatchOps.startWeldTarget
				else				ApplyOperation Edit_Patch PatchOps.Weld
			)
		)
		
		-- Groups [UPDATE 3/10/2009 1:42 AM : Closes group heads if any are selected]
		else(
			--	Selection set isn't empty
			if(selection.count > 0) then(
				local canClose = false;
				for i in selection do
					if(isOpenGroupHead i or isOpenGroupMember i) then
						canClose = true;
				if(canClose)
					then max group close;
			)
		)
		
	)
)