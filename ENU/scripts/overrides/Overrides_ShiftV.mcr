MacroScript ShiftV
	category: "Overrides"
	buttonText: "UVW Modifier"
	tooltip: "UVW Modifier"
	icon: #("Material_Modifiers", 4)
(
	on isEnabled do mcrUtils.validMod Uvwmap
	on execute do(
		
		--	Unwrap UVW
		if(keyboard.altPressed) then(
			local uvw	=	Unwrap_UVW();
			uvw.setGridVisible false;
			uvw.setShowMapSeams false;
			uvw.setPeltAlwaysShowSeams false;
			
			if(#modify != getCommandPanelTaskMode())
				do setCommandPanelTaskMode mode:#modify
			modPanel.addModToSelection uvw;
		)
		
		else	macros.run "Modifiers" "Uvwmap"
	)
)