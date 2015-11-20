macroScript VRayFur
	category:"VRay"
	buttonText:"V-Ray Fur"
	toolTip: "Create V-Ray Fur"
(
	fn setSourceNode obj = obj.sourceNode = $
	
	on execute do startObjectCreation Vrayfur newNodeCallback: setSourceNode
	on isEnabled do (superClassOf $ == GeometryClass)
)
