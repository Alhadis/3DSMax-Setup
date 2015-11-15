macroScript PRTVolume category:"Krakatoa" tooltip:"PRT Volume - Select Source(s) and Click to Create, or Hold SHIFT to Create Manually in the Viewport" icon:#("Krakatoa",8)
(
	on isChecked return (mcrUtils.IsCreating PRT_Volume)
	on execute do 
	(
		--local legacyParticles = #(PArray, PCloud, SuperSpray, Blizzard, Snow, Spray)
		local theObjects = (for o in selection where findItem GeometryClass.classes (classof o) > 0 AND (classof o) != TargetObject AND (classof o) != PRT_Volume AND (classof o) != ParticleGroup AND (classof o) != PF_Source AND (classof o) != KrakatoaPrtLoader collect o) --AND findItem legacyParticles (classof o) == 0 
		if keyboard.shiftPressed or theObjects.count == 0 then
		(
			StartObjectCreation PRT_Volume
		)
		else
		(
			local toSelect = for o in theObjects collect
			(
				local theBBox = o.max-o.min
				local theMaxSize = amax #(theBBox.x, theBBox.y, theBBox.z)
				local newVolume = PRT_Volume()
				newVolume.ViewportVoxelLength = theMaxSize/50.0
				newVolume.transform = o.transform
				newVolume.TargetNode = o
				newVolume.wirecolor = o.wirecolor
				newVolume.material = o.material
				newVolume.name = uniquename ("PRTVolume_" + o.name + "_")
				newVolume
			)	
			select toSelect
		)	
	)	
)
