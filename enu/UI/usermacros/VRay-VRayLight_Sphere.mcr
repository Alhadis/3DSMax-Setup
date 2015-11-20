macroScript VRayLight_Sphere
	category:"VRay"
	buttonText:"V-Ray Sphere Light"
	toolTip: "Create V-Ray Sphere Light"
(
	fn setType obj = (obj.type = 2)
	
	on execute do StartObjectCreation VRayLight newNodeCallback: setType
)
