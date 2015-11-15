MacroScript RenderEngine_Scanline
	category: "Tools"
	tooltip: "Change Rendering Engine to Scanline"
	buttonText: "Change Rendering Engine to Scanline"
	icon:#("CustomIcons", 10)
(
	on isChecked do classOf renderers.current == Default_Scanline_Renderer;
	on Execute do(
		if(classOf renderers.current != Default_Scanline_Renderer) then
			renderers.current	=	Default_Scanline_Renderer();
	)
)