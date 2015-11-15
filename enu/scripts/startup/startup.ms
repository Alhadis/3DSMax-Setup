base	=	getDir #userScripts;

fileIn		(base	+	"/inc/Inc_Utils.ms");
fileIn		(base	+	"/inc/Inc_Subsinker.ms");
fileIn		(base	+	"/inc/Inc_SplineTools.ms");
fileIn		(base	+	"/inc/Inc_PolyMeshTools.ms");
fileIn		(base	+	"/inc/Inc_LegacyViewports.ms");
fileIn		(base	+	"/inc/Inc_ReferenceImages.ms");
fileIn		(base	+	"/inc/Inc_Other.ms");


--	Set common viewport configuration settings.
global configureViewports;
function configureViewports = (
	local restore	=	viewport.activeViewport;
	for i = 1 to viewport.numViews do with redraw off(
		viewport.activeViewport = i;
		viewport.SetTransparencyLevel 3;
		viewport.SetShowEdgeFaces true;
		viewport.SetRenderLevel #smooth
		actionMan.executeAction 0 "370";	--	Show Selection Bracket Toggle
	)
	-- Restore the active viewport to what we had before.
	viewport.activeViewport = restore;
)


--	Preferred defaults for V-Ray
global vrayPref;
function vrayPref = (
	-- Disable VRay's infuriating feedback window that's displayed by default.
	try(
		local vr = renderers.current;
		vr.system_vrayLog_show	=	false;
		vr.imageSampler_type	=	1;						/* Adaptive DMC */
		vr.filter_kernel		=	Mitchell_Netravali();	/* Mitchell-Netravali*/
		vr.colorMapping_gamma	=	2.2;
		
		renderPresets.loadAll 0 (GetDir #renderPresets + "/vray.default.rps");
	)
	catch()
)



--	Revert to default region selection type
actionMan.executeAction 0 "59232"  -- Selection: Rectangular Selection Region
global pst_enabled; pst_enabled = off;


vrayPref();

--	Set to Generic Units only
units.DisplayType	= #Generic;

--	Enable Angle Snap toggle by default
max angle snap toggle;

--	Enable Key Mode Toggle
max key mode;


configureViewports();

-- Tools: Maximize Viewport Toggle
actionMan.executeAction 0 "50026"