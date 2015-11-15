MacroScript G
	category: "Overrides"
	buttonText: "Grid Toggle"
	tooltip: "Grid Toggle"
	icon: #("Helpers", 4)
(
	on Execute do with undo off(
		local obj	=	Filters.GetModOrObj();
		
		--	Unwrap UVW: Toggle grid in edit window, if opened
		if(isKindOf obj Unwrap_UVW and obj.getWindowH() > 0) then
			obj.setGridVisible (not obj.getGridVisible());
		
		--	Default: Toggle grid in viewport
		else max grid toggle;
	)
)