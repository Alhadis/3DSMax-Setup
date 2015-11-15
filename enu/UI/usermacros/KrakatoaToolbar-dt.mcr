macroScript dt category:"KrakatoaToolbar" tooltip:"Deformation Motion Blur Toggle" icon:#("KrakatoaTools",23)
(
	on isEnabled return (renderers.current.classid as string == "#(-1204370534, -399920359)")
	on isChecked return try(FranticParticles.getBoolProperty "DeformationMotionBlur")catch(false)
	on execute do (
		try(
			FranticParticles.setProperty "DeformationMotionBlur" ((not (FranticParticles.getBoolProperty "DeformationMotionBlur")) as string)
			Krakatoa_GUI_Main.refresh_GUI()
		)catch()
	)
)
