macroScript PRTV category:"KrakatoaToolbar" tooltip:"Render PRT Volumes" icon:#("KrakatoaTools",21) 
(
	on isEnabled return (renderers.current.classid as string == "#(-1204370534, -399920359)")
	on isChecked return try(FranticParticles.getBoolProperty "RenderGeometryVolumes")catch(false)
	on execute do (
		try(
			FranticParticles.setProperty "RenderGeometryVolumes" ((not (FranticParticles.getBoolProperty "RenderGeometryVolumes")) as string)
			Krakatoa_GUI_Main.refresh_GUI()
			Krakatoa_GUI_Main.update2009VFBControls side:#right
		)catch()
	)
)
