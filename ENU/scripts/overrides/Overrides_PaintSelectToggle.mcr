MacroScript PaintSelectToggle
	category: "Overrides"
	buttonText: "Paint Selection Region Toggle"
	toolTip: "Paint Selection Region Toggle"
	icon: #("CustomIcons", 17)
(
	--	Note to Autodesk: Please expose the Region Select type to MAXScript.
	global pst_enabled;
	on isChecked do pst_enabled == true;
	on Execute do(
		actionMan.executeAction 0 (if(pst_enabled == true) then "59232" else "59236")
		pst_enabled	=	if(pst_enabled == true) then false else true;
	)
)