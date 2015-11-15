macroScript RND category:"KrakatoaToolbar" tooltip:"Render Scene Particles" icon:#("KrakatoaTools",20)
(
	on isEnabled return (renderers.current.classid as string == "#(-1204370534, -399920359)")
	on isChecked return try((FranticParticles.getProperty "ParticleMode") == "Render Scene Particles")catch(false)
	on execute do (
		try(
			local oldMode = (FranticParticles.getProperty "ParticleMode")
			if oldMode == "Render Scene Particles"  then
				FranticParticles.setProperty "ParticleMode" "Save Particles To File Sequence"
			else
				FranticParticles.setProperty "ParticleMode" "Render Scene Particles" 
			Krakatoa_GUI_Main.refresh_GUI()
		)catch()
	)
)
