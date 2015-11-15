MacroScript SelectByMaterial
	enabledIn: #("MAX", "VIZ")
	category: "Medit Tools"
	internalcategory: "Medit Tools"
	ButtonText: "Select Objects By Material"
	tooltip: "Select Objects By Material"
(
	on Execute do(
		local mat = Medit.GetCurMtl();
		
		for i in objects do(
			-- Cycle through the scene's nodes and pick up those with matching material that aren't frozen
			if(i.material == mat and not i.isFrozen and not i.isHidden) then
				selectMore i;
		)
	)
)