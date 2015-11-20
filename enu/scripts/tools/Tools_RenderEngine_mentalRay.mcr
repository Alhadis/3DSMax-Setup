MacroScript RenderEngine_mentalRay
	category: "Tools"
	tooltip: "Change Rendering Engine to mental Ray"
	buttonText: "Change Rendering Engine to mental Ray"
	icon:#("CustomIcons", 9)
(
	on isChecked do classOf renderers.current == mental_ray_renderer;
	on Execute do(
		if(classOf renderers.current != mental_ray_renderer) then
			renderers.current	=	mental_ray_renderer();
	)
)