macroScript RayFireFragVorPart
category:"RayFire Tool"
tooltip:"Fragment - Voronoi Particles"
buttontext:"Fragment - Voronoi Particles"

(
	on execute do
	(
		try(
			FragRolRf.FragType.selection = 9
			FragRolRf.fragment_btn.pressed ()
		) catch ()
	)
)
