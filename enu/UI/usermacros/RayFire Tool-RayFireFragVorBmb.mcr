macroScript RayFireFragVorBmb
category:"RayFire Tool"
tooltip:"Fragment - Voronoi Bomb\Impact"
buttontext:"Fragment - Voronoi Bomb\Impact"

(
	on execute do
	(
		try(
			FragRolRf.FragType.selection = 8
			FragRolRf.fragment_btn.pressed ()
		) catch ()
	)
)
