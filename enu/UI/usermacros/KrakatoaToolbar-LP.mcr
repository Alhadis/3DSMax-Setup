macroScript LP category:"KrakatoaToolbar" tooltip:"Render Legacy Particles" icon:#("KrakatoaTools",15)
(
	on isEnabled return (renderers.current.classid as string == "#(-1204370534, -399920359)")
	on isChecked return try(FranticParticles.getBoolProperty "RenderMaxParticles")catch(false)
	on execute do (
		try(
			FranticParticles.setProperty "RenderMaxParticles" ((not (FranticParticles.getBoolProperty "RenderMaxParticles")) as string)
			Krakatoa_GUI_Main.refresh_GUI()
			Krakatoa_GUI_Main.update2009VFBControls side:#right
		)catch()
	)
)
