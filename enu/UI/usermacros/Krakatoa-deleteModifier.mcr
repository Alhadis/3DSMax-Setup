macroScript deleteModifier category:"Krakatoa" tooltip:"Krakatoa Delete Modifier - hold SHIFT to Instance among Selection" icon:#("Krakatoa",11)
(
	on isEnabled return (selection.count > 0)
	on execute do 
	(
		local theObjects = (for o in selection where classof o.baseobject == KrakatoaPrtLoader or classof o.baseobject == PRT_Volume collect o)
		if keyboard.shiftPressed then
		(
			local newModifier = KrakatoaDeleteModifier()
			for o in theObjects do addModifier o newModifier
			max modify mode
		)	
		else
		(
			for o in theObjects do addModifier o (KrakatoaDeleteModifier())
			max modify mode
		)
	)	
) 