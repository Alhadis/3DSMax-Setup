macroScript SchematicFlow category:"Krakatoa" icon:#("krakatoa",10) tooltip:"Krakatoa Schematic Flow"
(
	global Krakatoa_SchematicFlow_Rollout 
	global Krakatoa_updateSchematicFlow
	try(destroyDialog Krakatoa_SchematicFlow_Rollout)catch()
	
	local theTree = #()
	local showAllNodes = ((getInisetting (getDir #plugcfg + "\\Krakatoa\\KrakatoaPreferences.ini") "SchematicView" "ShowAllNodes" )!="false" )
	
	rcmenu Krakatoa_SchematicFlow_MainMenu
	(
		submenu "View"
		(
			menuitem mnu_ShowAllNodes "Show Inactive Nodes" checked:showAllNodes
		)
		menuitem mnu_Update "Update!" 
		on mnu_Update picked do Krakatoa_updateSchematicFlow()

		on mnu_ShowAllNodes picked do 
		(
			showAllNodes = not showAllNodes
			Krakatoa_updateSchematicFlow()
			setInisetting (getDir #plugcfg + "\\Krakatoa\\KrakatoaPreferences.ini") "SchematicView" "ShowAllNodes" (showAllNodes as string)
		)
	)
	
	local RightClickMenus 
	struct RightClickMenusStruct 
	(
		RenderNodeRCMenu,
		MemoryNodeRCMenu,
		MotionBlurNodeRCMenu,
		ShadingNodeRCMenu,
		SpecularPowerNodeRCMenu,
		SpecularLevelNodeRCMenu,
		PhaseEccentricityNodeRCMenu,
		
		DOFNodeRCMenu,
		EnvReflectionNodeRCMenu,
		APMENodeRCMenu,
		MatteObjectsNodeRCMenu,
		DepthMatteNodeRCMenu,
		ImageFileNodeRCMenu,
		AttenuationFileNodeRCMenu,
		BackgroundImageFileNodeRCMenu,
		
		VFBNodeRCMenu,
		
		ColorOverrideNodeRCMenu,
		EmissionOverrideNodeRCMenu,
		AbsorptionOverrideNodeRCMenu,
		DensityOverrideNodeRCMenu,
		
		ForceAdditiveModeNodeRCMenu,
		EmissionNodeRCMenu,
		AbsorptionNodeRCMenu,
		
		GetParticlesFromNodeRCMenu,
		LightsNodeRCMenu,
		ViewsNodeRCMenu,
		PRTLoadersNodeRCMenu,
		PRTVolumesNodeRCMenu,
		GeometryVerticesNodeRCMenu,
		LegacySystemsNodeRCMenu,
		TPNodeRCMenu,
		PFlowGeometryNodeRCMenu,
		PFlowPhantomNodeRCMenu,
		PFlowBBoxNodeRCMenu,
		FumeFXNodeRCMenu,
		ChannelOverrideNodeRCMenu,
		
		KCMsNodeRCMenu
	)
	
	RightClickMenus = RightClickMenusStruct()
	
	rcmenu RenderNodeRCMenu
	(
		menuitem mnu_RenderNow "RENDER FRAME NOW!" enabled:((FranticParticles.GetProperty "ParticleMode") != "Save Particles To File Sequence")
		separator sep_10
		menuitem mnu_RenderParticles "Particle Rendering" checked:((FranticParticles.GetProperty "RenderingMethod") == "Particle Rendering")
		menuitem mnu_RenderVoxes "Voxel Rendering" checked:((FranticParticles.GetProperty "RenderingMethod") == "Voxel Rendering")
		separator sep_20
		menuitem mnu_SaveSceneParticles "Save Particles To File Sequence" checked:((FranticParticles.GetProperty "ParticleMode") == "Save Particles To File Sequence")
		menuitem mnu_LightSceneParticles "Light Scene Particles" checked:((FranticParticles.GetProperty "ParticleMode") == "Light Scene Particles")
		
		on mnu_RenderNow picked do
		(
			if ((FranticParticles.GetProperty "ParticleMode") != "Save Particles To File Sequence") then 
			(
				local oldState = renderSceneDialog.isOpen()
				renderSceneDialog.close()
				
				local oldSaveFile = rendSaveFile 
				local oldTimeType = rendTimeType 
				
				rendSaveFile = false
				rendTimeType = 1
				local oldWidth = renderWidth
				local oldHeight = renderHeight
				
				local theScaleFactor = case (FranticParticles.GetProperty "IterativeRender:ScaleFactor") of
				(
					"2" : 2
					"1" : 1
					"1/2" : 0.5
					"1/4" : 0.25
					"1/8" : 0.125
					"1/16" : 0.0625
				)
				renderWidth = oldWidth*theScaleFactor
				renderHeight = oldHeight*theScaleFactor
				
				local oldDensity = FranticParticles.getFloatProperty "Density:DensityPerParticle"
				if FranticParticles.getProperty "Density:DensityMethod" != "Volumetric Density" and FranticParticles.getProperty "RenderingMethod" != "Voxel Rendering" do 
					FranticParticles.setProperty "Density:DensityPerParticle" (((oldDensity)*(theScaleFactor^2))as string)
				
				try
					(max quick render)
				catch
					(messagebox "KABOOM!\n3ds Max attempted to crash, but the Krakatoa GUI caught the exception.\nThis is usually a sign that there has been a memory problem or other instability inside the 3ds Max system\nand not necessarily something wrong with Krakatoa or your scene.\nPlease try to save a copy of your work and restart 3ds Max immediately.\n\nIf the problem persists, please contact Krakatoa Support - krakatoa-support@primefocusworld.com" message:"Krakatoa Prevented A Big Explosion!")

				FranticParticles.setProperty "Density:DensityPerParticle" (oldDensity as string)
				rendTimeType = oldTimeType 
				rendSaveFile = oldSaveFile 
				renderWidth = oldWidth 
				renderHeight = oldHeight
				if oldState do renderSceneDialog.Open()		
			)
		)
		
		on mnu_RenderParticles picked do 
		(
			FranticParticles.SetProperty "RenderingMethod" "Particle Rendering"
			FranticParticles.SetProperty "ParticleMode" "Render Scene Particles"
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
			try(Krakatoa_GUI_Channels.refresh_GUI())catch()
		)
		on mnu_RenderVoxes picked do 
		(
			FranticParticles.SetProperty "RenderingMethod" "Voxel Rendering"
			FranticParticles.SetProperty "ParticleMode" "Render Scene Particles"
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
			try(Krakatoa_GUI_Channels.refresh_GUI())catch()
		)		
		on mnu_SaveSceneParticles picked do 
		(
			if FranticParticles.GetProperty "ParticleMode" != "Save Particles To File Sequence" then
			(
				FranticParticles.SetProperty "ParticleMode" "Save Particles To File Sequence"
				FranticParticles.SetProperty "RenderingMethod" "Particle Rendering"
			)
			else
				FranticParticles.SetProperty "ParticleMode" "Render Scene Particles"
			
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
			try(Krakatoa_GUI_Channels.refresh_GUI())catch()
		)				
		on mnu_LightSceneParticles picked do 
		(
			if FranticParticles.GetProperty "ParticleMode" != "Light Scene Particles" then
				FranticParticles.SetProperty "ParticleMode" "Light Scene Particles"
			else
				FranticParticles.SetProperty "ParticleMode" "Render Scene Particles"
			
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
			try(Krakatoa_GUI_Channels.refresh_GUI())catch()
		)				
		
	)
	
	RightClickMenus.RenderNodeRCMenu = RenderNodeRCMenu 
	
	rcmenu MemoryNodeRCMenu
	(
		menuItem mnu_enablePCache "Enable PCache" checked:(FranticParticles.GetBoolProperty "EnableParticleCache" ) enabled:((try(FranticParticles.GetCachedParticleCount())catch(0)) > 0)
		menuItem mnu_enableLCache "Enable LCache" checked:(FranticParticles.GetBoolProperty "EnableLightingCache" ) enabled:((try(FranticParticles.GetCachedParticleCount())catch(0)) > 0)

		on mnu_enablePCache picked do 
		(
			FranticParticles.SetProperty "EnableParticleCache" ((not (FranticParticles.GetBoolProperty "EnableParticleCache" )) as string)
			if not (FranticParticles.GetBoolProperty "EnableParticleCache" ) do
				FranticParticles.SetProperty "EnableLightingCache" "false"
			
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
		)		
		on mnu_enableLCache picked do 
		(
			FranticParticles.SetProperty "EnableLightingCache" ((not (FranticParticles.GetBoolProperty "EnableLightingCache" )) as string)
			if (FranticParticles.GetBoolProperty "EnableLightingCache" ) do
				FranticParticles.SetProperty "EnableParticleCache" "true"
			
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
		)			
	)
	
	RightClickMenus.MemoryNodeRCMenu = MemoryNodeRCMenu 
	
	rcmenu ShadingNodeRCMenu
	(
		menuItem mnu_isotropic "Isotropic" checked:(matchpattern (FranticParticles.GetProperty "PhaseFunction") pattern:"Isotropic" )
		menuItem mnu_phong "Phong Surface" checked:(matchpattern (FranticParticles.GetProperty "PhaseFunction") pattern:"Phong*" )
		menuItem mnu_hengreen "Henyey-Greenstein" checked:(matchpattern (FranticParticles.GetProperty "PhaseFunction") pattern:"Henyey*" )
		menuItem mnu_schlick "Schlick" checked:(matchpattern (FranticParticles.GetProperty "PhaseFunction") pattern:"Schlick" )
		
		on mnu_isotropic picked do
		(
			FranticParticles.SetProperty "PhaseFunction" "Isotropic"
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
			try(Krakatoa_GUI_Channels.refresh_GUI())catch()
		)
		
		on mnu_phong picked do
		(
			FranticParticles.SetProperty "PhaseFunction" "Phong Surface"
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
			try(Krakatoa_GUI_Channels.refresh_GUI())catch()
		)		

		on mnu_hengreen picked do
		(
			FranticParticles.SetProperty "PhaseFunction" "Henyey-Greenstein"
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
			try(Krakatoa_GUI_Channels.refresh_GUI())catch()
		)		

		on mnu_schlick picked do
		(
			FranticParticles.SetProperty "PhaseFunction" "Schlick"
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
			try(Krakatoa_GUI_Channels.refresh_GUI())catch()
		)				
	)
	RightClickMenus.ShadingNodeRCMenu = ShadingNodeRCMenu 
	
	
	rcmenu SpecularPowerNodeRCMenu 
	(
		menuitem mnu_toggle "Allocate SpecularPower Channel" checked:(FranticParticles.GetBoolProperty "Channel:Allocate:SpecularPower")
		on mnu_toggle picked do
		(
			FranticParticles.SetProperty "Channel:Allocate:SpecularPower" (not (FranticParticles.GetBoolProperty "Channel:Allocate:SpecularPower" ))
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
			try(Krakatoa_GUI_Channels.refresh_GUI())catch()			
		)
	)
	RightClickMenus.SpecularPowerNodeRCMenu = SpecularPowerNodeRCMenu
	
	rcmenu SpecularLevelNodeRCMenu 
	(
		menuitem mnu_toggle "Allocate SpecularLevel Channel" checked:(FranticParticles.GetBoolProperty "Channel:Allocate:SpecularLevel")
		on mnu_toggle picked do
		(
			FranticParticles.SetProperty "Channel:Allocate:SpecularLevel" (not (FranticParticles.GetBoolProperty "Channel:Allocate:SpecularLevel" ))
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
			try(Krakatoa_GUI_Channels.refresh_GUI())catch()			
		)		
	)
	RightClickMenus.SpecularLevelNodeRCMenu = SpecularLevelNodeRCMenu

	rcmenu PhaseEccentricityNodeRCMenu 
	(
		menuitem mnu_toggle "Allocate PhaseEccentricity Channel" checked:(FranticParticles.GetBoolProperty "Channel:Allocate:PhaseEccentricity")
		on mnu_toggle picked do
		(
			FranticParticles.SetProperty "Channel:Allocate:PhaseEccentricity" (not (FranticParticles.GetBoolProperty "Channel:Allocate:PhaseEccentricity" ))
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
			try(Krakatoa_GUI_Channels.refresh_GUI())catch()			
		)			
	)
	RightClickMenus.PhaseEccentricityNodeRCMenu = PhaseEccentricityNodeRCMenu
	

	rcmenu MotionBlurNodeRCMenu
	(
		menuItem mnu_enableMBlur "Enable Motion Blur" checked:(FranticParticles.GetBoolProperty "EnableMotionBlur" )
		separator sep_10
		menuItem mnu_enableJitteredMBlur "Jittered Motion Blur" checked:(FranticParticles.GetBoolProperty "JitteredMotionBlur" )
		menuItem mnu_enableDeformMBlur "Deformation Motion Blur" checked:(FranticParticles.GetBoolProperty "DeformationMotionBlur" )
		
		on mnu_enableMBlur picked do 
		(
			FranticParticles.SetProperty "EnableMotionBlur" ((not (FranticParticles.GetBoolProperty "EnableMotionBlur" )) as string)
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
			try(Krakatoa_GUI_Channels.refresh_GUI())catch()
		)	
		on mnu_enableJitteredMBlur picked do 
		(
			FranticParticles.SetProperty "JitteredMotionBlur" ((not (FranticParticles.GetBoolProperty "JitteredMotionBlur" )) as string)
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
			try(Krakatoa_GUI_Channels.refresh_GUI())catch()
		)	
		on mnu_enableDeformMBlur picked do 
		(
			FranticParticles.SetProperty "DeformationMotionBlur" ((not (FranticParticles.GetBoolProperty "DeformationMotionBlur" )) as string)
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
			try(Krakatoa_GUI_Channels.refresh_GUI())catch()
		)			
	)
	
	RightClickMenus.MotionBlurNodeRCMenu =MotionBlurNodeRCMenu
	
	rcmenu DOFNodeRCMenu
	(
		fn canAddKrakatoaCameraMod = viewport.getCamera() != undefined and (for m in (viewport.getCamera()).modifiers where classof m == KrakatoaCameraModifier collect m).count == 0
		menuItem mnu_enableDOF "Enable Depth Of Field" checked:(FranticParticles.GetBoolProperty "EnableDepthOfField" )
		separator sep_10 filter:canAddKrakatoaCameraMod
		menuItem mnu_addCameraModifier "FIX:Add Krakatoa Camera Modifier..." filter:canAddKrakatoaCameraMod
		
		on mnu_enableDOF picked do 
		(
			FranticParticles.SetProperty "EnableDepthOfField" ((not (FranticParticles.GetBoolProperty "EnableDepthOfField" )) as string)
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
		)			

		on mnu_addCameraModifier picked do
		(
			local theCamera = viewport.getCamera() 
			local theMod = KrakatoaCameraModifier dofOn:true
			addModifier theCamera theMod
			max modify mode
			select theCamera
		)
	)
	RightClickMenus.DOFNodeRCMenu = DOFNodeRCMenu
	
	rcmenu EnvReflectionNodeRCMenu 
	(
		menuItem mnu_enableReflections "Enable Environment Reflections" checked:(FranticParticles.GetBoolProperty "UseEnvironmentReflections" )
		on mnu_enableReflections picked do 
		(
			FranticParticles.SetProperty "UseEnvironmentReflections" ((not (FranticParticles.GetBoolProperty "UseEnvironmentReflections" )) as string)
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
			try(Krakatoa_GUI_Channels.refresh_GUI())catch()
		)			
	)
	RightClickMenus.EnvReflectionNodeRCMenu = EnvReflectionNodeRCMenu
	
	
	rcmenu APMENodeRCMenu 
	(
		menuItem mnu_enableAPME "Enable Ambient PME" checked:(FranticParticles.GetBoolProperty "PME:UseExtinction" )
		on mnu_enableAPME picked do 
		(
			FranticParticles.SetProperty "PME:UseExtinction" ((not (FranticParticles.GetBoolProperty "PME:UseExtinction" )) as string)
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
		)			
	)
	RightClickMenus.APMENodeRCMenu = APMENodeRCMenu
	
	rcmenu DepthMatteNodeRCMenu 
	(
		menuItem mnu_enableDepthMapMatte "Enable Depth Map Matte" checked:(FranticParticles.GetBoolProperty "Matte:UseDepthMapFiles" )
		on mnu_enableDepthMapMatte picked do 
		(
			FranticParticles.SetProperty "Matte:UseDepthMapFiles" ((not (FranticParticles.GetBoolProperty "Matte:UseDepthMapFiles" )) as string)
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
		)				
		
	)
	
	RightClickMenus.DepthMatteNodeRCMenu  = DepthMatteNodeRCMenu 
	
	rcmenu MatteObjectsNodeRCMenu 
	(
		menuItem mnu_enableMatteObjects "Enable Matte Objects" checked:(FranticParticles.GetBoolProperty "Matte:UseMatteObjects" )
		
		on mnu_enableMatteObjects picked do 
		(
			FranticParticles.SetProperty "Matte:UseMatteObjects" ((not (FranticParticles.GetBoolProperty "Matte:UseMatteObjects" )) as string)
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
		)				
	)
	RightClickMenus.MatteObjectsNodeRCMenu = MatteObjectsNodeRCMenu
	
	rcmenu VFBNodeRCMenu 
	(
		menuItem mnu_enableVFB "Virtual Frame Buffer (Rendered Frame Window)" checked:(rendshowVFB)
		on mnu_enableVFB picked do 
		(
			renderSceneDialog.close()
			rendshowVFB = not rendshowVFB
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
		)			
	)
	RightClickMenus.VFBNodeRCMenu = VFBNodeRCMenu
	
	
	rcmenu AttenuationFileNodeRCMenu
	(
		menuItem mnu_enableAttenuationFile "Save Attenuation Map Image File" checked:(FranticParticles.GetBoolProperty "EnableAttenuationMapSaving" )
		on mnu_enableAttenuationFile picked do 
		(
			FranticParticles.SetProperty "EnableAttenuationMapSaving" ((not (FranticParticles.GetBoolProperty "EnableAttenuationMapSaving" )) as string)
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
		)			
	)
	RightClickMenus.AttenuationFileNodeRCMenu = AttenuationFileNodeRCMenu
	
	rcmenu ImageFileNodeRCMenu
	(
		menuItem mnu_enableImageFile "Save Image File" checked:(rendSaveFile)
		separator sep_10
		menuItem mnu_SelectImageFile "Set Render Output Filename..."  checked:(rendOutputFilename!="")
		
		on mnu_enableImageFile picked do 
		(
			renderSceneDialog.close()
			rendSaveFile = not rendSaveFile
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
		)		

		on mnu_SelectImageFile picked do
		(
			local oldState = renderSceneDialog.isOpen()
			local keepOpen = ((getIniSetting (GetDir #plugcfg + "\\Krakatoa\\KrakatoaPreferences.ini") "Preferences" "KeepRenderSceneDialogOpen")=="true")
			renderSceneDialog.close()
			theBitmapPath = getBitmapSaveFileName filename:rendOutputFilename
			if theBitmapPath != undefined do
			(
				rendOutputFilename = theBitmapPath 
				rendSaveFile = true
			)	
			if oldState and keepOpen do renderSceneDialog.open()	
			try(Krakatoa_updateSchematicFlow())catch()
		)
			
	)
	RightClickMenus.ImageFileNodeRCMenu = ImageFileNodeRCMenu
	
	rcmenu BackgroundImageFileNodeRCMenu
	(
		menuItem mnu_saveMultipleLayers "Save Background Image File" checked:(FranticParticles.GetBoolProperty "Matte:SaveMultipleLayers")
		on mnu_saveMultipleLayers picked do 
		(
			FranticParticles.SetProperty "Matte:SaveMultipleLayers" ((not (FranticParticles.GetBoolProperty "Matte:SaveMultipleLayers" )) as string)
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
		)					
		
	)
	RightClickMenus.BackgroundImageFileNodeRCMenu = BackgroundImageFileNodeRCMenu
	
	
	rcmenu ColorOverrideNodeRCMenu
	(
		menuItem mnu_overrideColor "Override Color Channel" checked:(FranticParticles.GetBoolProperty "ColorOverride:Enabled")
		on mnu_overrideColor picked do 
		(
			FranticParticles.SetProperty "ColorOverride:Enabled" ((not (FranticParticles.GetBoolProperty "ColorOverride:Enabled" )) as string)
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
			try(Krakatoa_GUI_Channels.refresh_GUI())catch()
		)	
	)
	RightClickMenus.ColorOverrideNodeRCMenu = ColorOverrideNodeRCMenu
	rcmenu EmissionOverrideNodeRCMenu
	(
		menuItem mnu_overrideEmission "Override Emission Channel" checked:(FranticParticles.GetBoolProperty "EmissionOverride:Enabled")
		on mnu_overrideEmission picked do 
		(
			FranticParticles.SetProperty "EmissionOverride:Enabled" ((not (FranticParticles.GetBoolProperty "EmissionOverride:Enabled" )) as string)
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
			try(Krakatoa_GUI_Channels.refresh_GUI())catch()
		)	
	)	
	RightClickMenus.EmissionOverrideNodeRCMenu = EmissionOverrideNodeRCMenu
	rcmenu AbsorptionOverrideNodeRCMenu
	(
		menuItem mnu_overrideAbsorption "Override Absorption Channel" checked:(FranticParticles.GetBoolProperty "AbsorptionOverride:Enabled")

		on mnu_overrideAbsorption picked do 
		(
			FranticParticles.SetProperty "AbsorptionOverride:Enabled" ((not (FranticParticles.GetBoolProperty "AbsorptionOverride:Enabled" )) as string)
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
			try(Krakatoa_GUI_Channels.refresh_GUI())catch()
		)	
	)		
	RightClickMenus.AbsorptionOverrideNodeRCMenu = AbsorptionOverrideNodeRCMenu
	
	rcmenu DensityOverrideNodeRCMenu
	(
		menuItem mnu_overrideDensity "Override Density Channel" checked:(FranticParticles.GetBoolProperty "DensityOverride:Enabled")
		on mnu_overrideDensity picked do 
		(
			FranticParticles.SetProperty "DensityOverride:Enabled" ((not (FranticParticles.GetBoolProperty "DensityOverride:Enabled" )) as string)
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
			try(Krakatoa_GUI_Channels.refresh_GUI())catch()
		)			
	)
	RightClickMenus.DensityOverrideNodeRCMenu = DensityOverrideNodeRCMenu
	
	
	rcmenu ForceAdditiveModeNodeRCMenu
	(
		menuItem mnu_ForceAdditive "Force Additive Mode" checked:(FranticParticles.GetBoolProperty "AdditiveMode")
		on mnu_ForceAdditive picked do 
		(
			FranticParticles.SetProperty "AdditiveMode" ((not (FranticParticles.GetBoolProperty "AdditiveMode" )) as string)
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
			try(Krakatoa_GUI_Channels.refresh_GUI())catch()
		)	
	)
	RightClickMenus.ForceAdditiveModeNodeRCMenu = ForceAdditiveModeNodeRCMenu	
	
	rcmenu EmissionNodeRCMenu
	(
		menuItem mnu_UseEmission "Use Emission" checked:(FranticParticles.GetBoolProperty "UseEmissionColor") enabled:(not (FranticParticles.GetBoolProperty "AdditiveMode"))

		on mnu_UseEmission picked do 
		(
			FranticParticles.SetProperty "UseEmissionColor" ((not (FranticParticles.GetBoolProperty "UseEmissionColor" )) as string)
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
			try(Krakatoa_GUI_Channels.refresh_GUI())catch()
		)	
	)
	RightClickMenus.EmissionNodeRCMenu = EmissionNodeRCMenu
	
	rcmenu AbsorptionNodeRCMenu
	(	
		menuItem mnu_UseAbsorption "Use Absorption" checked:(FranticParticles.GetBoolProperty "UseFilterColor") enabled:(not (FranticParticles.GetBoolProperty "AdditiveMode"))

		on mnu_UseAbsorption picked do 
		(
			FranticParticles.SetProperty "UseFilterColor" ((not (FranticParticles.GetBoolProperty "UseFilterColor" )) as string)
			Krakatoa_updateSchematicFlow()
			try(Krakatoa_GUI_Main.refresh_GUI())catch()
			try(Krakatoa_GUI_Channels.refresh_GUI())catch()
		)
		
	)
	RightClickMenus.AbsorptionNodeRCMenu = AbsorptionNodeRCMenu
	
	/*
	rcmenu GetParticlesFromNodeRCMenu 
	(
		menuItem mnu_ForceAdditive "Force Additive Mode" checked:(FranticParticles.GetBoolProperty "AdditiveMode")
		
	)
	RightClickMenus.GetParticlesFromNodeRCMenu = GetParticlesFromNodeRCMenu
	*/
	
	rollout Krakatoa_SchematicFlow_Rollout "Krakatoa Schematic Flow" width:900
	(
		local inputCount = 0
		local nextOffset = #(0,0)
		local theOriginX = 780
		local theTreeHeight = 0
		local theMemoryPoolIndex = 0
		
		SchematicControl hc "" width:900 height:600 pos:[0,0] 
		--edittext edt_info readOnly:true
		
		fn getNextOffset =
		(
			if inputCount >= 3 then
			(
				inputCount = 0
				nextOffset =#(150,-100)
			)
			else
				nextOffset = #(30,50)			
		)
		
		fn defineMenu menuName theNodes thePropName =
		(
			local txt = "rcmenu  "+menuName+" (\n"
			txt+="fn filterSeparator = ("+theNodes.count as string + " > 0) \n"
			txt+="menuItem mnu_enable_type \"Enabled For Rendering\" checked:(FranticParticles.GetBoolProperty \""+thePropName+"\")\n"
			txt+="on mnu_enable_type picked do (\n"
			txt+="FranticParticles.SetProperty \""+thePropName+"\" (not (FranticParticles.GetBoolProperty \""+thePropName+"\"))\n"
			txt+="try(Krakatoa_GUI_Main.refresh_GUI())catch()\n"
			txt+="Krakatoa_updateSchematicFlow())\n"
			
			txt+="separator sep_10 filter:filterSeparator\n"
			local cnt = 0
			for aNode in theNodes do
			(
				cnt+=1
				local theName = (if aNode.isHiddenInVpt then "-- " else if aNode.renderable then "+ " else "-r ") +  aNode.name 
				if not aNode.renderable then 
					theName += " [object not renderable]"
				else if aNode.isNodeHidden then 
					theName += " [object hidden]"
				else if aNode.isHidden then 
					theName += " [layer hidden]"
				if aNode.isFrozen and maxOps.hideFrozenObjects then 
					theName += " [hide frozen]"
				else if aNode.isHiddenInVpt and not aNode.isNodeHidden and not aNode.isHidden then theName += " [hidden by category]"
				
					
				txt+= "menuItem mnu_node_" + cnt as string + " \""+ theName + "\" \n"
				txt+= "on mnu_node_" + cnt as string + " picked do (\n"
				txt+= "if keyboard.controlPressed then \n"
				txt+= "try(max modify mode;modPanel.setCurrentObject ((getNodeByName \""+aNode.name +"\").baseobject); (getNodeByName \""+aNode.name +"\").isHidden = not (getNodeByName \""+aNode.name +"\").isHidden; Krakatoa_updateSchematicFlow())catch() \n" 
				txt += "else\n"
				txt+= "try(max modify mode;modPanel.setCurrentObject ((getNodeByName \""+aNode.name +"\").baseobject))catch() \n" 
				txt += ")\n"
			)
			txt += ")\n"
			execute txt						
		)
		
		
		fn defineTree =
		(
			theTree = #()
			local legacyParticles = #(PArray, PCloud, SuperSpray, Blizzard, Snow, Spray)
			local imageBuffers = #()
			local enableNode = false
			local theCacheCount = try(FranticParticles.GetCachedParticleCount())catch(0)
			local theMemory = try(FranticParticles.getCacheSize())catch(0)
			local theSceneLights = for o in objects where findItem light.classes (classof o) > 0 collect o
			local theActiveLights = (for o in theSceneLights where o.on collect o)
			local theActiveVoxelLights = (for o in theActiveLights where  classof o != OmniLight collect o)
			local theActiveOmniLights = (for o in theActiveLights where classof o == OmniLight collect o)
			local lightsAreOff = FranticParticles.getBoolProperty "IgnoreSceneLights" 
			
			local txt = "rcmenu LightsNodeRCMenu (\n"
			txt+= "menuItem mnu_ignoreSceneLights \"Ignore Scene Lights\" checked:(FranticParticles.GetBoolProperty \"IgnoreSceneLights\")\n"
			
			txt+= "on mnu_ignoreSceneLights picked do (\n"
			txt+= "FranticParticles.SetProperty \"IgnoreSceneLights\" (not (FranticParticles.GetBoolProperty \"IgnoreSceneLights\")) \n"
			txt+= "try(Krakatoa_GUI_Main.Refresh_GUI())catch()\n)\n"			
			txt+="separator sep_10 \n"
			
			if theActiveOmniLights.count > 0 and not lightsAreOff then
			(
				txt+= "menuItem mnu_disableOmnis \"FIX:Turn Off Omni Lights\"\n"
				txt+= "on mnu_disableOmnis picked do ((for o in objects where classof o.baseobject == OmniLight do o.on = off); Krakatoa_updateSchematicFlow())\n"
				txt+= "separator sep_20 \n"
			)			
				
			local cnt = 0
			for aLight in theSceneLights do
			(
				cnt+=1
				local theName = if (isProperty aLight #on and aLight.on) or (isProperty aLight #enabled and aLight.enabled) then "+ " else "-- " 
				theName += aLight.name 
				txt+= "menuItem mnu_light_" + cnt as string + " \""+ theName + "\" checked:("+ aLight.isSelected as string +")\n"
				txt+= "on mnu_light_" + cnt as string + " picked do (\n"
				txt+= "try(select (getNodeByName \""+aLight.name +"\");max modify mode)catch() \n"
				txt += ")\n"
			)
			if theSceneLights.count > 0 do txt+= "separator sep_30 \n"
			
			--if theSceneLights.count == 0 or (theActiveVoxelLights.count== 0)  do 
			(
				txt+= "menuItem mnu_defaultLight \"Create Default Spotlight\" \n"
				txt+= "on mnu_defaultLight picked do (\n"
				txt+= "local theTarget = TargetObject pos:[0,0,0]\n"
				txt+= "local theSpot = TargetSpot target:theTarget pos:[-1000,0,1000]\n"
				txt+= "theTarget.name = theSpot.name + \".Target\"\n"
				txt+= "max modify mode \n select theSpot\n"
				txt+= "Krakatoa_updateSchematicFlow()\n"
				txt+= ")\n"
				txt+= "separator sep_40 \n"
			)
			
			txt+= "menuItem mnu_lightLister \"Open Light Lister...\" \n"
			txt+= "on mnu_lightLister picked do macros.run \"Lights and Cameras\" \"Light_List\"\n"
			txt += ")\n"
			RightClickMenus.LightsNodeRCMenu = execute txt			
			
			
			local hasLights = if theActiveLights.count > 0 then 1.0 else 0.5
			/*if showLights do
			(
				append theTree #("Scene Lights", #(), #(color 255  235 225, [110,45],false,true),undefined, #("Light","Light"), #(theOriginX,0), "Illuminate Particles")
			)*/
				
			if (FranticParticles.GetProperty "ParticleMode") == "Save Particles To File Sequence" do
			(
					local theColor = color 255  255 150
					local theInfo = "Saves particle files (.PRT, .CSV or .BIN) to disk."
					if FranticParticles.GetProperty "ParticleFiles" == "" do 
					(
						theColor = red
						theInfo = "ERROR: The Save Particles filename is empty - no files can be saved!"
					)
					append theTree #("Particle File Output", #(theTree.count+2), #(theColor, [110,45],false,true),#(120,0), #("Particles","Particles"), undefined, theInfo)
					

					if FranticParticles.GetBoolProperty "SaveLightingAsEmission" then
					(
						theColor = (color 255 200 255)
						theInfo = "Copies the internal Light channel into the particles' Emission channel to be saved to disk."
						enableNode = not (FranticParticles.GetBoolProperty "IgnoreSceneLights")
						if theActiveLights.count == 0 do
						(
							theColor = color 255 50 50
							theInfo = "WARNING: No light in the scene, no Lighting data will be saved to the Emission channel!"
						)
						if not enableNode do 
						(
							theColor = (color 255 50 50)
							theInfo = "WARNING: Lighting is disabled, no lighting channel will be generated and saved."
						)
						if enableNode or showAllNodes do 
						(
							append theTree #("Light To Emission", #(theTree.count+2), #(theColor, [110,45], false, false), #(120,0) , #("Particles","Particles"), undefined , theInfo )
							append theTree #("Attenuation", #(theTree.count+2), #((color 255 200 150)*(if enableNode then 1 else 0.1), [110,45]), #(120,0) , #("Lit Particles","Particles"), undefined, "Calculates Attenuation of Light as it passes through the particle cloud." )
							append theTree #("Sort For "+theActiveLights.count as string+ (if theActiveLights.count == 1 then " Light" else " Lights"), #(theTree.count+2), #((color 220 220 240)*(if enableNode then 1 else 0.1), [110,45], false, false), #(120,0) , #("Sorted Particles","Particles"), #(0,0,10,0), "" )
						)
					)		
					else append imageBuffers theTree.count	
				
			)
			if (FranticParticles.GetProperty "ParticleMode") == "Light Scene Particles" do
			(
				(
					local hasImageOutput = rendOutputFilename != ""
					local ImageOutputEnabled = rendSaveFile == true 
					local iterativeRendererOff = FranticParticles.getBoolProperty "IterativeRender" == false
					local imageOutputEnabled =(ImageOutputEnabled and hasImageOutput and iterativeRendererOff)
					local particleRendering = (FranticParticles.GetProperty "RenderingMethod") == "Particle Rendering"
					local nodeEnabled = (FranticParticles.GetBoolProperty "EnableAttenuationMapSaving")
					if imageOutputEnabled  or showAllNodes do 
					(
						local theColor = (color 255 255 150)
						if not imageOutputEnabled do theColor = color 255 50 50
						local theInfo = "Saves Attenuation Maps To EXR Files in the \Shadows sub-folder of the current output path."
						if not hasImageOutput then 
							theInfo = "WARNING: Valid Output Image Path must be specified for Attenuation Maps to be saved!"
						else if not ImageOutputEnabled then 
							theInfo = "WARNING: Output Image Saving must be enabled for Attenuation Maps to be saved!"
						
						if not particleRendering do theInfo = "Attenuation Maps are not supported in Voxel Mode."
							
						if nodeEnabled or showAllNodes do 
						(
							append theTree #("Attenuation File", #(theTree.count+2), #(theColor*(if nodeEnabled then 1 else 0.1), [110,45]),#(120,0), #("Pixels","Pixels"), undefined, theInfo )
							--append imageBuffers theTree.count	
						)
					)
					enableNode = not (FranticParticles.GetBoolProperty "IgnoreSceneLights")
					if enableNode or showAllNodes do 
					(
						append theTree #("Attenuation", #(theTree.count+2), #((color 255 200 150)*(if enableNode then 1 else 0.1), [110,45]), #(120,0) , #("Lit Particles","Particles") )
						append theTree #("Sort For "+theActiveLights.count as string+ (if theActiveLights.count == 1 then " Light" else " Lights"), #(theTree.count+2), #((color 220 220 240)*(if enableNode then 1 else 0.1), [110,45], false, false), #(120,0) , #("Sorted Particles","Particles"), #(0,0,10,0) )
					)
					
					--append theTree #("Frame Buffer", #(theTree.count+2), #(color 255  255 150, [110,45],true,true),#(120,0), #("Pixels","Pixels"))
					--append imageBuffers theTree.count	
				)
			)			
			
			if (FranticParticles.GetProperty "ParticleMode") == "Render Scene Particles" do
			(
				if rendShowVFB or showAllNodes do
				(
					append theTree #("Frame Buffer", #(), #((color 255  255 150)*(if rendShowVFB then 1 else 0.1), [110,45],false,true),#(120,0), #("Pixels","Pixels"))
					append imageBuffers theTree.count
				)
					
				local imageOutputEnabled =(rendSaveFile == true and rendOutputFilename != "" and FranticParticles.getBoolProperty "IterativeRender" == false)
				
				if imageOutputEnabled or showAllNodes do
				(
					local theColor = color 255 255 150
					local theInfo = if rendOutputFilename != "" then 
						if rendSaveFile then 
							("Will save to ["+rendOutputFilename +"]") 
						else
							("Would save to ["+rendOutputFilename +"] if enabled.") 
					else 
						("Would save the render output to an image file if specified.")
					append theTree #("Image File", #(), #(theColor*(if showAllNodes and not imageOutputEnabled then 0.1 else 1), [110,45],true,true),#(120,0), #("Pixels","Pixels"), undefined, theInfo)
					append imageBuffers theTree.count
						
						
					enableNode = FranticParticles.GetBoolProperty "Matte:SaveMultipleLayers"							
					if enableNode or 	showAllNodes do
					(
						local theInfo = if rendOutputFilename != "" then 
							if rendSaveFile then 
								if enableNode then
									("Will save the background layer to ["+rendOutputFilename +"]") 
								else
									("Would save the background layer to ["+rendOutputFilename +"] if enabled.") 
							else
								if enableNode then
									("Would save the background layer to ["+rendOutputFilename +"] if Image File saving were enabled.") 
								else
									("Would save the background layer to ["+rendOutputFilename +"] if enabled and if Image File saving were enabled.") 
						else 
							("Would save the background layer of the render output to an EXR file if specified.")						
						append theTree #("Background Image File", #(), #(theColor*(if showAllNodes and (not imageOutputEnabled or not enableNode) then 0.1 else 1), [110,45],true,true),#(120,0), #("Pixels","Pixels"), undefined, theInfo)
						append imageBuffers theTree.count							
					)
				)
				if (FranticParticles.GetProperty "RenderingMethod") == "Particle Rendering" then						
				(
					if (imageOutputEnabled and (FranticParticles.GetBoolProperty "EnableAttenuationMapSaving")) or showAllNodes do 
					(
						local theColor = color 255 255 150
						if (showAllNodes and not (FranticParticles.GetBoolProperty "EnableAttenuationMapSaving")) or not imageOutputEnabled do theColor *= 0.1
						append theTree #("Attenuation File", #(), #(theColor, [110,45],true,true),#(120,0), #("Pixels","Pixels"))
						append imageBuffers theTree.count
					)
				)
			)
			
			local willRender = if lightsAreOff then 
				(FranticParticles.GetBoolProperty "UseEmissionColor" or FranticParticles.GetBoolProperty "AdditiveMode") 
			else
				(theActiveLights.count > 0 or FranticParticles.GetBoolProperty "UseEmissionColor" or FranticParticles.GetBoolProperty "AdditiveMode") and theActiveOmniLights.count == 0
			
			
			if (FranticParticles.GetProperty "RenderingMethod") == "Particle Rendering" then
			(
				if (FranticParticles.GetProperty "ParticleMode") == "Light Scene Particles" do
				(
					imageBuffers = #()					
					append theTree #("RENDER PARTICLES", #(), #((color 200 220 255)*0.5, [110,45], false, true), undefined, #("",""), #(theOriginX,0,theOriginX,0), "No particles will be rendered in this mode, only Attenuation Maps will be saved." )
					theTree[theTree.count-1][2] = #(theTree.count+1)
				)
				if (FranticParticles.GetProperty "ParticleMode") == "Save Particles To File Sequence" do
				(
					imageBuffers = #()					
					append theTree #("RENDER PARTICLES", #(), #((color 200 220 255)*0.5, [110,45], false, true), undefined, #("",""), #(theOriginX,0,theOriginX,0), "No particles will be rendered in this mode, only Attenuation Maps will be saved." )
					theTree[theTree.count-1][2] = #(theTree.count+1)
				)				
				
				if (FranticParticles.GetProperty "ParticleMode") == "Render Scene Particles" do
				(
					local theInfo = if willRender then 
					(
						if lightsAreOff then
							"Lights are off, will Sort and Render the particles without Sorting for Lights." 
						else
							"Will Sort and calculate Attenuation Once per Light, then Sort and Render from Back to Front in Camera space." 
					)
					else 
						"WARNING: Particles will render BLACK RGB unless at least one Light is created or either Emission or Force Additive Mode is enabled."
					
					--local theColor = color 200 220 255
					append theTree #("RENDER PARTICLES", #(theTree.count+2), #((if willRender then (color 200 220 255) else (color 255 50 50)), [110,45], false, true), undefined, #("Pixels","Particles"), #(theOriginX,0,theOriginX,0), theInfo )
					for j in imageBuffers do theTree[j][2] = #(theTree.count)						
					imageBuffers = #()
				)
			)
			else
			(
				local theColor = (color 200 220 255) 
				local theInfo = ""
				if theActiveOmniLights.count > 0 and not lightsAreOff then 
				(
					theInfo = "ERROR: There are active Omni Lights in the scene, Voxel Mode will fail until they are turned off or removed." 
					theColor = (color 255 50 50)
				)
				else if willRender then 
				(
					if lightsAreOff then
						theInfo = "Lights are off, will Render the Voxel Grid once, one Slice Plane at a time, oriented im camera space." 
					else
						theInfo = "Will Render the Voxel Grid once per light, one Planar Slice at a time, oriented halfway between camera and light ." 
				)
				else 
				(
					theColor = color 255 50 50
					theInfo = "WARNING: Voxel Mode will NOT render unless at least one Light is created or Emission or Force Additive Mode is enabled."
				)
				append theTree #("RENDER VOXELS", #(theTree.count+2), #(theColor, [110,45], false, true), undefined, #("Pixels","Voxels"), #(theOriginX,0), theInfo )
				for j in imageBuffers do theTree[j][2] = #(theTree.count)						
				imageBuffers = #()

				enableNode =(FranticParticles.GetBoolProperty "UseEnvironmentReflections") 
				if enableNode or showAllNodes do 
				(
					local theColor = (color 255 200 150)  
					local theInfo = "Calculates an additional light source from the 3ds Max Environment Map using texel lookup along the particle normals."
					if enableNode and environmentMap == undefined do 
					(
						theColor = (color 255 50 50)
						theInfo = "WARNING: No Environment Reflections will be rendered because the Environment Map is not defined in the 3ds Max Environment Dialog."
					)
					append theTree #("Env.Reflection Pass", #(theTree.count+2), #(theColor*(if enableNode then 1 else 0.1), [110,45]), #(120,0) , #("Lit Voxels","Voxels"), undefined, theInfo )
				)
					
				enableNode = not (FranticParticles.GetBoolProperty "IgnoreSceneLights")
				if enableNode or showAllNodes do 
				(
					local theInfo = ""
					local theColor = (color 255 200 150)
					if theActiveVoxelLights.count == 0 then 
					(
						theColor = color 255 50 50
						theInfo = ("WARNING: There are no valid lights in the scene. " +(if theActiveOmniLights.count > 0 then "There are only Omni lights which are not supported in Voxel Mode." else "" ))
					)
					else if theActiveOmniLights.count > 0 then 
					(
						theColor = red
						theInfo = "WARNING: There are Omni Lights in the scene. The Voxel Rendering will FAIL until they are disabled/removed." 
					)
					else
					(
						theInfo = "One pass per active light will be rendered."
					)
					append theTree #(theActiveVoxelLights.count as string + (if theActiveVoxelLights.count == 1 then " Light Pass" else " Light Passes"), #(theTree.count+2), #(theColor*(if theActiveVoxelLights.count > 0 then 1 else 0.5)*(if enableNode then 1.0 else 0.1), [110,45]), #(120,0) , #("Lit Voxels","Voxels"), undefined, theInfo )
						
					/*	
					local txt = "rcmenu LightsNodeRCMenu (\n"
					txt+= "menuItem mnu_ignoreSceneLights \"Ignore Scene Lights\" checked:(FranticParticles.GetBoolProperty \"IgnoreSceneLights\")\n"
					
					txt+= "on mnu_ignoreSceneLights picked do (\n"
					txt+= "FranticParticles.SetProperty \"IgnoreSceneLights\" (not (FranticParticles.GetBoolProperty \"IgnoreSceneLights\")) \n"
					txt+= "try(Krakatoa_GUI_Main.Refresh_GUI())catch()\n)\n"
					if theSceneLights.count > 0 do txt+= "separator sep_10 \n"
						
					if theActiveOmniLights.count > 0 and not lightsAreOff then
					(
						txt+= "menuItem mnu_disableOmnis \"Turn Off Omni Lights\"\n"
						txt+= "on mnu_disableOmnis picked do ((for o in objects where classof o.baseobject == OmniLight do o.on = off); Krakatoa_updateSchematicFlow())\n"
						txt+= "separator sep_20 \n"
					)
					
					local cnt = 0
					for aLight in theSceneLights do
					(
						cnt+=1
						local theName = if (isProperty aLight #on and aLight.on) or (isProperty aLight #enabled and aLight.enabled) then "+ " else "-- " 
						theName += aLight.name 
						txt+= "menuItem mnu_light_" + cnt as string + " \""+ theName + "\" \n"
						txt+= "on mnu_light_" + cnt as string + " picked do (\n"
						txt+= "try(select (getNodeByName \""+aLight.name +"\");max modify mode)catch() \n"
						txt += ")\n"
					)
					
					txt+= "separator sep_30 \n"
					txt+= "menuItem mnu_lightLister \"Open Light Lister...\" \n"
					txt+= "on mnu_lightLister picked do macros.run \"Lights and Cameras\" \"Light_List\"\n"
					txt += ")\n"
					RightClickMenus.LightsNodeRCMenu = execute txt						
					*/
				)
				append theTree #("Particles To Grid", #(theTree.count+2), #(color 200 200 255, [110,45] ), #(120,0) , #("Voxels","Particles"), undefined, "Particles are being loaded onto the Grid for rendering. Cannot be turned off." )
			)						
				
			if (FranticParticles.GetProperty "ParticleMode") == "Render Scene Particles" do	
			(
				enableNode = FranticParticles.GetBoolProperty "Matte:UseMatteObjects"
				if enableNode or showAllNodes do
					append theTree #("Objects Matte", #(theTree.count+2), #((color 200 200 220)*(if enableNode then 1 else 0.1) , [110,45]), #(120,0) , #("Matted Particles","Particles")  )
				
				enableNode = FranticParticles.GetBoolProperty "Matte:UseDepthMapFiles"
				if enableNode or showAllNodes do
				(
					local theColor = (color 200 200 220)
					local theInfo = "Loads a sequence of Z-Depth files as initial value of the Matte buffer. Useful for matting out by rendertime-generated geometry from other renderers."
					local theFiles = FranticParticles.GetProperty "Matte:DepthMapFiles" 
					if theFiles == "" then
					(
						theColor = red
						theInfo = "ERROR: No Depth Matte Files have been specified. The Rendering will FAIL!"
					)
					else
					(
						if not (doesFileExist theFiles) then
						(
							theColor = red
							theInfo = "WARNING: The specified Depth Matte File could not be found."
						)
					)
					append theTree #("Depth Map Matte", #(theTree.count+2), #(theColor*(if enableNode then 1 else 0.1), [110,45]), #(120,0) , #("Matted Particles","Particles"), undefined, theInfo )
				)

				enableNode = FranticParticles.GetBoolProperty "PME:UseExtinction"
				if enableNode or showAllNodes do
					append theTree #("Ambient PME", #(theTree.count+2), #((color 255 200 150)*(if enableNode then 1 else 0.1), [110,45]), #(120,0) , #("Extinct Particles","Particles"), undefined, "Calculates Color Extinction based on a Participating Medium other than the Particles themselves."  )

				if (FranticParticles.GetProperty "RenderingMethod") == "Particle Rendering" then	
				(						
					enableNode =(FranticParticles.GetBoolProperty "UseEnvironmentReflections") 
					if enableNode or showAllNodes do 
					(
						local theColor = (color 255 200 150)
						local theInfo = "Looks up colors from the 3ds Max Environment Map along the Particle Normals as an additional light source."
						if environmentMap == undefined and enableNode do 
						(
							theColor = (color 255 0 0)
							theInfo = "WARNING: No Environment Reflections will be rendered because the Environment Map is not defined in the 3ds Max Environment dialog."
						)
						append theTree #("Env.Reflections", #(theTree.count+2), #(theColor*(if enableNode then 1 else 0.1), [110,45]), #(120,0) , #("Lit Particles","Particles"), undefined, theInfo )
					)
				)
				
				enableNode =	FranticParticles.GetBoolProperty "EnableDepthOfField" 
				if enableNode or showAllNodes do 	
				(
					local theColor = (color 200 220 255)
					local theCamera = viewport.getCamera() 
					local theInfo = "Calculates a Depth Of Field effect. Requires Krakatoa Camera modifier on the current Camera to provide an f-stop value." 
					if theCamera == undefined then
					(
						theColor = red
						theInfo = "WARNING: No Depth Of Field effect will be rendered because the view is not a Camera with a Krakatoa Camera Modifier."
					)
					else
					(
						if (for m in theCamera.modifiers where classof m == KrakatoaCameraModifier collect m).count == 0 do
						(
							theColor = red
							theInfo = "WARNING: No DOF effect will be rendered - the current Camera does not have a Krakatoa Camera Modifier to provide the f-stop value."
						)
					)
					append theTree #("Depth Of Field", #(theTree.count+2), #(theColor*(if enableNode then 1 else 0.1), [110,45]), #(120,0) , #("Sample Rate:"+((floor((FranticParticles.GetFloatProperty "DepthOfFieldSampleRate")*100))/100) as string,"Particles"), undefined, theInfo)
				)
				
				local theShadingMode = FranticParticles.GetProperty "PhaseFunction"
				append theTree #(theShadingMode , #(theTree.count+2), #((color 255 200 150), [110,45], false, true), #(120,0) , #("Shaded Particles" ,"Particles"), undefined, "Performs Shading Based On the Selected Phase Function.") --#(theOriginX,60) 
				

				enableNode = FranticParticles.GetBoolProperty "EnableMotionBlur" 
				if enableNode or showAllNodes do 	
					append theTree #((FranticParticles.GetIntProperty "MotionBlurSegments") as string+" Passes MBlur "+(if FranticParticles.GetBoolProperty "JitteredMotionBlur" then "J" else "")+(if FranticParticles.GetBoolProperty "DeformationMotionBlur" then "D" else "") , #(theTree.count+2), #((color 255 200 225)*(if enableNode then 1 else 0.1), [110,45], false, true), #(120,0) , #("Shttr:"+(FranticParticles.GetIntProperty "ShutterAngleInDegrees") as string+ " Bias:"+ (floor ((FranticParticles.GetFloatProperty "ShutterBias")*100)/100) as string  ,"Particles"), undefined, "Causes the Rendering of Multiple Passes to produce a Motion Blur Effect.") --#(theOriginX,60) 
				
					
				local ignoreSceneLights = (FranticParticles.GetBoolProperty "IgnoreSceneLights")
				if not ignoreSceneLights and theCacheCount > 0 and FranticParticles.GetBoolProperty "EnableLightingCache" and (FranticParticles.GetProperty "RenderingMethod") == "Particle Rendering" then
				(
					append theTree #("LIGHTING CACHE", #(theTree.count+2), #((color 200 255 255), [110,45], false,true), #(120,0) , #(FranticParticleRenderMXS.addCommas (theCacheCount as string) + " Prts ","Particles"), #(theOriginX,60), "Stores the last content of the Lighting channel in Particle Mode" )
				)
				else
				(
					if (FranticParticles.GetProperty "RenderingMethod") == "Particle Rendering" then		
					(
						append theTree #("Sort For View", #(theTree.count+2), #((color 220 230 250), [110,45]), #(120,0) , #("Sorted Particles","Particles"), undefined, "Sorts the particles back to front relatively to the current view." )
						
						local txt = "rcmenu ViewsNodeRCMenu (\n"
						local cnt = 0
						local theSceneCameras=for o in objects where findItem Camera.classes (classof o) != 0 collect o
						for aCamera in theSceneCameras do
						(
							cnt+=1
							local theName = aCamera.name 
							txt+= "menuItem mnu_camera_" + cnt as string + " \""+ theName + "\" checked:(" +(viewport.getCamera() == aCamera) as string + ")\n"
							txt+= "on mnu_camera_" + cnt as string + " picked do (\n"
							txt+= "try(select (getNodeByName \""+aCamera.name +"\");max modify mode;viewport.setCamera (getNodeByName \""+aCamera.name +"\") )catch() \n"
							txt+= ")\n"
						)
						if cnt > 0 do txt+="separator sep_01\n"
						txt+= "menuItem mnu_camerafromview \"Camera From View\" enabled:(viewport.getCamera() == undefined)\n"
						txt+= "on mnu_camerafromview picked do\n"
						txt+= "macros.run \"Lights and Cameras\" \"Camera_CreateFromView\"\n"
						
						txt += ")\n"
						RightClickMenus.ViewsNodeRCMenu = execute txt
							
						
						if not ignoreSceneLights or showAllNodes do
						(
							append theTree #("Attenuation", #(theTree.count+2), #((color 255 200 150)*hasLights*(if not ignoreSceneLights then 1 else 0.1), [110,45]), #(120,0) , #("Lit Particles","Particles"), undefined, "Calculates Light Attenuation Map For Each Light" )
							append theTree #("Sort For "+theActiveLights.count as string+ (if theActiveLights.count == 1 then " Light" else " Lights"), #(theTree.count+2), #((color 220 220 240)*hasLights*(if not ignoreSceneLights then 1 else 0.1), [110,45]), #(120,0) , #("Sorted Particles","Particles"), #(0,0,120,0) ) --#(0,0,theOriginX,0)
						)
					)
				)
			)
			


			if theCacheCount > 0 and FranticParticles.GetBoolProperty "EnableParticleCache" then
			(
				append theTree #("PARTICLE CACHE", #(theTree.count+2), #(color 200 255 255, [110,45], false, true), undefined, #(FranticParticleRenderMXS.addCommas (theCacheCount as string) + " Prts",(theMemory as string) + " MB"), #(theOriginX,0), "The Particle Cache freezes the content of the Memory Pool and allows the fast re-rendering of the loaded particles." )
			)
			else
			(
					
				append theTree #("MEMORY POOL", #(theTree.count+2), #(color 200 255 255, [110,45], false, true), undefined, #(FranticParticleRenderMXS.addCommas (theCacheCount as string) + " Prts", (if theMemory > 0 then  (theMemory as string) + " MB" else "Particles")), #(theOriginX,0), "The Memory Pool collects all particles scheduled for rendering." )
				theMemoryPoolIndex = theTree.count
				for j in imageBuffers do theTree[j][2] = #(theTree.count)
					
				local theShadingMode = FranticParticles.GetProperty "PhaseFunction"
				if matchPattern theShadingMode pattern:"Phong*" do
				(
					enableNode = FranticParticles.GetBoolProperty "Channel:Allocate:SpecularLevel" 
					append theTree #("Use SpecularLevel", #(theTree.count+2), #((color 255 200 150)*(if enableNode then 1 else 0.1), [110,45]), #(120,0) , #("Particles" ,"Particles"), undefined, "Allocates SpecularLevel Channel for Phong Shading.")
					enableNode = FranticParticles.GetBoolProperty "Channel:Allocate:SpecularPower" 					
					append theTree #("Use SpecularPower", #(theTree.count+2), #((color 255 200 150)*(if enableNode then 1 else 0.1), [110,45]), #(120,0) , #("Particles" ,"Particles"), undefined, "Allocates SpecularPower Channel for Phong Shading.")
				)
				
				if matchPattern theShadingMode pattern:"Henyey*" or matchPattern theShadingMode pattern:"Schlick" do
				(
					enableNode = FranticParticles.GetBoolProperty "Channel:Allocate:PhaseEccentricity" 
					append theTree #("Use PhaseEccentricity", #(theTree.count+2), #((color 255 200 150)*(if enableNode then 1 else 0.1), [110,45]), #(120,0) , #("Particles" ,"Particles"), undefined, "Allocates PhaseEccentricity Channel for Henyey-Greenstein or Schlick Shading.")
				)					
					
				enableNode = FranticParticles.GetBoolProperty "UseFilterColor" --or FranticParticles.GetBoolProperty "AdditiveMode"
				if enableNode or showAllNodes do 
					append theTree #("Use Absorption", #(theTree.count+2), #((color 255 200 150)*(if enableNode then 1 else 0.1), [110,45],false,true), #(120,0) , #("Shaded Particles","Particles"), undefined, "Allocates the Absorption channel which causes light to be attenuated independently in R,G and B as it passes through dense particles." )
				
				enableNode =FranticParticles.GetBoolProperty "UseEmissionColor" --or FranticParticles.GetBoolProperty "AdditiveMode"
				if enableNode or showAllNodes do 
					append theTree #("Use Emission", #(theTree.count+2), #((color 255 200 150)*(if enableNode then 1 else 0.1), [110,45]), #(120,0) , #("Emissive Particles","Particles"), undefined, "Allocates the Emission channel which makes the particles render as self-illuminated even when no scene lights are present." )
					
				enableNode =	FranticParticles.GetBoolProperty "AdditiveMode"
				if enableNode or showAllNodes do 
					append theTree #("Force Additive Mode", #(theTree.count+2), #((color 255 200 150)*(if enableNode then 1 else 0.1), [110,45]), #(120,0) , #("Clr->Emiss;0->Abs","Particles"), undefined, "Forces Additive Rendering by enabling internally the Emission and Absorption channel and copying the Color into the Emission while setting Absorption to Black." )
				
					
				enableNode =FranticParticles.GetBoolProperty "DensityOverride:Enabled"
				if enableNode or showAllNodes do 
					append theTree #("Density Override", #(theTree.count+2), #((color 255 200 200)*(if enableNode then 1 else 0.1) , [110,45],false,false), #(120,0),#("Density Channel","Particles"), #(theOriginX,60), "The Density Channel Override REPLACES the density value in all particles being loaded regardless of their source.")
				
				enableNode =FranticParticles.GetBoolProperty "AbsorptionOverride:Enabled"
				if enableNode or showAllNodes do 
					append theTree #("Absorption Override", #(theTree.count+2), #((color 255 200 200)*(if enableNode then 1 else 0.1) , [110,45],false,false), #(120,0), #("Absorption Chnl","Particles"), undefined, "The Absorption Channel Override REPLACES the absorption value in all particles being loaded regardless of their source.")

				enableNode =FranticParticles.GetBoolProperty "EmissionOverride:Enabled"
				if enableNode or showAllNodes do 
					append theTree #("Emission Override", #(theTree.count+2), #((color 255 200 200)*(if enableNode then 1 else 0.1) , [110,45],false,false), #(120,0), #("Emission Channel","Particles"), undefined, "The Emission Channel Override REPLACES the emission value in all particles being loaded regardless of their source.")
				
				enableNode =FranticParticles.GetBoolProperty "ColorOverride:Enabled" 
				if enableNode or showAllNodes do 
					append theTree #("Color Override", #(theTree.count+2), #((color 255 200 200)*(if enableNode then 1 else 0.1) , [110,45],false,false), #(120,0), #("Color Channel","Particles"), undefined, "The Color Channel Override REPLACES the color value in all particles being loaded regardless of their source.")

				enableNode =FranticParticles.GetProperty "GlobalDataHolder" != ""
				if enableNode or showAllNodes do 
					append theTree #("Channel Override", #(theTree.count+2), #((color 255 200 200)*(if enableNode then 1 else 0.1) , [110,45]), #(120,0), #("Channels","Channels"), undefined, "The Global Channel Override runs Krakatoa Channels Modifiers on all particles being loaded regardless of their source.")
					
				local theHolders = (for o in objects where classof o.baseobject == KrakatoaGlobalDataHolder collect o) 
				local theHolderNames = join #("") (for o in theHolders collect o.name)
				local theHolderDisplay = join #("--Disable Global Channel Overrides--") (for o in theHolders collect o.name)	
				local txt = "rcmenu ChannelOverrideNodeRCMenu (\n"
				for i = 1 to theHolderNames.count do
				(
					txt += "menuItem mnu_globalHolder"+i as string +" \""+theHolderDisplay[i]+"\" checked:(\""+theHolderNames[i]+"\"==\""+FranticParticles.GetProperty "GlobalDataHolder"+"\")\n"
					txt += "on mnu_globalHolder"+i as string +" picked do \n("
					txt += "FranticParticles.SetProperty \"GlobalDataHolder\" \""+theHolderNames[i]+"\"\n"
					txt += "try(Krakatoa_GUI_RenderGlobalValues.refresh_GUI())catch()\n"
					txt += "try(Krakatoa_VFB_Left_Rollout.refresh_GUI())catch()\n"
					txt += "try(select (getNodeByName \""+theHolderNames[i]+ "\"))catch()\n"
					txt += "Krakatoa_updateSchematicFlow())\n"
				)	
				txt += "separator sep_10\n"
				txt += "menuItem mnu_addSet \"Create New Channel Override Set...\" \n"					
				txt += "on mnu_addSet picked do (\n"
				txt += "try(Krakatoa_GUI_RenderGlobalValues.createNewOverrideSet()\n"
				txt += "Krakatoa_GUI_RenderGlobalValues.refresh_GUI())catch()\n"
				txt += "Krakatoa_updateSchematicFlow())\n"
				
				txt+=")\n"
				RightClickMenus.ChannelOverrideNodeRCMenu = execute txt
				
				append theTree #("Node Material", #(), #(color 200 200 255, [110,45],false,true),undefined, #("Shaded Particles","Particles"), #(theOriginX-(if showAllNodes then 210 else 0),10), "The Material is applied after the modifier stack and will overwrite Color, Density, Absorption and Emission channels unless these are explicitly unchecked in a Krakatoa Material." )
				local theMatRoot = theTree.count
					
				local hasCulling = (for o in getClassInstances KrakatoaPRTLoader where o.useCullingGizmo collect o).count > 0 and FranticParticles.GetBoolProperty "RenderKrakatoaLoaders" 
				local thePRTLoaders = for o in objects where classof o == KrakatoaPRTLoader collect o --and not o.isHiddenInVpt and o.renderable and o.baseobject.enabledInRender 
				local thePRTVolumes = for o in objects where classof o == PRT_Volume collect o  --and not o.isHiddenInVpt and o.renderable

				local PRTLhasDeformations = (for o in thePRTLoaders where (for m in o.modifiers where classof m != KrakatoaChannelsModifier collect m).count > 0 collect o).count > 0 and FranticParticles.GetBoolProperty "RenderKrakatoaLoaders" 
				local PRTLhasKCMs = (for o in thePRTLoaders where (for m in o.modifiers where classof m == KrakatoaChannelsModifier collect m).count > 0 collect o).count > 0 and FranticParticles.GetBoolProperty "RenderKrakatoaLoaders" 
				local PRTVhasDeformations = (for o in thePRTVolumes where (for m in o.modifiers where classof m != KrakatoaChannelsModifier collect m).count > 0 collect o).count > 0 and FranticParticles.GetBoolProperty "RenderGeometryVolumes" 
				local PRTVhasKCMs = (for o in thePRTVolumes where (for m in o.modifiers where classof m == KrakatoaChannelsModifier collect m).count > 0 collect o).count > 0 and FranticParticles.GetBoolProperty "RenderGeometryVolumes" 
				
				if hasCulling or PRTLhasDeformations or PRTLhasKCMs or PRTVhasDeformations or PRTVhasKCMs do theTree[theMatRoot][2] = #(theTree.count+1)
					
				if hasCulling or showAllNodes do 
				(
					append theTree #("Culling", #(theTree.count+2), #((color 200 200 255)*(if hasCulling then 1 else 0.1), [110,45],false, false), #(120,0),  #("Culled Particles","Particles") )
					theCullingRoot = theTree.count
				)
				if PRTLhasDeformations or PRTVhasDeformations or showAllNodes do 
				(
					append theTree #("Deformations", #(theTree.count+2), #((color 200 200 255)*(if PRTLhasDeformations or PRTVhasDeformations then 1 else 0.1), [110,45],false, false), #(120,0) , #("Deformed Particles","Particles"), undefined, "Deformation Modifiers are applied to the modifier stack of PRT Loaders and PRT Volumes in object or world space and affect the Position, Velocity and Normal channels." )
					theDeformRoot = theTree.count
				)
				
				if PRTLhasKCMs or PRTVhasKCMs or showAllNodes do 
				(
					append theTree #("Local KCMs", #(), #((color 200 200 255)*(if PRTLhasKCMs or PRTVhasKCMs  then 1 else 0.1), [110,45],false, false), #(120,0),  #("Modified Channels","Particles"), undefined, "Local Krakatoa Channels Modifiers are applied to the modifier stack of PRT Loaders and PRT Volumes in object space." )
					theKCMRoot = theTree.count
					
					local allKCMs = getClassInstances KrakatoaChannelsModifier 
					local txt = "rcmenu KCMsNodeRCMenu\n(\n"
					local cnt = 0
					for kcm in allKCMs do 
					(
						cnt+=1
						local theNodes = for o in refs.dependents kcm where (classof (superclassof o)) == Node and classof o.baseobject != KrakatoaGlobalDataHolder collect o
						if theNodes.count > 0 do
						(
							local theLine = "menuItem mnu_"+ cnt as string + " \"" + kcm.name + " ("
							local isShortened = false
							for o = theNodes.count to 1 by -1 do 
							(
								if theLine.count < 100 then 
									theLine += theNodes[o].name+","
								else
									isShortened = true
							)
							theLine = substring theLine 1 (theLine.count-1)
							if isShortened do theLine += "..." + theNodes[1].name
							theLine+=")\" checked:"+ (modPanel.getCurrentObject() == kcm) as string+"\n"
							txt+= theLine
							txt+="on mnu_"+cnt as string +" picked do(\n"
							txt+="max modify mode\n"
							local theIndex = findItem theNodes[1].modifiers kcm
							txt+="modPanel.setCurrentObject ((getNodeByName \""+ theNodes[1].name +"\").modifiers["+ theIndex as string +"] )\n"
							txt+=")\n"
						)
					)--end kcm loop
					txt+=")\n"
					RightClickMenus.KCMsNodeRCMenu = execute txt
				)
				
				theTree[theTree.count][6] = #(0,0,theOriginX,30)
					
				local theStackRoot = theTree.count
				inputCount = 0
				
				allRenderableSystems = #()

				enableNode =FranticParticles.GetBoolProperty "RenderParticleFlowGeometry"
				if enableNode or showAllNodes do 
				(
					local theSystems = #()
					for theRenderOp in (getClassInstances RenderParticles) where theRenderOp.type == 2 do 
						(for o in refs.dependents theRenderOp where classof o == PF_Source and isProperty o #name do if findItem theSystems o == 0 do append theSystems o )
					local theRenderableSystems = for o in theSystems where not o.isHiddenInVpt and o.renderable and o.Enable_Particles collect o
					local theInfo = if theSystems.count == 0 then 
					(
						if enableNode then 
							"Loads Particles from PFlow Events with Render Operator set to Geometry, but there are currently no such Events in the scene."
						else
							"Loads Particles from PFlow Events with Render Operator set to Geometry, but there are no such Events and the >PFlow Geometry option is currently unchecked."
					)
					else
					(
						if theRenderableSystems.count == 0 then 
						(
							if enableNode then 
								"Loads Particles from PFlow Events with Render Operator set to Geometry, but the host PFlow System is not renderable."
							else
								"Loads Particles from PFlow Events set to Geometry, but the host PFlow is not renderable and the >PFlow Geometry option is currently unchecked."
						)
						else
						(
							if enableNode then 
								"Loads Particles from PFlow Events with Render Operator set to Geometry."
							else
								"Would load Particles from PFlow Events with Render Operator set to Geometry, but the >PFlow Geometry option is currently unchecked."
						)
					)
					local multiplier = if theSystems.count > 0 then 1.0 else 0.5
					append theTree #( theRenderableSystems.count as string +"/"+theSystems.count as string + " PFlow Geometry", #(), #((color 200 255 200)*multiplier*(if enableNode then 1 else 0.1) , [140,40], true,true), getNextOffset(), #("Particles"), undefined, theInfo )
					append theTree[theMatRoot][2] theTree.count
					inputCount += 1
					
					if enableNode and theSystems.count > 0 do join allRenderableSystems theRenderableSystems
					
					RightClickMenus.PFlowGeometryNodeRCMenu = defineMenu "PFlowGeometryNodeRCMenu" theSystems "RenderParticleFlowGeometry"
				)
				
				enableNode =FranticParticles.GetBoolProperty "RenderParticleFlowPhantom"
				if enableNode or showAllNodes do 
				(				
					local theSystems = #()
					for theRenderOp in (getClassInstances RenderParticles) where theRenderOp.type == 3 do 
						(for o in refs.dependents theRenderOp where classof o == PF_Source and isProperty o #name do if findItem theSystems o == 0 do append theSystems o )
					local theRenderableSystems = for o in theSystems where not o.isHiddenInVpt and o.renderable and o.Enable_Particles collect o
					local theInfo = if theSystems.count == 0 then 
					(
						if enableNode then 
							"Loads Particles from PFlow Events with Render Operator set to Phantom, but there are currently no such Events in the scene."
						else
							"Loads Particles from PFlow Events with Render Operator set to Phantom, but there are no such Events and the >PFlow Phantom option is currently unchecked."
					)
					else
					(
						if theRenderableSystems.count == 0 then 
						(
							if enableNode then 
								"Loads Particles from PFlow Events with Render Operator set to Phantom, but the host PFlow System is not renderable."
							else
								"Loads Particles from PFlow Events set to Phantom, but the host PFlow is not renderable and the >PFlow Phantom option is currently unchecked."
						)
						else
						(
							if enableNode then 
								"Loads Particles from PFlow Events with Render Operator set to Phantom."
							else
								"Would load Particles from PFlow Events with Render Operator set to Phantom, but the >PFlow Phantom option is currently unchecked."
						)
					)	
					local multiplier = if theSystems.count > 0 then 1.0 else 0.5
					append theTree #(theRenderableSystems.count as string + "/"+theSystems.count as string + " PFlow Phantom", #(), #((color 200 255 200)*multiplier*(if enableNode then 1 else 0.1)  , [140,40],true,true), getNextOffset(), #("Particles"), undefined, theInfo )
					append theTree[theMatRoot][2] theTree.count
					inputCount += 1
					RightClickMenus.PFlowPhantomNodeRCMenu = defineMenu "PFlowPhantomNodeRCMenu" theSystems "RenderParticleFlowPhantom"
					
					if enableNode and theSystems.count > 0 do join allRenderableSystems theRenderableSystems
					
				)

				enableNode =FranticParticles.GetBoolProperty "RenderParticleFlowBBox"
				if enableNode or showAllNodes do 
				(					
					local theSystems = #()
					for theRenderOp in (getClassInstances RenderParticles) where theRenderOp.type == 1 do 
						(for o in refs.dependents theRenderOp where classof o == PF_Source and isProperty o #name do if findItem theSystems o == 0 do append theSystems o )
					local theRenderableSystems = for o in theSystems where not o.isHiddenInVpt and o.renderable and o.Enable_Particles collect o
					local theInfo = if theSystems.count == 0 then 
					(
						if enableNode then 
							"Loads Particles from PFlow Events with Render Operator set to Bounding Box, but there are currently no such Events in the scene."
						else
							"Loads Particles from PFlow Events with Render Operator set to Bounding Box, but there are no such Events and the >PFlow BBox option is currently unchecked."
					)
					else
					(
						if theRenderableSystems.count == 0 then 
						(
							if enableNode then 
								"Loads Particles from PFlow Events with Render Operator set to Bounding Box, but the host PFlow System is not renderable."
							else
								"Loads Particles from PFlow Events set to Bounding Box, but the host PFlow is not renderable and the >PFlow BBox option is currently unchecked."
						)
						else
						(
							if enableNode then 
								"Loads Particles from PFlow Events with Render Operator set to Bounding Box."
							else
								"Would load Particles from PFlow Events with Render Operator set to Bounding Box, but the >PFlow BBox option is currently unchecked."
						)
					)						
					local multiplier = if theRenderableSystems.count > 0 then 1.0 else 0.5
					append theTree #(theRenderableSystems.count as string +"/"+theSystems.count as string +" PFlow BBox", #(), #((color 200 255 200)*multiplier*(if enableNode then 1 else 0.1)  , [140,40], true,true), getNextOffset(), #("Particles"), undefined, theInfo  )
					append theTree[theMatRoot][2] theTree.count
					inputCount += 1
					RightClickMenus.PFlowBBoxNodeRCMenu = defineMenu "PFlowBBoxNodeRCMenu" theSystems "RenderParticleFlowBBox"	
					
					if enableNode and theSystems.count > 0 do join allRenderableSystems theRenderableSystems
				)

				enableNode =FranticParticles.GetBoolProperty "RenderMaxParticles"
				if enableNode or showAllNodes do 
				(
					local theSystems =(for o in objects where findItem legacyParticles (classof o) > 0 collect o) 
					local theRenderableSystems = for o in theSystems where not o.isHiddenInVpt and o.renderable collect o
					local multiplier = if theRenderableSystems.count > 0 then 1.0 else 0.5

					local theInfo = if theSystems.count == 0 then 
					(
						if enableNode then 
							"Loads Particles from 3ds Max Legacy particle systems, but there are currently no such systems in the scene."
						else
							"Loads Particles from 3ds Max Legacy particle systems, but there are no such systems and the >Legacy Particles option is currently unchecked."
					)
					else
					(
						if theRenderableSystems.count == 0 then 
						(
							if enableNode then 
								"Loads Particles from 3ds Max Legacy particle systems, but there are currently no renderable systems in the scene."
							else
								"Loads Particles from 3ds Max Legacy particle systems, but there are no renderable systems and the >Legacy Particles option is currently unchecked."
						)
						else
						(
							if enableNode then 
								"Will load the Particles from 3ds Max Legacy particle systems."
							else
								"Would load Particles from 3ds Max Legacy particle systems, but the >Legacy Particles option is currently unchecked."
						)
					)						
					append theTree #(theRenderableSystems.count as string + "/" +theSystems.count as string  + (if theRenderableSystems.count == 1 then " Legacy System" else " Legacy Systems"), #(), #((color 200 255 200)*multiplier*(if enableNode then 1 else 0.1) , [140,40], true,true), getNextOffset(), #("Particles"), undefined, theInfo  )
					append theTree[theMatRoot][2] theTree.count
					inputCount += 1
					
					RightClickMenus.LegacySystemsNodeRCMenu = defineMenu "LegacySystemsNodeRCMenu" theSystems "RenderMaxParticles" 
					
					if enableNode and theRenderableSystems.count > 0 do join allRenderableSystems theRenderableSystems
					
				)
				
				
				enableNode =FranticParticles.GetBoolProperty "RenderThinkingParticles"
				if enableNode or showAllNodes do 
				(
					local theSystems = (for o in objects where classof o == Thinking collect o)
					local theRenderableSystems = for o in theSystems where not o.isHiddenInVpt and o.renderable collect o
					local multiplier = if theRenderableSystems.count > 0 then 1.0 else 0.5
					local theInfo = if theSystems.count == 0 then 
					(
						if enableNode then 
							"Loads Particles from Thinking Particles systems, but there are currently no TP systems in the scene."
						else
							"Loads Particles from Thinking Particles systems, but there are no TP systems and the >ThinkingParticles option is currently unchecked."
					)
					else
					(
						if enableNode then 
							"Will load the Particles from Thinking Particles systems."
						else
							"Would load Particles from Thinking Particles systems, but the >ThinkingParticles option is currently unchecked."
					)							
					append theTree #(theRenderableSystems.count as string +"/"+theSystems.count as string + " Thinking Particles", #(), #((color 200 255 200)*multiplier*(if enableNode then 1 else 0.1) , [140,40], true,true), getNextOffset(), #("Particles"), undefined, theInfo  )
					append theTree[theMatRoot][2] theTree.count
					inputCount += 1
					RightClickMenus.TPNodeRCMenu = defineMenu "TPNodeRCMenu" theSystems "RenderThinkingParticles"
					
					if enableNode and theSystems.count > 0 do join allRenderableSystems theRenderableSystems
				)

				enableNode =FranticParticles.GetBoolProperty "RenderFumeFX"
				if enableNode or showAllNodes do 
				(
					local theSystems =(for o in objects where classof o == FumeFX collect o)
					local theRenderableSystems = for o in theSystems where not o.isHiddenInVpt and o.renderable collect o
					
					local multiplier = if theRenderableSystems.count > 0 then 1.0 else 0.5
					local theInfo = if theSystems.count == 0 then 
					(
						if enableNode then 
							"Loads Particles created inside FumeFX sim's voxels, but there are currently no FumeFX sims in the scene."
						else
							"Loads Particles created inside FumeFX sim's voxels, but there are none and the >FumeFX option is currently unchecked."
					)
					else
					(
						if theRenderableSystems.count == 0 then
						(
							if enableNode then 
								"Loads Particles created inside FumeFX sim's voxels, but there are currently no renderable FumeFX simulations in the scene."
							else
								"Loads Particles created inside FumeFX sim's voxels, but there are renderable FumeFX sims and the >FumeFX option is currently unchecked."
						)
						else
						(
							if enableNode then 
								"Would load Particles created inside FumeFX sim's voxels."
							else
								"Would load Particles created inside FumeFX sim's voxels, but the >FumeFX option is currently unchecked."
						)
					)								
					append theTree #(theRenderableSystems.count as string +"/"+theSystems.count as string +" Fume FX", #(), #((color 200 255 200)*multiplier*(if enableNode then 1 else 0.1) , [140,40], true,true), getNextOffset(), #("Voxels As Particles"), undefined, theInfo )
					append theTree[theMatRoot][2] theTree.count
					inputCount += 1
					
					RightClickMenus.FumeFXNodeRCMenu = defineMenu "FumeFXNodeRCMenu" theSystems "RenderFumeFX"
					
					if enableNode and theSystems.count > 0 do join allRenderableSystems theRenderableSystems
				)			
				
		
				enableNode =FranticParticles.GetBoolProperty "RenderKrakatoaLoaders"
				if enableNode or showAllNodes do 
				(
					local theRenderableSystems = for o in thePRTLoaders where not o.isHiddenInVpt and o.renderable and o.baseobject.enabledInRender collect o
					local multiplier = if theRenderableSystems.count > 0 then 1.0 else 0.5
					local theInfo = if thePRTLoaders.count == 0 then 
					(
						if enableNode then 
							"Loads Particles from PRT Loader objects reading file sequences from disk, but there are currently no PRT Loaders in the scene."
						else
							"Loads Particles PRT Loader objects but there are none and the >PRT Loaders option is currently unchecked."
					)
					else
					(
						if theRenderableSystems.count == 0 then
						(
							if enableNode then 
								"Loads Particles from PRT Loader objects reading file sequences from disk, but there are currently no renderable PRT Loaders in the scene."
							else
								"Loads Particles PRT Loader objects but there are no renderable PRT Loaders and the >PRT Loaders option is currently unchecked."
						)
						else
						(
							if enableNode then 
								"Will load the Particles read by PRT Loaders from file sequences on disk."
							else
								"Would load the Particles of the PRT Loader objects, but the >PRT Loaders option is currently unchecked."
						)
					)						
					append theTree #(theRenderableSystems.count as string + "/" +thePRTLoaders.count as string +  (if thePRTLoaders.count == 1 then " PRT Loader" else " PRT Loaders"), #(), #((color 200 255 200)*multiplier*(if enableNode then 1 else 0.1) , [140,40], PRTLhasKCMs or  PRTLhasDeformations or hasCulling, PRTLhasKCMs or PRTLhasDeformations or hasCulling ), getNextOffset(), #("Loaded Particles"), undefined, theInfo)
					if PRTLhasKCMs then
						append theTree[theKCMRoot][2] theTree.count
					else if PRTLhasDeformations then 
						append theTree[theDeformRoot][2] theTree.count
					else if hasCulling then 
						append theTree[theCullingRoot][2] theTree.count
					else
						append theTree[theMatRoot][2] theTree.count
					inputCount += 1
					
					RightClickMenus.PRTLoadersNodeRCMenu = defineMenu "PRTLoadersNodeRCMenu" thePRTLoaders "RenderKrakatoaLoaders"					
					
					if enableNode and thePRTLoaders.count > 0 do join allRenderableSystems theRenderableSystems
				)
				

				enableNode =FranticParticles.GetBoolProperty "RenderGeometryVolumes"
				if enableNode or showAllNodes do 
				(
					local theRenderableSystems = for o in thePRTVolumes where not o.isHiddenInVpt and o.renderable collect o
					local multiplier = if theRenderableSystems.count > 0 then 1.0 else 0.5
					local theInfo = if theRenderableSystems.count == 0 then 
					(
						if enableNode then 
							"Loads Particles created by PRT Volume objects, but there are currently no PRT Volume objects in the scene."
						else
							"Loads Particles created by PRT Volume objects but there are none and the >PRT Volumes option is currently unchecked."
					)
					else
					(
						if enableNode then 
							"Will load the Particles created by the PRT Volume objects filling Geometry volumes."
						else
							"Would load the Particles created by the PRT Volume objects, but the >PRT Volumes option is currently unchecked."
					)
					
					append theTree #(theRenderableSystems.count as string + "/" + thePRTVolumes.count as string + (if theRenderableSystems.count == 1 then " PRT Volume" else " PRT Volumes"), #(), #((color 200 255 200)*multiplier*(if enableNode then 1 else 0.1)  , [140,40], PRTVhasDeformations or PRTVhasKCMs,PRTVhasDeformations or PRTVhasKCMs), getNextOffset(), #("Volume Particles"), undefined, theInfo)
					if PRTVhasKCMs then
						append theTree[theKCMRoot][2] theTree.count
					else if PRTVhasDeformations then 
						append theTree[theDeformRoot][2] theTree.count
					else
						append theTree[theMatRoot][2] theTree.count
					inputCount += 1
					
					RightClickMenus.PRTVolumesNodeRCMenu = defineMenu "PRTVolumesNodeRCMenu" thePRTVolumes "RenderGeometryVolumes"
					
					if enableNode and theRenderableSystems.count > 0 do join allRenderableSystems theRenderableSystems
				)
				
				enableNode =FranticParticles.GetBoolProperty "RenderGeometryVertices"
				if enableNode or showAllNodes do 
				(
					local useNamedSelectionSets = execute (FranticParticles.GetProperty "Matte:NamedSelectionSets")
					local matteSelSets = for i = 1 to selectionSets.count where findItem useNamedSelectionSets (getNamedSelSetName i) != 0 collect selectionSets[i]
					local matteObjects = #()
					for i in matteSelSets do 
						join matteObjects (for o in i collect o)				
					local theSystems = (for o in objects where findItem GeometryClass.classes (classof o) > 0 AND classof o != TargetObject AND classof o != Thinking AND classof o != FumeFX AND classof o != ParticleGroup AND findItem legacyParticles (classof o) == 0 AND classof o != PF_Source AND findItem matteObjects o == 0 and classof o != KrakatoaPrtLoader AND classof o.baseobject != KrakatoaGlobalDataHolder AND not FranticParticleRenderMXS.isGeoVolume o collect o)
					local theRenderableSystems = for o in theSystems where not o.isHiddenInVpt and o.renderable collect o
					local multiplier = if theRenderableSystems.count > 0 then 1.0 else 0.5
					
					local theInfo = if theSystems.count == 0 then 
					(
						if enableNode then 
							"Loads Vertices of Geometry Objects as Particles, but there are currently no Geometry Objects in the scene."
						else
							"Loads Vertices of Geometry Objects as Particles, but the >Geo.Vertices option is currently unchecked."
					)
					else
					(
						if enableNode then 
							"Will load the Vertices of the scene Geometry Objects as Particles."
						else
							"Would load the Vertices of the scene Geometry Objects as Particles, but the >Geo.Vertices option is currently unchecked."
					)
					
					append theTree #(theRenderableSystems.count as string + "/" + theSystems.count as string  + (if theRenderableSystems.count == 1 then " Geometry Object " else " Geometry Objects"), #(), #((color 200 255 200)*multiplier*(if enableNode then 1 else 0.1) , [140,40]), getNextOffset(), #("Vertices As Particles"), undefined, theInfo )
					append theTree[theMatRoot][2] theTree.count
					inputCount += 1
					
					RightClickMenus.GeometryVerticesNodeRCMenu = defineMenu "GeometryVerticesNodeRCMenu" theSystems "RenderGeometryVertices"
					
					if enableNode and theRenderableSystems.count > 0 do join allRenderableSystems theRenderableSystems
				)					
				
				if allRenderableSystems.count == 0 do 
				(
					theTree[theMemoryPoolIndex][3][1] = color 255 50 50 
					theTree[theMemoryPoolIndex][7] = "WARNING: The scene provides NO PARTICLES. Please create/unhide/enable one or more particle sources."
				)
							
			)
		)--end fn
		
		fn createNodeTree init:false=
		(
			theTreeHeight = 0
			if init do
			(
				for i = hc.getNodeCount to 1 by -1 do 
				(
					hc.activeNode = i	
					hc.deleteActiveNode
				)
			)	
			hc.setInfo = "Krakatoa Schematic Flow "
			local x = theOriginX+120
			local y = 10
			for i = 1 to theTree.count do
			(
				local currentNode = theTree[i]
				if currentNode[4] != undefined then
				(
					x -= currentNode[4][1]
					y += currentNode[4][2]
				)
				else
				(
					x += 0
					y += 60
				)			
				if currentNode[6] != undefined do 
				(
					if currentNode[6][1] > 0 do 
					(
						x = currentNode[6][1]
						y += currentNode[6][2]
					)
				)		
				if x < 100 do 
				(
					x = theOriginX
					y += 60
				)

				if init do hc.addNode
				hc.activeNode = i
				hc.nodeName =  currentNode[1] 
				hc.nodeColor = currentNode[3][1]
					
				hc.activeNodePos = [x,y]
				if y+60 > theTreeHeight do theTreeHeight = y+60
				hc.isCollapsible = false
				try(hc.drawLayer = 3)catch()
				try(hc.viewAlign = 0)catch()
				if init do hc.addOutSocket
				hc.activeSocket = 1
				hc.connectionColor = blue
				hc.socketPosition = [5,20]
				if currentNode[3][4] ==true do try(hc.activeSocketFlipped  = true)catch()
				hc.socketName = if currentNode[5] != undefined then 
					currentNode[5][1]
				else ""
				
				hc.activeSocketShowValue = false
				
				if currentNode[2].count > 0 do
				(
					if init do hc.addInSocket
					hc.activeSocket = 2
					hc.socketPosition = [5,32]

					if currentNode[3][3] ==true do try(hc.activeSocketFlipped  = true)catch()

					hc.socketName = if currentNode[5] != undefined then 
						currentNode[5][2]
					else ""
					hc.connectionColor = blue
				)
				
				hc.nodeCollapsedSize = [currentNode[3][2].x ,20]	
				hc.nodeSize = currentNode[3][2]
	
				if currentNode[6] != undefined and i < theTree.count do 
				(
					if currentNode[6].count > 2 do 
					(
						x = currentNode[6][3]
						y += currentNode[6][4]
					)
				)
				if currentNode[7] != undefined do
				(
					if matchpattern currentNode[7]  pattern:"WARNING*" or matchpattern currentNode[7]  pattern:"ERROR*" do 
						hc.setInfo = currentNode[7] 
				)				
			)
			--print theTree
			
			if init do 
			(
				for i = 1 to theTree.count do
				(
					local currentNode = theTree[i]
					local theConnections = currentNode[2]
					for c = 1 to theConnections.count do
					(
						if theConnections[c] != undefined and theConnections[c] > 0 and theConnections[c] <= theTree.count do
						(
							hc.activeNode = theConnections[c]
							hc.activeSocket = 1
							hc.toggleConnection = [i,2]
						)	
					)
				)
			)
			hc.redrawView	
		)
		
		 
				
			
		on hc LButtonDown do
		(
			if classof renderers.current != Krakatoa do destroyDialog(Krakatoa_SchematicFlow_Rollout)

			lastMouseClick = mouse.screenpos
			local theMouse = (lastMouseClick - (getDialogPos Krakatoa_SchematicFlow_Rollout))-[3,40]
			lastNodeClick = (hc.findNodeByPos = theMouse)
			hc.setInfo = ""
			if lastNodeClick > 0 do
			(
				if theTree[lastNodeClick][7] != undefined do
				(
					hc.setInfo = theTree[lastNodeClick][7]
				)
			)
			hc.redrawView			
			--::Krakatoa_updateSchematicFlow()
		)			
		
		on hc RButtonDown do
		(
			if classof renderers.current != Krakatoa do destroyDialog(Krakatoa_SchematicFlow_Rollout)
			lastMouseClick = mouse.screenpos
			local theMouse = (lastMouseClick - (getDialogPos Krakatoa_SchematicFlow_Rollout))-[3,40]
			Krakatoa_updateSchematicFlow()
			lastNodeClick = (hc.findNodeByPos = theMouse)
			if lastNodeClick > 0 do
			(
				case theTree[lastNodeClick][1] of
				(
					"RENDER VOXELS": popupmenu RightClickMenus.RenderNodeRCMenu pos:mouse.screenpos
					"RENDER PARTICLES": popupmenu RightClickMenus.RenderNodeRCMenu pos:mouse.screenpos
					"MEMORY POOL": popupmenu RightClickMenus.MemoryNodeRCMenu pos:mouse.screenpos
					"PARTICLE CACHE": popupmenu RightClickMenus.MemoryNodeRCMenu pos:mouse.screenpos
					"LIGHTING CACHE": popupmenu RightClickMenus.MemoryNodeRCMenu pos:mouse.screenpos
					"Depth Of Field":  popupmenu RightClickMenus.DOFNodeRCMenu pos:mouse.screenpos
					"Ambient PME": popupmenu RightClickMenus.APMENodeRCMenu  pos:mouse.screenpos
					"Background Image File": popupmenu RightClickMenus.BackgroundImageFileNodeRCMenu pos:mouse.screenpos
					"Depth Map Matte": popupmenu RightClickMenus.DepthMatteNodeRCMenu pos:mouse.screenpos
					"Objects Matte": popupmenu RightClickMenus.MatteObjectsNodeRCMenu pos:mouse.screenpos
					"Attenuation File": popupmenu RightClickMenus.AttenuationFileNodeRCMenu pos:mouse.screenpos
					"Image File": popupmenu RightClickMenus.ImageFileNodeRCMenu pos:mouse.screenpos
					"Frame Buffer": popupmenu RightClickMenus.VFBNodeRCMenu pos:mouse.screenpos
					
					"Force Additive Mode": popupmenu RightClickMenus.ForceAdditiveModeNodeRCMenu pos:mouse.screenpos
					"Use Emission": popupmenu RightClickMenus.EmissionNodeRCMenu pos:mouse.screenpos
					"Use Absorption": popupmenu RightClickMenus.AbsorptionNodeRCMenu pos:mouse.screenpos
					"Local KCMs":  popupmenu RightClickMenus.KCMsNodeRCMenu pos:mouse.screenpos 
				)
				
				if matchPattern theTree[lastNodeClick][1] pattern:"*MBlur*" do popupmenu RightClickMenus.MotionBlurNodeRCMenu pos:mouse.screenpos
				if matchPattern theTree[lastNodeClick][1] pattern:"*Env.Refl*" do popupmenu RightClickMenus.EnvReflectionNodeRCMenu	pos:mouse.screenpos
				if matchPattern theTree[lastNodeClick][1] pattern:"Channel Override" then popupmenu RightClickMenus.ChannelOverrideNodeRCMenu pos:mouse.screenpos
				if matchPattern theTree[lastNodeClick][1] pattern:"Color Override*" do popupmenu RightClickMenus.ColorOverrideNodeRCMenu pos:mouse.screenpos
				if matchPattern theTree[lastNodeClick][1] pattern:"Emission Override*" do popupmenu RightClickMenus.EmissionOverrideNodeRCMenu pos:mouse.screenpos
				if matchPattern theTree[lastNodeClick][1] pattern:"Absorption Override*" do popupmenu RightClickMenus.AbsorptionOverrideNodeRCMenu pos:mouse.screenpos
				if matchPattern theTree[lastNodeClick][1] pattern:"Density Override*" do popupmenu RightClickMenus.DensityOverrideNodeRCMenu pos:mouse.screenpos
					
				--if matchPattern theTree[lastNodeClick][1] pattern:"*Object*Vertices*" do popupmenu RightClickMenus.GetParticlesFromNodeRCMenu pos:mouse.screenpos 
				if matchPattern theTree[lastNodeClick][1] pattern:"Sort For*Light*" do popupmenu RightClickMenus.LightsNodeRCMenu pos:mouse.screenpos 
				if matchPattern theTree[lastNodeClick][1] pattern:"*Light Pass*" do popupmenu RightClickMenus.LightsNodeRCMenu pos:mouse.screenpos 
					
				if matchPattern theTree[lastNodeClick][1] pattern:"Sort For View*" do popupmenu RightClickMenus.ViewsNodeRCMenu pos:mouse.screenpos 
				if matchPattern theTree[lastNodeClick][1] pattern:"*PRT Loader*" do popupmenu RightClickMenus.PRTLoadersNodeRCMenu pos:mouse.screenpos 
				if matchPattern theTree[lastNodeClick][1] pattern:"*PRT Volume*" do popupmenu RightClickMenus.PRTVolumesNodeRCMenu pos:mouse.screenpos 
					
				if matchPattern theTree[lastNodeClick][1] pattern:"*Geometry Object*" do popupmenu RightClickMenus.GeometryVerticesNodeRCMenu pos:mouse.screenpos 
				if matchPattern theTree[lastNodeClick][1] pattern:"*Legacy System*" do popupmenu RightClickMenus.LegacySystemsNodeRCMenu pos:mouse.screenpos 
				if matchPattern theTree[lastNodeClick][1] pattern:"*Thinking Particles*" do popupmenu RightClickMenus.TPNodeRCMenu pos:mouse.screenpos 

				if matchPattern theTree[lastNodeClick][1] pattern:"*PFlow Geometry*" do popupmenu RightClickMenus.PFlowGeometryNodeRCMenu pos:mouse.screenpos 
				if matchPattern theTree[lastNodeClick][1] pattern:"*PFlow Phantom*" do popupmenu RightClickMenus.PFlowPhantomNodeRCMenu pos:mouse.screenpos 
				if matchPattern theTree[lastNodeClick][1] pattern:"*PFlow BBox*" do popupmenu RightClickMenus.PFlowBBoxNodeRCMenu pos:mouse.screenpos 
				if matchPattern theTree[lastNodeClick][1] pattern:"*Fume FX*" do popupmenu RightClickMenus.FumeFXNodeRCMenu pos:mouse.screenpos 
					
				if matchPattern theTree[lastNodeClick][1] pattern:"Isotropic" or matchPattern theTree[lastNodeClick][1] pattern:"Phong Surface"  or matchPattern theTree[lastNodeClick][1] pattern:"Henyey*"  or matchPattern theTree[lastNodeClick][1] pattern:"Schlick" do
					popupmenu RightClickMenus.ShadingNodeRCMenu pos:mouse.screenpos 
				
				if matchPattern theTree[lastNodeClick][1] pattern:"*SpecularPower*" do  popupmenu RightClickMenus.SpecularPowerNodeRCMenu pos:mouse.screenpos  
				if matchPattern theTree[lastNodeClick][1] pattern:"*SpecularLevel*" do  popupmenu RightClickMenus.SpecularLevelNodeRCMenu pos:mouse.screenpos  
				if matchPattern theTree[lastNodeClick][1] pattern:"*PhaseEccentricity*" do  popupmenu RightClickMenus.PhaseEccentricityNodeRCMenu pos:mouse.screenpos  
				
			)
		)
		
		on hc connectionChanged fromNodeIndex toNodeIndex toSocketID fromSocketID status toSocketCount do
		(
			::Krakatoa_updateSchematicFlow()
		)
		on Krakatoa_SchematicFlow_Rollout open do
		(
			try(hc.useDrawLayers = true)catch()
			hc.drawShadows = true
			hc.allowZoom  = true
			try(hc.zoomAboutMouse = false)catch()
			hc.drawMenuBars = true
			hc.allowUIDelete = false
			--Krakatoa_SchematicFlow_Rollout.title = "Krakatoa v"+ FranticParticles.Version + " Schematic Flow"
		)
		
		on Krakatoa_SchematicFlow_Rollout resized val do 
		(
			hc.width = val.x
			hc.height = val.y
			hc.activeNode = theTree.count
			hc.pan = ([hc.width, hc.height] - [900,theTreeHeight]*hc.zoom + [0,-10])
			setIniSetting (getDir #plugcfg + "/Krakatoa/KrakatoaPreferences.ini") "SchematicFlow" "Size" (val as string)
		)
		
		on hc mouseScroll do
		(
			if hc.zoom > 1.0 do hc.zoom = 1.0
			hc.pan = ([hc.width, hc.height] - [900,theTreeHeight]*hc.zoom + [0,-10])
		)
		
		on Krakatoa_SchematicFlow_Rollout moved pos do
		(
			setIniSetting (getDir #plugcfg + "/Krakatoa/KrakatoaPreferences.ini") "SchematicFlow" "Position" (pos as string)
		)
		
		on Krakatoa_SchematicFlow_Rollout close do
		(
			deleteAllChangeHandlers id:#KrakatoaSchematicFlow
			callbacks.removeScripts id:#KrakatoaSchematicFlow
		)
		
		fn registerCallbacks =
		(
			deleteAllChangeHandlers id:#KrakatoaSchematicFlow
			if selection.count > 0 do
			(
				when parameters selection change id:#KrakatoaSchematicFlow do 
				(
					::Krakatoa_updateSchematicFlow()
				)
			)
		)
	)
	
	on isEnabled return classof renderers.current == Krakatoa
	on execute do
	(
		try(destroyDialog Krakatoa_SchematicFlow_Rollout)catch()
		local thePos = execute (getIniSetting (getDir #plugcfg + "/Krakatoa/KrakatoaPreferences.ini") "SchematicFlow" "Position")
		if thePos == OK do thePos = [100,100]
		local theSize = execute (getIniSetting (getDir #plugcfg + "/Krakatoa/KrakatoaPreferences.ini") "SchematicFlow" "Size")
		if theSize == OK do theSize = [900,600]
		if theSize.x < 300 do theSize.x = 400
		if theSize.y < 300 do theSize.y = 300
		if thePos.x+theSize.x > sysinfo.DesktopSize.x do thePos.x = sysinfo.DesktopSize.x-theSize.x
		if thePos.x<0 do thePos.x = 0
		if thePos.y+theSize.y > sysinfo.DesktopSize.y do thePos.y = sysinfo.DesktopSize.y-theSize.y
		if thePos.y<0 do thePos.y = 0
			
		createDialog Krakatoa_SchematicFlow_Rollout theSize.x theSize.y thePos.x thePos.y style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing, #style_minimizebox, #style_maximizebox) menu:Krakatoa_SchematicFlow_MainMenu
		fn Krakatoa_updateSchematicFlow =
		(
			if classof renderers.current == Krakatoa do
			(
				Krakatoa_SchematicFlow_Rollout.defineTree()
				Krakatoa_SchematicFlow_Rollout.createNodeTree init:true			
				local theSize = [Krakatoa_SchematicFlow_Rollout.width, Krakatoa_SchematicFlow_Rollout.height]
				--if theSize.y < Krakatoa_SchematicFlow_Rollout.theTreeHeight+10 do theSize.y = Krakatoa_SchematicFlow_Rollout.theTreeHeight+10
				Krakatoa_SchematicFlow_Rollout.resized theSize
			)
		)	
		Krakatoa_updateSchematicFlow()
		
		
		callbacks.removeScripts id:#KrakatoaSchematicFlow
		callbacks.addScript #SelectionSetChanged "try(Krakatoa_SchematicFlow_Rollout.registerCallbacks())catch()" id:#KrakatoaSchematicFlow
	)
)
