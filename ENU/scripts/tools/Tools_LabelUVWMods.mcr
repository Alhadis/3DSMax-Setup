MacroScript LabelUVWMods
	category: "Tools"
	buttonText: "Label UV Map Modifiers"
	tooltip: "Label UV Map Modifiers"
	icon: #("Material_Modifiers", 1)
(
	fn labelMods obj pattern:"UVs - %" = (
		if(isKindOf obj Node) then(
			local mat	=	obj.material;
			if(isKindOf mat Multimaterial) then(
				local names	=	mat.names;
				local chan;
				suspendEditing();
				
				try(
					for i in obj.modifiers where (isKindOf i UVWMap) do(
						chan	=	i.mapChannel;
						if(names[chan] != undefined and names[chan] != "") then
							i.name	=	substituteString pattern "%" names[chan];
					)
				)
				catch()
				
				resumeEditing();
			)
		)
		
		else for i in obj do labelMods i;
	)
	
	on isEnabled do mcrUtils.ValidMod Uvwmap
	on Execute do labelMods $;
)