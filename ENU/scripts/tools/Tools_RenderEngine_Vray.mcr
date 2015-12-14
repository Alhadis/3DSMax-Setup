MacroScript RenderEngine_Vray
	category: "Tools"
	tooltip: "Change Rendering Engine to V-Ray"
	buttonText: "Change Rendering Engine to V-Ray"
	icon:#("CustomIcons", 8)
(
	on isChecked do classOf renderers.current == VRay;
	on Execute do(
		if(classOf renderers.current != VRay and VRay != undefined) then(
			global vrayPref;
			renderers.current	=	VRay();
			vrayPref();
		)
	)
)