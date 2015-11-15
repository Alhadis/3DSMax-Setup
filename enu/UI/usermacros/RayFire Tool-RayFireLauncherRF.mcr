macroScript RayFireLauncherRF
category:"RayFire Tool"
tooltip:"Launch RayFire"
buttontext:"Launch RayFire"
Icon:#("rayfire",1)
(
	on execute do
	(
		try(If RayFireMain == undefined do StAuthRf.Launch ()) catch ()
	)
)
