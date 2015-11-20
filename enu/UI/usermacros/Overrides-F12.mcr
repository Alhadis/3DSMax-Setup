macroScript F12
	category: "Overrides"
	buttonText: "Show Last Render"
	toolTip: "Show Last Render"
	icon: #("Maintoolbar", 101)
(
	on Execute do with undo off(
		local vr	=	renderers.current;
		if(isKindOf renderers.current VRay)
			then	vr.showLastVFB();
			else	actionMan.executeAction 0 "348"; --max show vfb
	)
) 