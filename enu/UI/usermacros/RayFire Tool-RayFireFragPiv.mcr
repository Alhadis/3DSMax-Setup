macroScript RayFireFragPiv
category:"RayFire Tool"
tooltip:"Fragment - Pivot"
buttontext:"Fragment - Pivot"

(
	on execute do
	(
		try(
			FragRolRf.FragType.selection = 5
			FragRolRf.fragment_btn.pressed ()
		) catch ()
	)
)
