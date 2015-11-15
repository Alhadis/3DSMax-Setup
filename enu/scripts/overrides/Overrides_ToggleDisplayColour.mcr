MacroScript ToggleDisplayColour
	category:	"Overrides"
	tooltip:	"Display Colour"
	buttonText:	"Display Colour"
(
	on Execute do(
		if(displayColor.shaded == #material) then
			displayColor.shaded = #object;
		else
			displayColor.shaded = #material;
	)
)