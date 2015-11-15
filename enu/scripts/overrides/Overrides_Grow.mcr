MacroScript Grow
	category:	"Overrides"
	buttonText:	"Grow Selection"
	tooltip:	"Grow Selection"
(
	on Execute do(
		local obj;
		
		--	Editable Poly
		if(Filters.Is_EPolySpecifyLevel #{2..6}) then
			macros.run "Editable Polygon Object" "EPoly_Grow"
		
		--	Editable Patch
		else if(Filters.Is_EditPatchSpecifyLevel #{2..5}) then(
			obj	=	Filters.getModOrObj();
			patchOps.growSelection (if($.baseObject == obj) then $ else obj);
		)
		
		
		else(
			obj	=	modPanel.getCurrentObject();
			
			--	Unwrap UVWs
			if(isKindOf obj Unwrap_UVW) then(
				
				--	Editing window's open
				if(obj.getWindowW() > 0 and obj.getWindowH() > 0) then
					obj.expandSelection();
				
				else case subobjectlevel of(
					1:	obj.expandGeomVertexSelection()
					2:	obj.expandGeomEdgeSelection()
					3:	obj.expandGeomFaceSelection()
				)
			)
		)
	)
)