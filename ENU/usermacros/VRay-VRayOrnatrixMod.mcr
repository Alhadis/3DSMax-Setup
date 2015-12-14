macroScript VRayOrnatrixMod
	category:"VRay"
	buttonText:"V-Ray Ornatrix Mod"
	toolTip: "V-Ray Ornatrix Mod"
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
	
	on execute do 
	(
		if(superClassOf $ == GeometryClass) then (
			if (ValidModifier $ VRayOrnatrixMod) do (
				addModifier $ (VRayOrnatrixMod())
			)
		) else if(isKindOf $ ObjectSet) then (
			for obj in $ do (
				if ((superClassOf obj == GeometryClass) AND (ValidModifier obj VRayOrnatrixMod)) do (
					addModifier obj (VRayOrnatrixMod())
				)
			)
		)
		else (
			warningToSelectGeometry "Ornatrix Modifier"
		)
	)
	
	on isEnabled return ValidModifier $ VRayOrnatrixMod
	
	on isVisible do
	(
		checkRenderer()
		enabled
	)
)
