MacroScript BooleanUnion
	category: "Overrides"
	buttonText: "Boolean (Union)"
	tooltip: "Boolean (Union)"
(
	on Execute do(
		local obj	=	Filters.GetModOrObj();
		
		if(Filters.Is_EditSplineSpecifyLevel #{2..4}) then(
			global splineConv;
			if(subobjectlevel == 1)			then	splineConv.splinesByKnots $ (splineConv.getSelectedKnots $);
			else if(subobjectlevel == 2)	then	splineConv.splinesBySegments $ (splineConv.getSelectedSegments $);
			
			splineOps.startUnion (if(obj == $.baseObject) then $ else obj);
		)
	)
)