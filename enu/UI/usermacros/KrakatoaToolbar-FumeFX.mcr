macroScript FumeFX category:"KrakatoaToolbar" tooltip:"Render FumeFX" icon:#("KrakatoaTools",22) --FIXME!
(
	on isEnabled return (renderers.current.classid as string == "#(-1204370534, -399920359)")
	on isChecked return try(FranticParticles.getBoolProperty "RenderFumeFX")catch(false)
	on execute do (
		try(
			FranticParticles.setProperty "RenderFumeFX" ((not (FranticParticles.getBoolProperty "RenderFumeFX")) as string)
			Krakatoa_GUI_Main.refresh_GUI()
			Krakatoa_GUI_Main.update2009VFBControls side:#right
		)catch()
	)
)
