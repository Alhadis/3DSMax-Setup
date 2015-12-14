macroScript toggleFrozenInGrey
	category:"Tools"
	toolTip:"Show Frozen In Grey Toggle"
	buttontext:"Toggle Frozen In Grey"
	Icon:#("CustomIcons", 12)
(
	
	/*
		Toggles an object's "Show Frozen In Grey" property
	
		UPDATE 2/10/2009 9:06 PM: Switched Shift-behaviour to always default to "Frozen with Grey Off".
		Irrespective of the node's "Frozen in grey" property, this function will always freeze the node
		with the property turned off.
	*/
	
	on Execute do(
		
		-- If SHIFT was being held, freeze the selection.
		if(keyboard.shiftPressed) then(
			for i in selection do
				i.showFrozenInGray = off;
			max freeze selection;
		)
		else
			for i in selection do(
				if(i.showFrozenInGray == on) then i.showFrozenInGray = off
				else i.showFrozenInGray = on
			)
	)
)