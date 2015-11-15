macroScript SelectLoop
	category:"Overrides"
	buttonText:"Select Loop"
	tooltip:"Select Loop"
(
	On Execute Do(
		local obj;
		
		if(selection.count > 0 and getCommandPanelTaskMode() != #modify)
			then max modify mode;

		--	Editable Poly
		if(Filters.Is_EPolySpecifyLevel #{3}) then
			macros.run "Editable Polygon Object" "EPoly_Select_Loop"

		--	Editable Patch
		else if(Filters.Is_EditPatchSpecifyLevel #{3}) then(
			obj	=	Filters.getModOrObj();
			patchOps.selectEdgeLoop (if $.baseObject == obj then $ else obj);
		)


		else(
			obj	=	modPanel.getCurrentObject();
			
			--	Unwrap UVWs
			if(isKindOf obj Unwrap_UVW) then(
				
				--	Editing window's open
				if(obj.getWindowW() > 0 and obj.getWindowH() > 0)
					then	obj.uvLoop 0
				
				--	Standard geometry edge loop
				else if(subobjectlevel == 2) then
					obj.geomEdgeLoopSelection();
			)

			--	Next Keyframe
			else with undo (maxOps.setKeyMode) max time forward;
		)
	)
)