macroScript RayFireFragMs
category:"RayFire Tool"
tooltip:"Fragment - Mouse Cursor"
buttontext:"Fragment - Mouse Cursor"

(
	on execute do
	(
		try(
			FragRolRf.FragType.selection = 4
			FragRolRf.fragment_btn.pressed ()
		) catch ()
	)
)
