macroScript SAV category:"KrakatoaToolbar" tooltip:"Save Particles To Disk Mode" icon:#("KrakatoaTools",19)
(
	on isEnabled return (renderers.current.classid as string == "#(-1204370534, -399920359)")
	on isChecked return try((FranticParticles.getProperty "ParticleMode") == "Save Particles To File Sequence")catch(false)
	on execute do (
		try(
			local oldMode = (FranticParticles.getProperty "ParticleMode")
			if oldMode == "Save Particles To File Sequence" then
				FranticParticles.setProperty "ParticleMode" "Render Scene Particles"
			else
				FranticParticles.setProperty "ParticleMode" "Save Particles To File Sequence"
			Krakatoa_GUI_Main.refresh_GUI()
		)catch()
	)
)
