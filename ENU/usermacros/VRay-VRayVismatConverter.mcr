macroScript VRayVismatConverter category:"VRay" buttontext:"V-Ray vrmat converter" tooltip:"Converts 3dsMax V-Ray materials to a .vrmat file" (
	
	on execute do createDialog vrayVismatConverterRollout modal: false
	
	local enabled = false
	fn checkRenderer = (
		productRenderer = renderers.production

		if(productRenderer != undefined) then (
			enabled = ((productRenderer.classid[1] == 1941615238) and (productRenderer.classid[2] == 2012806412) or (productRenderer.classid[1] == 1770671000) and (productRenderer.classid[2] == 1323107829))
		) else (
			enabled = false
		)
	)
	
	on isEnabled do (
		checkRenderer()
		enabled
	)
	
	on isVisible do
	(
		checkRenderer()
		enabled
	)
)
