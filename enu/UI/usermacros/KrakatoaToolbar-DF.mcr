macroScript DF category:"KrakatoaToolbar" tooltip:"Depth Of Field Toggle" icon:#("KrakatoaTools",2)
(
	on isEnabled return (renderers.current.classid as string == "#(-1204370534, -399920359)")
	on isChecked return try(FranticParticles.getBoolProperty "EnableDepthOfField")catch(false)
	on execute do (
		try(
			FranticParticles.setProperty "EnableDepthOfField" ((not (FranticParticles.getBoolProperty "EnableDepthOfField")) as string)
			Krakatoa_GUI_Main.refresh_GUI()
		)catch()
	)
)
