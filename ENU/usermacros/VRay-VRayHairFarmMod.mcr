macroScript VRayHairFarmMod
	category:"VRay"
	buttonText:"V-Ray HairFarm Mod"
	toolTip: "V-Ray HairFarm Mod"
(
	local enabled = false
	fn checkRenderer = (
		productRenderer = renderers.production

		if(productRenderer != undefined) then (
			enabled = ((productRenderer.classid[1] == 1941615238) and (productRenderer.classid[2] == 2012806412) or (productRenderer.classid[1] == 1770671000) and (productRenderer.classid[2] == 1323107829))
		) else (
			enabled = false
		)
	)
	
	on execute do (
		if($ == undefined) then warningToSelectGeometry "V-Ray HairFarm"
		
		if(superClassOf $ == GeometryClass) then (
			if (ValidModifier $ VRayHairFarmMod) do (
				addModifier $ (VRayHairFarmMod())
			)
		) else if(isKindOf $ ObjectSet) then (
			for obj in $ do (
				if ((superClassOf obj == GeometryClass) AND (ValidModifier obj VRayHairFarmMod)) do (
					addModifier obj (VRayHairFarmMod())
				)
			)
		)
		else (
			print "Please select a geometry object to apply V-Ray HairFarm!"
		)
	)
	
	on isEnabled return ValidModifier $ VRayHairFarmMod
	
	on isVisible do
	(
		checkRenderer()
		enabled
	)
)
