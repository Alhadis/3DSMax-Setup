MacroScript Attach
	category: "Overrides"
	buttonText: "Attach"
	tooltip: "Attach"
(
	on Execute do(
		local obj	=	Filters.GetModOrObj();
		
		--	Poly
		if(Filters.Is_EPoly()) then
			if(keyboard.shiftPressed) then
				if(obj == $.baseObject)
					then	obj.buttonOp #AttachList
					else	obj.popupDialog #Attach
			else obj.enterPickMode #Attach
		
		--	Spline
		else if(Filters.Is_EditSpline()) then
			if(keyboard.shiftPressed)
				then	splineOps.attachMultiple (if(obj == $.baseObject) then $ else obj);
				else	macros.run "Editable Spline Object" "ESpline_Attach"
		
		--	Mesh
		else if(Filters.Is_EditMesh()) then(
			if(keyboard.shiftPressed)
				then	meshOps.attachList (if(obj == $.baseObject) then $ else obj);
				else	macros.run "Editable Mesh Object" "EMesh_Attach"
		)
		
		--	Patch
		else if(Filters.Is_EditPatch()) then
			macros.run "Editable Patch Object" "EPatch_Attach"
	)
	
)