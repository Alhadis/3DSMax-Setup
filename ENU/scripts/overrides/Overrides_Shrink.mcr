MacroScript Shrink
	category:	"Overrides"
	buttonText:	"Shrink Selection"
	tooltip:	"Shrink Selection"
(
	on Execute do(
		local obj;
		
		--	Editable Poly
		if(Filters.Is_EPolySpecifyLevel #{2..6}) then
			macros.run "Editable Polygon Object" "EPoly_Shrink"
		
		--	Editable Patch
		else if(Filters.Is_EditPatchSpecifyLevel #{2..5}) then(
			obj	=	Filters.getModOrObj();
			patchOps.shrinkSelection (if($.baseObject == obj) then $ else obj);
		)


		else(
			obj	=	modPanel.getCurrentObject();
			
			--	Unwrap UVWs
			if(isKindOf obj Unwrap_UVW) then(
				
				--	Editing window's open
				if(obj.getWindowW() > 0 and obj.getWindowH() > 0) then
					obj.contractSelection();
				
				else case subobjectlevel of(
					1:	obj.contractGeomVertexSelection()
					2:	obj.contractGeomEdgeSelection()
					3:	obj.contractGeomFaceSelection()
				)
			)
		)
	)
)