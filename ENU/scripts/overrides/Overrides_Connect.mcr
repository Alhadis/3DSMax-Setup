macroScript Connect
	category:"Overrides"
	buttonText:"Connect"
	tooltip:"Connect"
(
	
	global connectSelKnots;
	function connectSelKnots obj multiple:false = (
		global findOpenKnots, connectKnots;
		local k	=	findOpenKnots obj onlySelected:true;
		if(k.count > 1) then(
			
			if(multiple) then(
				-- Hmm, we'll get to this later...
			)
			
			else connectKnots obj k[1] k[2]
		)
		else false;
	)
	
	
	on IsVisible do Filters.Is_EditSpline();
	on execute do(
		if(selection.count > 0 and getCommandPanelTaskMode() != #modify)
			then max modify mode;
		
		local obj	=	Filters.getModOrObj();
		
		
		-- Editable Poly
		if(Filters.Is_EPoly()) then(
			
			--	Edges
			if(subobjectlevel == 2) then(
				obj.connectEdgeSegments	=	1;
				obj.connectEdgePinch	=	0;
				obj.connectEdgeSlide	=	0;
				macros.run "Editable Polygon Object" "EPoly_EConnect"
			)
			
			--	Vertices
			else if(subobjectlevel == 1) then
				macros.run "Editable Polygon Object" "EPoly_VConnect"
			
			--	Polygons/Borders
			else if(subobjectlevel == 4 or subobjectlevel == 3) then(
				local buttOp	=	if(subobjectlevel == 3) then #BridgeBorder else #BridgePolygon;
				if($.baseObject == obj)
					then	obj.bridge();
					else	obj.buttonOp buttOp
			)
		)

		-- Editable Patch
		else if(Filters.Is_EditPatchSpecifyLevel #{3,4}) then
			patchOps.subdivide (if $.baseObject == obj then $ else obj);
		
		-- Editable Spline
		else if(Filters.Is_EditSpline()) then(
			
			--	Because the Edit_Spline modifier is largely inaccessible to MAXScript, this is all we can do.
			if($.baseObject != obj) then(
				subobjectlevel = 1;
				macros.run "Editable Spline Object" "ESpline_Connect";
			)
			
			else if(subobjectlevel == 1) then(
				result	=	connectSelKnots $;
				if(not(result)) then
					macros.run "Editable Spline Object" "ESpline_Connect";
			)
			else macros.run "Editable Spline Object" "ESpline_Connect";
			
			/*
			else if(so == 2) then(
				result	=	connectSelSegs $;
				if(not(result)) then
					macros.run "Editable Spline Object" "ESpline_Connect";
			)*/
		)
	)
)
