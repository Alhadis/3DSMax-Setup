MacroScript CtrlM
	category:	"Overrides"
	buttonText:	"Mirror / Merge"
	tooltip:	"Mirror / Merge"
	Icon:		#("Maintoolbar", 51)
(
	--	Runs a Mirror command if a selection set exists; otherwise, shows File Merge dialog.
	on Execute do(
		
		if(selection.count > 0)
			then max mirror
		else
			max file merge;
		
	)
)