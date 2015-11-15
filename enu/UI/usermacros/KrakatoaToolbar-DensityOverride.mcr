macroScript DensityOverride category:"KrakatoaToolbar" tooltip:"Override Density Channel Toggle" icon:#("KrakatoaTools",26)
(
	on isEnabled return (renderers.current.classid as string == "#(-1204370534, -399920359)")
	on isChecked return try(FranticParticles.getBoolProperty "DensityOverride:Enabled")catch(false)
	on execute do (
		try(FranticParticles.setProperty "DensityOverride:Enabled" ((not (FranticParticles.getBoolProperty "DensityOverride:Enabled")) as string))catch()
		try(Krakatoa_GUI_RenderGlobalValues.refresh_GUI())catch()
		--try(Krakatoa_GUI_Main.refresh_GUI())catch()
		try(Krakatoa_GUI_Main.update2009VFBControls side:#left)catch()
		try(Krakatoa_GUI_Channels.updateMemChannels())catch()
	)
)
