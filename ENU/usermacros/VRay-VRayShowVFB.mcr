macroScript VRayShowVFB category:"VRay" buttontext:"V-Ray VFB" tooltip:"Displays the last rendered V-Ray VFB, if is exists" (
	r=renderers.production
	cls=r.classid
	if (cls[1]==1941615238 and cls[2]==2012806412) then r.showLastVFB()
	if (cls[1]==1770671000 and cls[2]==1323107829) do r.V_Ray_settings.showLastVFB()
)
