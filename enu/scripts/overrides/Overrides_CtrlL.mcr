MacroScript CtrlL
	category:	"Overrides"
	buttonText:	"Lathe"
	tooltip:	"Lathe"
	Icon:		#("Standard_Modifiers", 14)
(
	on Execute do(
	
		if(mcrUtils.ValidMod Lathe) then
			macros.run "Modifiers" "Lathe"
		
		else
			max default lighting toggle
		
	)
)