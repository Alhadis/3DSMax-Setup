macroScript VRayFur
	category:"VRay"
	buttonText:"V-Ray Fur"
	toolTip: "Create V-Ray Fur"
(
	fn setSourceNode obj = obj.sourceNode = $
	
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
		if($ == undefined) then warningToSelectGeometry "V-Ray Fur"
		
		local vrFur = undefined
		if(superClassOf $ == GeometryClass) then (
			vrFur = VRayFur sourceNode:$ pos:$.pos
			append $.children vrFur
		) else if(isKindOf $ ObjectSet) then (
			for obj in $ do (
				if(superClassOf obj == GeometryClass) do (
					vrFur = VRayFur sourceNode:obj pos:obj.pos
					append obj.children vrFur
				)
			)
		)
		else (
			print "Please select a geometry object to apply V-Ray Fur!"
		)
	)
	
	on isEnabled do (
		checkRenderer()
		enabled AND (superClassOf $ == GeometryClass)
	)
	
	on isVisible do
	(
		checkRenderer()
		enabled
	)
)
