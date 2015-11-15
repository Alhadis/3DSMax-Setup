MacroScript X
	category:"Overrides"
	buttonText:"Autogrid/Gizmo Toggle"
	tooltip:"Toggle Autogrid / Transform Gizmo"
(
	on Execute do with undo off(
		
		isCreating	= isCreatingObject();
		createMode = (getCommandPanelTaskMode() == #create);
		
		if createMode then
			maxOps.autoGrid	= (maxOps.autoGrid == false);
		
		else(
			preferences.useTransformGizmos = (preferences.useTransformGizmos == false)
			max views redraw
		)
	)
)