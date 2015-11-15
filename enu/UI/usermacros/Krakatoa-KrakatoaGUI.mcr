macroScript KrakatoaGUI category:"Krakatoa" tooltip:"Toggle Krakatoa Scripted GUI On/Off" buttontext:"Krakatoa GUI" icon:#("Krakatoa",1)
(
	global KrakatoaGuiOpen
	if KrakatoaGuiOpen== undefined do KrakatoaGuiOpen= true
	on isChecked return try(Krakatoa_Gui_floater.open And KrakatoaGuiOpen)catch(false)
	on isEnabled return try(FranticParticles.Version != undefined)catch(false)
	on execute do
	(
		if try(Krakatoa_Gui_floater.open)catch(false) then
			try(closeRolloutFloater Krakatoa_Gui_floater)catch()
		else
			try(FranticParticleRenderMXS.OpenGUI() )catch(messagebox ("Failed To Launch Krakatoa GUI:\n" + getCurrentException()) title:"Krakatoa Error")
	)
)
