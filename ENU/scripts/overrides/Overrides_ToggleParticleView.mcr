MacroScript ToggleParticleView
	category:	"Overrides"
	buttonText: "Particle View Toggle"
	tooltip:	"Particle View Toggle"
(
/*	Basic fix for MAX's Particle View Shortcut which only operates
	when Keyboard Shortcut Overrides is enabled */
	on Execute do with undo off(
		-- Particle Flow: Particle View Toggle
		actionMan.executeAction 135018554 "32771"
	)
)