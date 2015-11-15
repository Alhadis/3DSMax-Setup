MacroScript Show
	category: "Overrides"
	tooltip: "Show"
	buttonText: "Show"
(
	on Execute do(
		
		--	Mesh
		if(Filters.Is_EditMeshSpecifyLevel #{2..6}) then
			if(subobjectlevel == 2)
				then	macros.run "Editable Mesh Object" "EMesh_EVisible"
				else	macros.run "Editable Mesh Object" "EMesh_UnHide"
		
		--	Poly
		else if(Filters.Is_EPolySpecifyLevel #{2..6}) then
			macros.run "Editable Polygon Object" "EPoly_UnHide"
		
		--	Patch
		else if(Filters.Is_EditPatchSpecifyLevel #{2..5}) then
			macros.run "Editable Patch Object" "EPatch_UnHide"
		
		--	Spline
		else if(Filters.Is_EditSplineSpecifyLevel #{2..4}) then
			macros.run "Editable Spline Object" "ESpline_UnHide"
		
		--	Unhide All
		else max unhide all;
	)
)