macroScript AllocateEccentricityChannel category:"KrakatoaToolbar" tooltip:"Allocate Eccentricity Channel Toggle" icon:#("KrakatoaTools",28)
(
	on isEnabled return (renderers.current.classid as string == "#(-1204370534, -399920359)")
	on isChecked return try(FranticParticles.getBoolProperty "Channel:Allocate:PhaseEccentricity")catch(false)
	on execute do (
		try(FranticParticles.setProperty "Channel:Allocate:PhaseEccentricity" ((not (FranticParticles.getBoolProperty "Channel:Allocate:PhaseEccentricity")) as string))catch()
		try(Krakatoa_GUI_Main.refresh_GUI())catch()
		try(Krakatoa_GUI_Main.update2009VFBControls side:#left)catch()
		try(Krakatoa_GUI_Channels.updateMemChannels())catch()
	)
)
