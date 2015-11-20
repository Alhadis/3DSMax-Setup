MacroScript N
	category:"Overrides"
	buttonText:"NURMS Toggle"
	toolTip:"NURMS Toggle"
(
	on Execute do(
		
		--	Editable Poly: NURMS Toggle
		if(Filters.Is_EditPoly()) then(
			if(classOf $ == Editable_Poly) then	$.showCage = off
			macros.run "Editable Polygon Object" "EPoly_NURMS_Toggle";
		)
		
		--	Toggle interpolation steps of selected spline
		else try(
			if(Filters.Is_EditSpline() or (selection.count > 0 and isKindOf $.baseObject Shape))
				then $.adaptive = not($.adaptive)
		)	catch( /* Swallow Error */ )
	)
)