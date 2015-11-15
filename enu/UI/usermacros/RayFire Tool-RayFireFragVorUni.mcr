macroScript RayFireFragVorUni
category:"RayFire Tool"
tooltip:"Fragment - Voronoi Uniform"
buttontext:"Fragment - Voronoi Uniform"

(
	on execute do
	(
		try(
			FragRolRf.FragType.selection = 7
			FragRolRf.fragment_btn.pressed ()
		) catch ()
	)
)
