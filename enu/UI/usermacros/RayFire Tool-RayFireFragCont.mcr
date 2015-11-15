macroScript RayFireFragCont
category:"RayFire Tool"
tooltip:"Fragment - Continuous"
buttontext:"Fragment - Continuous"

(
	on execute do
	(
		try(
			FragRolRf.FragType.selection = 6
			FragRolRf.fragment_btn.pressed ()
		) catch ()
	)
)
