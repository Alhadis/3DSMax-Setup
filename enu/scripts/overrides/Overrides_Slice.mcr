MacroScript Slice
	category:"Overrides"
	tooltip:"Slice"
	buttonText:"Slice/Symmetry"
	Icon:#("Standard_Modifiers", 30)
(
	on isEnabled return mcrUtils.ValidMod slicemodifier;
	on Execute do(
		-- If holding Shift, add Symmetry modifier instead
		local shift		= keyboard.shiftPressed;
		local modname = if(shift) then "Symmetry" else "Slice";
		macros.run "Modifiers" modname;
	)
)