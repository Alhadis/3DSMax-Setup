MacroScript RemoveEdge
	category:"Overrides"
	tooltip:"Remove Edge"
	buttonText:"Remove Edge"
(
	on Execute do(
		local obj	=	Filters.GetModOrObj();

		if(Filters.Is_EPolySpecifyLevel #{3}) then(
			global cleanRemove;
			cleanRemove obj;
		)
		
		else macros.run "Overrides" "BooleanSubtract";
	)
)