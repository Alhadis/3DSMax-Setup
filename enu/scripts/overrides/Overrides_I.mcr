MacroScript I
	category:"Overrides"
	buttonText:"Ignore Backfacing / Interactive Pan"
	tooltip:"Ignore Backfacing / Interactive Pan"
(

	on Execute do with undo off(
		local obj		=	Filters.GetModOrObj();


		--	Unwrap UVW: Toggle backfacing, regardless of sublevel
		if(isKindOf obj Unwrap_UVW) then
			obj.setIgnoreBackFaceCull (not obj.getIgnoreBackFaceCull());


		--	Editable Poly: Toggle "Ignore Backfacing" property
		else if(Filters.Is_EPoly()) then(
			try		obj.ignoreBackfacing = (not obj.ignoreBackfacing);
			catch	max ipan;
		)


		-- Editable Mesh
		else if(Filters.Is_EditMesh()) then(
			try(
				if(obj == $.baseObject)
					then	meshop.setUIParam obj #IgBack	((meshop.getUIParam obj #IgBack) != 1);
					else	meshop.setUIParam $ obj #IgBack	((meshop.getUIParam $ obj #IgBack) != 1);
			)	catch()
		)


		--	Default: "Interactive Pan" command
		else max ipan;
	)
)