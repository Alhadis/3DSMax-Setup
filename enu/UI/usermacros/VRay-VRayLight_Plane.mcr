macroScript VRayLight_Plane
	category:"VRay"
	buttonText:"V-Ray Plane Light"
	toolTip: "Create V-Ray Plane Light"
(
	fn setType obj = (obj.type = 0)
	
	on execute do StartObjectCreation VRayLight newNodeCallback: setType
)
