macroScript RayFireFragBmb
category:"RayFire Tool"
tooltip:"Fragment - Bomb\Impact"
buttontext:"Fragment - Bomb\Impact"

(
	on execute do
	(
		try(
			FragRolRf.FragType.selection = 3
			FragRolRf.fragment_btn.pressed ()
		) catch ()
	)
)
