MacroScript Refine
	category: "Overrides"
	buttonText: "Refine / Insert Vertex"
	tooltip: "Refine / Insert Vertex"
	icon: #("Max_Edit_Modifiers",7)
(
	on Execute do(
		
		--	Poly
		if(Filters.Is_EPolySpecifyLevel #{3..6}) then
			macros.run "Editable Polygon Object" "EPoly_InsertVertex"
		
		--	Mesh
		else if(Filters.Is_EditMeshSpecifyLevel #{3..6}) then(
			local macro	=	case subobjectlevel of(
				2:			"EMesh_EDivide"
				3:			"EMesh_FDivide"
				default:	"EMesh_PDivide"
			);
			macros.run "Editable Mesh Object" macro;
		)
		
		--	Spline
		else if(Filters.Is_EditSplineSpecifyLevel #{2..4}) then
			macros.run "Editable Spline Object" "ESpline_Refine"
	)

)