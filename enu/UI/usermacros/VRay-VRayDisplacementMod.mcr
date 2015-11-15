macroScript VRayDisplacementMod
	category:"VRay"
	buttonText:"V-Ray Displacement Mod"
	toolTip: "V-Ray Displacement Mod"
(
	on execute do AddMod VRayDisplacementMod
	on isEnabled return ValidModifier $ VRayDisplacementMod
)
