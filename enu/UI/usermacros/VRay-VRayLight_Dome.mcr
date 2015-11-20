macroScript VRayLight_Dome
	category:"VRay"
	buttonText:"V-Ray Dome Light"
	toolTip: "Create V-Ray Dome Light"
(
	fn setType obj = (obj.type = 1)
	
	on execute do StartObjectCreation VRayLight newNodeCallback: setType
)
