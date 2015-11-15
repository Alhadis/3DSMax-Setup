macroScript PRTLoader category:"Krakatoa" tooltip:"PRT Loader - hold SHIFT to create at Origin" icon:#("Krakatoa",7)
(
	on isChecked return (mcrUtils.IsCreating KrakatoaPRTLoader)
	on execute do 
	(
		if keyboard.shiftPressed then
		(
			local newLoader = KrakatoaPRTLoader()
			if isValidNode newLoader do
			(
				select newLoader 
				local thePref = getIniSetting (GetDir #plugcfg + "\\Krakatoa\\KrakatoaPreferences.ini") "Preferences" "CreateLoadersBehavior"
				if thePref != "3" do try(newLoader.params.btn_addFiles.pressed())catch()
			)				
			max modify mode
		)	
		else
			StartObjectCreation KrakatoaPRTLoader
	)	
)
