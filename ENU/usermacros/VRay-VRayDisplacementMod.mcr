macroScript VRayDisplacementMod
	category:"VRay"
	buttonText:"V-Ray Displacement Mod"
	toolTip: "V-Ray Displacement Mod"
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
		if($ == undefined) then warningToSelectGeometry "Displacement Modifier"
		
		if(superClassOf $ == GeometryClass) then (
			if (ValidModifier $ VRayDisplacementMod) do (
				addModifier $ (VRayDisplacementMod())
			)
		) else if(isKindOf $ ObjectSet) then (
			for obj in $ do (
				if ((superClassOf obj == GeometryClass) AND (ValidModifier obj VRayDisplacementMod)) do (
					addModifier obj (VRayDisplacementMod())
				)
			)
		)
		else (
			print "Please select a geometry object to apply Displacement Modifier!"
		)
	)
	
	on isEnabled return ValidModifier $ VRayDisplacementMod
	
	on isVisible do
	(
		checkRenderer()
		enabled
	)
)
