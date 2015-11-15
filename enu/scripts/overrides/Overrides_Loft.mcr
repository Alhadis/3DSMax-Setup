MacroScript Loft
	category:"Overrides"
	tooltip:"Loft/Sweep"
	buttonText:"Sweep"
	Icon:#("Compound", 8)
(
	on isEnabled return okToCreate Loft;
	on Execute do(
		-- If holding Shift, add Sweep modifier instead
		local shift	=		keyboard.shiftPressed;
		if(shift)	then	macros.run "Modifiers" "SweepMod"
					else	macros.run "Objects Compounds" "Loft"
	)
)