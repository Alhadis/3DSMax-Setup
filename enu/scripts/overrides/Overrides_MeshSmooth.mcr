MacroScript MeshSmooth
	category:"Overrides"
	tooltip:"Turbo/MeshSmooth Modifier"
	buttonText:"Turbo/MeshSmooth"
	Icon:#("Standard_Modifiers", 19)
(
	on isEnabled return mcrUtils.ValidMod MeshSmooth;
	on Execute do(
		-- If holding Shift, add Symmetry modifier instead
		local shift		= keyboard.shiftPressed;
		local modname	= if(shift) then "TurboSmoothMod" else "MeshSmooth";
		macros.run "Modifiers" modname;
	)
)