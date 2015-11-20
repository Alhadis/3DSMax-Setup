MacroScript ZapMaterial
	category: "Medit Tools"
	internalcategory:"Medit Tools"
	buttonText: "Zap Material"
	tooltip: "Zap Material"
(
	on Execute do(
		
		--	Create and assign the default material to the selected material slot
		local slot				=	activeMeditSlot;
		local matName			=	((if(slot < 10) then "0" else "") + (slot as String)) + " - Default";
		local blank				=	StandardMaterial();
		blank.name				=	matName;
		
		--	CTRL held: Strip material from any objects in scene as well
		if(keyboard.controlPressed) then(
			local mat	=	Medit.GetCurMtl();
			for i in objects where i.material == mat do i.material = undefined;
		)
		
		meditMaterials[slot]	=	blank;
		
		clearUndoBuffer();
	)
)