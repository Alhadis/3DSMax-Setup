macroScript VRayAmbientLight
	category:"VRay"
	buttonText:"V-Ray Ambient Light"
	toolTip: "Create V-Ray Ambient Light"
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
	
	on execute do StartObjectCreation VRayAmbientLight
		
	on isEnabled do
	(
		checkRenderer()
		enabled
	)
	
	on isVisible do
	(
		checkRenderer()
		enabled
	)
)