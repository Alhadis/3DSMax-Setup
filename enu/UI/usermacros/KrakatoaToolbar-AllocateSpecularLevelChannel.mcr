macroScript AllocateSpecularLevelChannel category:"KrakatoaToolbar" tooltip:"Allocate SpecularLevel Channel Toggle" icon:#("KrakatoaTools",29)
(
	on isEnabled return (renderers.current.classid as string == "#(-1204370534, -399920359)")
	on isChecked return try(FranticParticles.getBoolProperty "Channel:Allocate:SpecularLevel")catch(false)
	on execute do (
		try(FranticParticles.setProperty "Channel:Allocate:SpecularLevel" ((not (FranticParticles.getBoolProperty "Channel:Allocate:SpecularLevel")) as string))catch()
		try(Krakatoa_GUI_Main.refresh_GUI())catch()
		try(Krakatoa_GUI_Main.update2009VFBControls side:#left)catch()
		try(Krakatoa_GUI_Channels.updateMemChannels())catch()
	)
)
