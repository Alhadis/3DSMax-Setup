macroScript RayFireFragIrr
category:"RayFire Tool"
tooltip:"Fragment - Irregular"
buttontext:"Fragment - Irregular"

(
	on execute do
	(
		try(
			FragRolRf.FragType.selection = 2
			FragRolRf.fragment_btn.pressed ()
		) catch ()
	)
)
