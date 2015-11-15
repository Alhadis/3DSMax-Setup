MacroScript ConvertToKnots
	category: "Tools"
	tooltip: "Convert to Knots"
	buttonText: "Convert to Knots"
(
	on isVisible do
		not(isKindOf (modPanel.getCurrentObject()) Modifier) and Filters.Is_EditSplineSpecifyLevel #{3,4};

	on Execute do(
		global splineConv;
		max modify mode;
		
		--	Segments
		if(subobjectlevel == 2) then
			splineConv.knotsBySegments $ (splineConv.getSelectedSegments $) keepOld:false;
		
		
		--	Splines
		else if(subobjectlevel == 3) then
			splineConv.knotsBySplines $ (getSplineSelection $) keepOld:false;
	)
)