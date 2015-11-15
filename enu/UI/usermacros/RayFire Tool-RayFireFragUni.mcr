macroScript RayFireFragUni
category:"RayFire Tool"
tooltip:"Fragment - Unform"
buttontext:"Fragment - Unform"

(
	on execute do
	(
		try(
			FragRolRf.FragType.selection = 1
			FragRolRf.fragment_btn.pressed ()
		) catch ()
	)
)
