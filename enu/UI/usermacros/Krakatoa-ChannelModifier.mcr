macroScript ChannelModifier category:"Krakatoa" tooltip:"Krakatoa Channels Modifier - hold SHIFT to Instance among Selection" icon:#("Krakatoa",9)
(
	on isEnabled return (selection.count > 0)
	on execute do 
	(
		local theObjects = (for o in selection where classof o.baseobject == KrakatoaPrtLoader or classof o.baseobject == PRT_Volume collect o)
		if keyboard.shiftPressed then
		(
			local newModifier = KrakatoaChannelsModifier()
			for o in theObjects do addModifier o newModifier
			max modify mode
		)	
		else
		(
			for o in theObjects do addModifier o (KrakatoaChannelsModifier())
			max modify mode
		)
	)	
)
