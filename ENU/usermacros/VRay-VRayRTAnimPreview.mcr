macroScript VRayRTAnimPreview
enabledIn:#("max")
category:"VRay"
buttontext:"Make V-Ray RT Animation Preview"
tooltip:"Render an animation preview with V-Ray RT"
(
	local enabled = false
	local running = false
	local asRenderer = undefined
	local cFrame
	local saveFilePath = (GetDir #renderoutput) + "\frame"
	local saveFileExt = ".png"
	local dialogPos
	local startFrame = (animationRange.start as Integer)/160
	local endFrame = (animationRange.end as Integer)/160
	
	rollout SettingsRollout "V-Ray RT Animation Preview Render Settings" width:262 height:216 (
		label startFrameSpinLabel "Start frame:" pos:[16, 10] width:160 height:16
		spinner startFrameSpin "" pos:[175, 10] width:70 height:16 range:[0, animationRange.end, startFrame] type:#integer scale:1
		
		label endFrameSpinLabel "End frame:" pos:[16, 32] width:160 height:16
		spinner endFrameSpin "" pos:[175, 32] width:70 height:16 range:[0, animationRange.end, endFrame] type:#integer scale:1
		
		label timeLimitSpinLabel "Time limit (min.):" pos:[16, 54] width:160 height:16
		spinner timeLimitSpin "" pos:[175, 54] width:70 height:16 range:[0.0, 525600.0, asRenderer.max_render_time] type:#float scale:0.25
		
		label noiseThrLimitSpinLabel "Noise threshold:" pos:[16, 76] width:160 height:16
		spinner noiseThrLimitSpin "" pos:[175, 76] width:70 height:16 range:[0.00001, 0.99, asRenderer.aa_threshold] type:#float scale:0.01
		
		label maxPathsLimitSpinLabel "Max. paths per pixel:" pos:[16, 98] width:160 height:16
		spinner maxPathsLimitSpin "" pos:[175, 98] width:70 height:16 range:[0, 65536, asRenderer.max_paths_per_pixel] type:#integer scale:1
		
		edittext saveFileNameEdit "" text:(saveFilePath + saveFileExt) pos:[12, 120] width:208 height:17
		button saveFileNameBtn "..." pos:[226, 120] width:20 height:18

		button startPreviewBtn "Start Preview Render" pos:[16, 142] width:230 height:18
		
		button cancelPreview "Cancel" pos:[16, 164] width:230 height:18

		progressBar animProgress pos:[16, 186] width:230 height:16
		
		on startFrameSpin changed val do (
			startFrame = val
		)
		
		on endFrameSpin changed val do (
			endFrame = val
		)
		
		on timeLimitSpin changed val do (
			if (enabled) do (
				asRenderer.max_render_time = val
			)
		)
		
		on noiseThrLimitSpin changed val do (
			if (enabled) do (
				asRenderer.aa_threshold = val
			)
		)

		on maxPathsLimitSpin changed val do (
			if (enabled) do (
				asRenderer.max_paths_per_pixel = val
			)
		)
		
		on saveFileNameEdit changed val do (
			saveFilePath = (getFilenamePath val) + (getFilenameFile val)
			saveFileExt = (getFilenameType val)
		)
		
		on saveFileNameBtn pressed do (
			local newFilePath = getSaveFileName filename:saveFileNameEdit.text \
											types:"PNG Image File (*.png)|*.png|JPEG File (*.jpg)|*.jpg" \
											historyCategory:"MAXScriptFileOpenSave"
			if (newFilePath != undefined) do (
				saveFileNameEdit.text = newFilePath
				saveFilePath = (getFilenamePath newFilePath) + (getFilenameFile newFilePath)
				saveFileExt = (getFilenameType newFilePath)
			)
		)
		
		on startPreviewBtn pressed do (
			if (running == false) do (
				running = true
				startPreviewBtn.enabled = false
				animProgress.value = 0
				cFrame = startFrame
				saveFilePath = (getFilenamePath saveFileNameEdit.text) + (getFilenameFile saveFileNameEdit.text)
				saveFileExt = (getFilenameType saveFileNameEdit.text)
				
				if (vrayGetRTBitmap() != undefined) then (
					sliderTime = cFrame
					actionMan.executeAction 369690881 "1"	-- reinitialize renderer
				)
				else (
					sliderTime = cFrame
					actionMan.executeAction 0 "40701"	-- start VrayRT ActiveShade
				)
			)
		)
		
		on cancelPreview pressed do (
			startPreviewBtn.enabled = true
			running = false
		)
		
		on SettingsRollout open do (
			if (startFrame < animationRange.start) do (
				startFrame = animationRange.start
			)
			
			if (endFrame > animationRange.end) do (
				endFrame = animationRange.end
			)
		)
		
		on SettingsRollout moved pos do (
			dialogPos = pos
		)
		
		on SettingsRollout close do (
			running = false
		)
	)
	
	fn checkRenderer = (
		asRenderer = renderers.activeShade
		
		if (asRenderer != undefined) then (
			enabled = ((renderers.activeShade.classid[1] == 1770671000) and (renderers.activeShade.classid[2] == 1323107829))
		) else (
			enabled = false
		)
	)
	
	on execute do (
		checkRenderer()
		
		if (enabled) do (
			if (dialogPos != undefined) then (
				CreateDialog SettingsRollout style:#(#style_titlebar, #style_border, #style_sysmenu) pos:dialogPos modal:true
			) else (
				CreateDialog SettingsRollout style:#(#style_titlebar, #style_border, #style_sysmenu) modal:true
			)
		)
	)
	
	on isEnabled do (
		checkRenderer()
		enabled
	)
	
	on isVisible do (
		checkRenderer()
		enabled
	)

	-- Export function through global variable declaration
	global vrayRTImageComplete
	fn vrayRTImageComplete reason = (
		if (running) do (
			if ((saveFilePath != "") AND (saveFileExt != "")) do (
				local b = vrayGetRTBitmap()
				if (b != undefined) do (
					b.filename = (saveFilePath + (formattedPrint (cFrame) format:"04i") + saveFileExt)
					save b
					close b
				)
			)
			
			SettingsRollout.animProgress.value = ((((cFrame - startFrame)+1)*100)/((endFrame - startFrame)+1))
			
			if (cFrame < endFrame) then (
				cFrame += 1
				sliderTime = cFrame
				actionMan.executeAction 369690881 "1"	-- reinitialize renderer
			) else (
				SettingsRollout.startPreviewBtn.enabled = true
				running = false
			)
		)
	)
)
