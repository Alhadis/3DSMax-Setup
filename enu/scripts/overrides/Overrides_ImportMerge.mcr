MacroScript ImportMerge
	category: "Overrides"
	buttonText: "Import / Merge"
	tooltip: "Import / Merge"
(
	--	Show Merge dialogue if Shift is held when pressed; Import dialog otherwise.
	on Execute do(
		if(keyboard.shiftPressed)		then	max file merge;
		else if(keyboard.altPressed)	then	max file xref object;
		else									max file import;
	)
)