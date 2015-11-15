macroScript UseEmissionChannel category:"KrakatoaToolbar" tooltip:"Use Emission Channel Toggle" icon:#("KrakatoaTools",30)
(
	on isEnabled return (renderers.current.classid as string == "#(-1204370534, -399920359)")
	on isChecked return try(FranticParticles.getBoolProperty "UseEmissionColor")catch(false)
	on execute do (
		try(FranticParticles.setProperty "UseEmissionColor" ((not (FranticParticles.getBoolProperty "UseEmissionColor")) as string))catch()
		try(Krakatoa_GUI_Main.refresh_GUI())catch()
		try(Krakatoa_GUI_Main.update2009VFBControls side:#left)catch()
		try(Krakatoa_GUI_Channels.updateMemChannels())catch()
	)
)
