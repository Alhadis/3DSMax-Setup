macroScript AllocateGlossinessChannel category:"KrakatoaToolbar" tooltip:"Allocate Glossiness Channel Toggle" icon:#("KrakatoaTools",27)
(
	on isEnabled return (renderers.current.classid as string == "#(-1204370534, -399920359)")
	on isChecked return try(FranticParticles.getBoolProperty "Channel:Allocate:Glossiness")catch(false)
	on execute do (
		try(FranticParticles.setProperty "Channel:Allocate:Glossiness" ((not (FranticParticles.getBoolProperty "Channel:Allocate:Glossiness")) as string))catch()
		try(Krakatoa_GUI_Main.refresh_GUI())catch()
		try(Krakatoa_GUI_Main.update2009VFBControls side:#left)catch()
		try(Krakatoa_GUI_Channels.updateMemChannels())catch()
	)
)
