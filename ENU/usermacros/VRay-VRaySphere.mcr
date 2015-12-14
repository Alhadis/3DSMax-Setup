macroScript VRaySphere
	category:"VRay"
	buttonText:"V-Ray Sphere"
	toolTip: "Create V-Ray Sphere"
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
	
	on execute do StartObjectCreation VRaySphere
	
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
