MacroScript ConvertToSplines
	category: "Tools"
	tooltip: "Convert to Splines"
	buttonText: "Convert to Splines"
(
	on isVisible do
		not(isKindOf (modPanel.getCurrentObject()) Modifier) and Filters.Is_EditSplineSpecifyLevel #{2,3};

	on Execute do(
		global splineConv;
		max modify mode;
		
		--	Knots
		if(subobjectlevel == 1) then
			splineConv.splinesByKnots $ (splineConv.getSelectedKnots $) keepOld:false;
		
		
		--	Segments
		else if(subobjectlevel == 2) then
			splineConv.splinesBySegments $ (splineConv.getSelectedSegments $) keepOld:false;
	)
)