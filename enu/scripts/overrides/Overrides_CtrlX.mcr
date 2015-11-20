MacroScript CtrlX
	category:	"Overrides"
	buttonText: "Split/Break"
	tooltip:	"Split/Break"
(

	on Execute do(
		local obj	=	Filters.getModOrObj();
		
		-- Editable Spline
		if(Filters.Is_EditSplineSpecifyLevel #{2..3}) then(
			-- Break Vertex
			if(subobjectlevel == 1)	then macros.run "Editable Spline Object" "ESpline_Break"
			
			-- Detach Segments (Same Shape)
			else if(subobjectlevel == 2) then(
				
				/* Normally, this would've been done using the splineOps.Detach method, except
				it relies on whatever "detach" settings the user has selected in the Command
				Panel. With no way to preemptively target the "Same Shp" property either, this was
				the only alternative. */
			)
		)
		
		--	Editable Mesh
		else if(Filters.Is_EditMesh()) then(
			if(obj == $.baseObject)
				then	meshOp.detachFaces obj (getFaceSelection $)
				else	meshOps.detach obj
		)
		
		--	Editable Poly
		else if(Filters.Is_EPolySpecifyLevel #{2,3,5,6}) then
			case subobjectlevel of(
				1:	macros.run "Editable Polygon Object" "EPoly_VBreak"
				2:	macros.run "Editable Polygon Object" "EPoly_Split"
				default:
					if(obj == $.baseObject)
						then	obj.detachToElement #Face keepOriginal:false
						else(
							global meshRefresh;
							local p, uName	=	uniqueName "polyTemp_";
							obj.detachToObject uName;
							p	=	meshRefresh (getNodeByName uName);
							centerPivot p;
							obj.attach p;
						)
			)
		
		-- Editable Patch
		else if(Filters.Is_EditPatchSpecifyLevel #{2,3}) then(
			try(
				obj	=	if($.baseObject == obj) then $ else obj;
				patchOps.break obj;
				patch.update obj;
			) catch()
		)
		
		else if(mcrUtils.ValidMod XForm) then(
			macros.run "Modifiers" "XForm"
			subobjectlevel = 1;
		)
	)
)