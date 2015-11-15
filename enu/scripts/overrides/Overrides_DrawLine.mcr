MacroScript DrawLine
	category:"Overrides"
	tooltip:"Draw Line"
	buttonText:"Draw Line"
	Icon:#("CustomIcons",1)
(
	on Execute do(
		-- If holding Shift, start a Freehand Drawing instead
		if(keyboard.shiftPressed)
			then	macros.run "Tools" "FreeSpline";
			else	macros.run "Objects Shapes" "Lines";
	)
)