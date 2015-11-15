macroScript VRayLight_Mesh
	category:"VRay"
	buttonText:"V-Ray Mesh Light"
	toolTip: "Create V-Ray Mesh Light"
(
	fn setType obj = (obj.type = 3)
	
	on execute do StartObjectCreation VRayLight newNodeCallback: setType
)
