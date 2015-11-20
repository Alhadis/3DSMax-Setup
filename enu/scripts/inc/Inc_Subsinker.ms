--=====================================================================================================
/*		SUBSINKER INTERFACE 	*/
--=====================================================================================================
global subsinker;
struct subsinker
(
	enabled	=	true,
	
	--	Returns TRUE if current modifier holds one of the familiar subobject levels common to the usual
	--	interface of working with editable meshes and shapes - Vertex, Edge/Segment, and Spline/Face/Border.
	--	*	Use the #target keyword to specify a different modifier.
	fn canSwitch1to3 target:unsupplied = (
		local type	=	classOf (if(target == unsupplied or target == undefined) then (modPanel.getCurrentObject()) else target);
		(type == Edit_Poly)			or	(type == Edit_Mesh)		or	(type == Edit_Patch)	or	(type == Edit_Spline)	or	\
		(type == Mesh_Select)		or	(type == Patch_Select)	or	(type == Poly_Select)	or	(type == SplineSelect)	or	\
		(type == Line)				or	(type == SplineShape)	or	(type == Editable_Poly)	or	(type == Editable_mesh)	or	\
		(type == Editable_Patch);
	),

	fn canSwitch1 target:unsupplied =	(	canSwitch1to3 target:target;	),
	fn canSwitch2 target:unsupplied =	(	canSwitch1to3 target:target;	),
	fn canSwitch3 target:unsupplied =	(	canSwitch1to3 target:target;	),
	fn canSwitch4 target:unsupplied =	(
		local type	=	classOf (if(target == unsupplied or target == undefined) then (modPanel.getCurrentObject()) else target);
		(type == Edit_Poly)		or	(type == Edit_Mesh)		or	(type == Edit_Patch)	or	(type == Mesh_Select)	or	\
		(type == Patch_Select)	or	(type == Poly_Select)	or	(type == Editable_Poly)	or	(type == Editable_mesh)	or	\
		(type == Editable_Patch);
	),

	fn canSwitch5 target:unsupplied =	(	canSwitch4 target:target;		),
	fn canSwitch6 target:unsupplied	=	(
		local type	=	classOf (if(target == unsupplied or target == undefined) then (modPanel.getCurrentObject()) else target);
		(type == Patch_Select) or (type == Editable_Patch) or (type == Edit_Patch);
	),


	methods =	#(	\
					#(canSwitch1to3, "SubObject_1"),	\
					#(canSwitch1to3, "SubObject_2"),	\
					#(canSwitch1to3, "SubObject_3"),	\
					#(canSwitch4, "SubObject_4"),		\
					#(canSwitch5, "SubObject_5")		\
				),
				
				
	--	Returns the next modifier down the stack with a matching subobject level
	fn findNext obj level = (
		local result;
		
		if(obj == undefined)
			then undefined;
		
		else(
			local obj	=	if(classOf obj == ObjectSet) then obj[1] else obj;
			local count	=	(obj.modifiers).count;
			local start	=	getModifierIndex obj
			
			local searching	=	true;
			for i = start to count+1 while searching do(
				result	=	if(i <= count) then obj.modifiers[i] else obj.baseObject;
				if(methods[level][1] target:result) then
					searching	=	false;
				else	result	=	undefined;
			)
		)
		
		result;
	),

	--	Top-level subobject selection method.
	fn s lvl = (
		if(enabled) then(
			
			if(selection.count > 0) then(
				if(subobjectlevel == undefined) then max modify mode;
				if(selection.count == 1 or (selection.count > 1 and instancedSel selection)) then(
					local obj	=	if(classOf $ == ObjectSet) then $[1] else $;
					local check	=	methods[lvl][1];
					
					if(check()) then
						macros.run "Modifier Stack" methods[lvl][2];
					else(
						local next	=	findNext obj lvl;
						if(check target:next) then(
							modPanel.setCurrentObject next node:obj;
							macros.run "Modifier Stack" methods[lvl][2];
							if(showEndResult == false) then
								showEndResult = true;
						)
					)
				)
			)
		)
		else	-- Subsink scripts have been disabled; run macros normally.
			macros.run "Modifier Stack" methods[lvl][2];
	),
	
	fn s1	=	( s 1 ),
	fn s2	=	( s 2 ),
	fn s3	=	( s 3 ),
	fn s4	=	( s 4 ),
	fn s5	=	( s 5 )
)

global subsink;	subsink	=	subsinker();
--=====================================================================================================