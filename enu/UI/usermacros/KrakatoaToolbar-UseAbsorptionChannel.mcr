macroScript UseAbsorptionChannel category:"KrakatoaToolbar" tooltip:"Use Absorption Channel Toggle" icon:#("KrakatoaTools",31)
(
	on isEnabled return (renderers.current.classid as string == "#(-1204370534, -399920359)")
	on isChecked return try(FranticParticles.getBoolProperty "UseFilterColor")catch(false)
	on execute do (
		try(FranticParticles.setProperty "UseFilterColor" ((not (FranticParticles.getBoolProperty "UseFilterColor")) as string))catch()
		try(Krakatoa_GUI_Main.refresh_GUI())catch()
		try(Krakatoa_GUI_Main.update2009VFBControls side:#left)catch()
		try(Krakatoa_GUI_Channels.updateMemChannels())catch()
	)
) 