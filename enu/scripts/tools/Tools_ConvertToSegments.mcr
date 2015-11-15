MacroScript ConvertToSegments
	category: "Tools"
	tooltip: "Convert to Segments"
	buttonText: "Convert to Segments"
(
	on isVisible do
		not(isKindOf (modPanel.getCurrentObject()) Modifier) and Filters.Is_EditSplineSpecifyLevel #{2,4};

	on Execute do(
		global splineConv;
		max modify mode;
		
		--	Knots
		if(subobjectlevel == 1) then
			splineConv.segmentsByKnots $ (splineConv.getSelectedKnots $) keepOld:false;
		
		
		--	Splines
		else if(subobjectlevel == 3) then
			splineConv.segmentsBySplines $ (getSplineSelection $) keepOld:false;
	)
)