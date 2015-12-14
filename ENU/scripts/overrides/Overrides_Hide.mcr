MacroScript Hide
	category: "Overrides"
	tooltip: "Hide"
	buttonText: "Hide"
(
	on Execute do(
		
		--	Mesh
		if(Filters.Is_EditMeshSpecifyLevel #{2..6}) then
			if(subobjectlevel == 2)
				then	macros.run "Editable Mesh Object" "EMesh_EInVisible"
				else	macros.run "Editable Mesh Object" "EMesh_Hide"
		
		--	Poly
		else if(Filters.Is_EPolySpecifyLevel #{2..6}) then
			if(subobjectlevel == 2)
				then	macros.run "Editable Polygon Object" "EPoly_ERemove"
				else	macros.run "Editable Polygon Object" "EPoly_Hide"
		
		--	Patch
		else if(Filters.Is_EditPatchSpecifyLevel #{2..5}) then
			macros.run "Editable Patch Object" "EPatch_Hide"
		
		--	Spline
		else if(Filters.Is_EditSplineSpecifyLevel #{2..4}) then
			macros.run "Editable Spline Object" "ESpline_Hide"
		
		--	Hide Selected
		else if(selection.count > 0) then
			max hide selection;
	)
)