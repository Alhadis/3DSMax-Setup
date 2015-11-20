MacroScript ApplyEditModifier
	category:	"Overrides"
	buttonText:	"Apply Edit Modifier"
	tooltip:	"Apply Edit Modifier"
	icon:		#("Max_Edit_Modifiers", 2)
(
	on Execute do(

		if(selection.count > 0) then(
			global getTrueClass;
			
			local showEnd	=	showEndResult;
			local info		=	getTrueClass $;
			local type		=	info[1];
			local super		=	info[2];
			local altExec	=	keyboard.altPressed;
			local macro;
			
			
			--	If holding ALT key, collapse modifier stack to the appropriate editing type.
			--	*	This ignores the position of the modifier stack's selection, operating
			--		normally just as a call to the Quad menu's "Collapse to Editable {type}" would
			if(altExec) then(
				type		=	classOf $;
				super		=	superClassOf $;
				
				local sharp		=	false;
				local poly		=	undefined;
				
				
				--	Editable Patch
				if(type == Editable_Patch or type == quadPatch or type == triPatch)
					then macro	=	"Convert_to_Patch";


				--	Rectangles: Set knots to corners if no corner radii was specified
				else if(type == Rectangle) then(
					macro	=	"Convert_to_Spline";
					if($.cornerRadius == 0) then sharp = true;
				)

				else if(super == shape)		then	macro	=	"Convert_to_Spline"		--	Editable Spline
				else if(type == NURBSSurf)	then	macro	=	"Convert_to_NURBS"		--	NURBS Surface


				--	Editable Polygon
				else if(super == GeometryClass) then(
					macro		=	"Convert_to_Poly"
					
					if(classOf $.baseObject == Editable_Poly) then(
						poly	=	#();
						poly[1]	=	$.baseObject.ignoreBackfacing;
						poly[2]	=	$.baseObject.iterations;
						poly[3]	=	$.baseObject.useRenderIterations;
						poly[4]	=	$.baseObject.renderIterations;
						poly[5]	=	$.baseObject.sepByMats;
						poly[6]	=	$.baseObject.sepBySmGroups;
						poly[7]	=	$.baseObject.weldThreshold;
						poly[8]	=	$.baseObject.autoSmoothThreshold;
					)
				)


				if(macro != undefined) then(
					
					--	UPDATE 27/08/2010: Strip all modifiers above to prevent accidentally changing object's class
					global pruneModifiers, getModifierIndex;
					if(showEndResult == false) then pruneModifiers $ (getModifierIndex $);
					showEnd	=	false;
					macros.run "Modifier Stack" macro;
					
					--	Set Rectangle verts to corners if no border radius was used.
					if(sharp)			then for k = 1 to 4 do setKnotType $ 1 k #corner;
					
					--	Transfer previously used Editable_Poly properties
					else if(poly != undefined)	then(
						$.baseObject.ignoreBackfacing		=	poly[1];
						$.baseObject.iterations				=	poly[2];
						$.baseObject.useRenderIterations	=	poly[3];
						$.baseObject.renderIterations		=	poly[4];
						$.baseObject.sepByMats				=	poly[5];
						$.baseObject.sepBySmGroups			=	poly[6];
						$.baseObject.weldThreshold			=	poly[7];
						$.baseObject.autoSmoothThreshold	=	poly[8];
					)
				)
			)
			
			
			--	Add an appropriate MAX Edit Modifier
			else(
				--	Editable Patch
				if(	type == Editable_Patch	or
					type == quadPatch		or
					type == triPatch)		then
					macros.run "Modifiers" "Edit_Patch";
					
				/*	Editable Spline	*/		else if(super == shape)				then	macros.run "Modifiers" "Edit_Spline"
				/*	Editable Poly	*/		else if(super == GeometryClass)		then	macros.run "Modifiers" "EditPolyMod"
			)
			
			--	Restore "Show End Result" to previous state
			showEndResult	=	showEnd;
		)
		
	)
)