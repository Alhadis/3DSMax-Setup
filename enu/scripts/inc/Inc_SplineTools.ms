--	Returns TRUE if object tests as a valid spline object.
--	*	Adopted from "Is_EditSpline" function defined in "filterFunctions.ms"
global isSpline;
function isSpline obj = (
	if obj == undefined or obj == unsupplied then false
	else try(
		local obj = if obj.modifiers.count == 0 then obj.baseobject else modPanel.getCurrentObject()
		local CO_class = classOf obj
		findItem #(Edit_Spline, Line, SplineShape) CO_class != 0
	)
	catch(false)
)


--	Returns the nearest editable spline object modifier
global dropToSplineModifier;
function dropToSplineModifier obj returnIndex:false = (
	local result, index;
	if(obj == undefined) then undefined;
	else(
		local obj	=	if(classOf obj == ObjectSet) then obj[1] else obj;
		local count	=	(obj.modifiers).count;
		local start	=	getModifierIndex obj;

		local searching	=	true;
		for i = start to count+1 while searching do(
			result	=	if(i <= count) then obj.modifiers[i] else obj.baseObject;
			index	=	i;
			if(isEditModOrObj result Shape)
				then	searching	=	false;
				else	result		=	undefined;
		)

		--	Decide whether to return the modifier index or the modifier itself
		if(returnIndex and result != undefined)
			then	(if(index <= count) then index else 0)
			else	result;
	)
)


--	Draws a line between two points
global drawLine;
function drawLine p1 p2 = (
	local spline	=	SplineShape pos:p1
	addNewSpline spline;
	addKnot spline 1 #corner #line p1
	addKnot spline 1 #corner #line p2
	updateShape spline;
	spline;
)


--	Returns TRUE if knot is at the start or end of an open spline
global isKnotOpen;
function isKnotOpen obj p1 = (
	if(obj != undefined) then(1
		if(isClosed obj p1[1])
			then	false;
			else	p1[2] == 1 or p1[2] == (numKnots obj p1[1])
	)
	else false;
)


--	Connects two open points in an editable spline with a new segment
global connectKnots;
function connectKnots obj p1 p2 = (
	global isKnotOpen;
	if(isKnotOpen obj p1 and isKnotOpen obj p2) then(
		global dropKnotSelection, guessKnotByPos;
		local pos1		=	getKnotPoint obj p1[1] p1[2];
		local pos2		=	getKnotPoint obj p2[1] p2[2];
		local t1		=	getKnotType obj p1[1] p1[2];
		local t2		=	getKnotType obj p2[1] p2[2];
		
		local new	=	addNewSpline obj;
		addKnot obj new #corner #line pos1;
		addKnot obj new #corner #line pos2;
		updateShape obj;
		
		dropKnotSelection obj;
		if(p1[1] == p2[1]) then
			setKnotSelection obj p1[1] #(p1[2], p2[2]);
		else(
			setKnotSelection obj p1[1] #(p1[2]);
			setKnotSelection obj p2[1] #(p2[2]);
		)
		
		setKnotSelection obj new #(1, 2);
		weldSpline obj 0.01;
		updateShape obj;
		
		pos1	=	guessKnotByPos obj pos1;
		pos2	=	guessKnotByPos obj pos2;
		
		--	If either of the initial knots were corners, restore their types from BezierCorner
		if(t1 == #corner) then	setKnotType obj pos1[1] pos1[2] #corner;
		if(t2 == #corner) then	setKnotType obj pos2[1] pos2[2] #corner;
		
		--	Try and recover the initially selected vertices	
		if(pos1[1] == pos2[1]) then
			setKnotSelection obj pos1[1] #(pos1[2], pos2[2]);
		else(
			setKnotSelection obj pos1[1] #(pos1[2]);
			setKnotSelection obj pos2[1] #(pos2[2]);
		)
		true
	)
	else false;
)



--	Reverses the vertex order of each spline held in an editable shape's base level. Modifiers are ignored.
--	*	If ignoreClosed is TRUE, only open splines are reversed
--	*	Returns TRUE if the operation was successful.
global reverseSplineBase;
function reverseSplineBase obj ignoreClosed:true = (

	if(obj != undefined) then(
		local type			=	classOf obj.baseObject;
		if(type == SplineShape or type == Line) then(
			local restore		=	getModifierIndex obj;
			local so;
			
			with redraw off(
				modPanel.setCurrentObject obj.baseObject;
				so				=	subobjectlevel;
				subobjectLevel	=	3;
				
				for s = 1 to numSplines obj do
					if(not(ignoreClosed) or not(isClosed obj s)) then
						reverse obj s
				
				updateShape obj
				subobjectLevel	=	so;
				if(restore > 0) then
					modPanel.setCurrentObject obj.modifiers[restore];
			)
			true;
		)
		else false;
	)
	else false;
)


--	Returns information about the first knot located in a shape object
global getShapeOrigin;
function getShapeOrigin obj = (
	global dropToSplineModifier, pruneModifiers;
	local first, second, out;
	
	local closest	=	dropToSplineModifier obj returnIndex:true;

	--	Fetch from SplineShape
	if(closest == 0) then(
		first	=	getKnotPoint obj 1 1;
		second	=	getKnotPoint obj 1 2;
		out		=	#(first, second);
	)

	--	Fetch from a collapsed copy.
	else if(isKindOf obj.baseObject Shape) then(
		local clone		=	copy obj;
		pruneModifiers clone (if(closest != undefined) then closest else 0);

		convertToSplineShape clone;
		
		first	=	getKnotPoint clone 1 1;
		second	=	getKnotPoint clone 1 2;
		
		out		=	#(first, second);
		delete clone;
	)
	out;
)



--	Drops the spline's currently selected segments.
global dropSegSelection;
function dropSegSelection obj spline:unsupplied = (
	if(spline == unsupplied or spline == undefined) then
		for s = 1 to numSplines obj do
			setSegSelection obj s #();
	else	setSegSelection obj spline #();
)


--	Drops the spline's currently selected vertices.
global dropKnotSelection;
function dropKnotSelection obj spline:unsupplied = (
	if(spline == unsupplied or spline == undefined) then
		for s = 1 to numSplines obj do
			setKnotSelection obj s #();
	else	setKnotSelection obj spline #();
)


--	Returns a multidimensional array composed of a spline's open knots
global findOpenKnots;
function findOpenKnots obj onlySelected:false = (
	local out	=	#();
	if(obj != undefined) then(
		for l = 1 to numSplines obj do(
			if(isClosed obj l == false) then(
				num_knots	=	numKnots obj l;
				if(onlySelected) then(
					sel			=	getKnotSelection obj l;
					if(findItem sel 1 != 0) then			append out #(l, 1);
					if(findItem sel num_knots != 0) then	append out #(l, num_knots);
				)
				else(
					append out #(l, 1);
					append out #(l, num_knots);
				)
			)
		)
	)
	out;
)


--	Attempts to locate the closest matching knot with the designated position.
--	*	Helpful for relocating reindexed vertices that may have been lost from scripted changes.
global guessKnotByPos;
function guessKnotByPos obj pos thresh:0.1 singular:true = (
	local out	=	undefined;
	
	if(obj != undefined) then(
		local knotPos;
		local searching	=	true;
		
		--	Replace blank return value with an empty array instead
		if(not(singular)) then out = #();
		
		for l = 1 to numSplines obj while searching do(
			
			for k = 1 to numKnots obj l while searching do(
				knotPos	=	getKnotPoint obj l k;
				if(distance knotPos pos <= thresh) then(
					if(singular) then(
						out			=	#(l, k);
						searching	=	false;
					)
					else append out #(l, k);
				)
			)
		)
		
		--	If we still didn't find any matches for a collective search, revert to an undefined result.
		if(out.count < 1) then out = undefined;
	)
	out;
)



--=====================================================================================================
/*		SPLINE CONVERTER INTERFACE 	*/
--=====================================================================================================	
	global SplineConverter;
	struct SplineConverter(
		
		--	Returns an Array composed of Point2 values composed of each selected knot's spline and vertex indices.
		--	[1]	=	Spline Index
		--	[2]	=	Vertex Index
		fn getSelectedKnots obj = (
			local sel		=	#();
			local knots, p;
			
			for l = 1 to numSplines obj do(
				knots	=	getKnotSelection obj l;
				for k = 1 to knots.count do(
					p	=	[l, knots[k]];
					append sel p;
				)
			)
			
			sel;
		),
		
		--	Returns an array of Point2 values composed of each selected segment and its parent spline's index
		fn getSelectedSegments obj = (
			local sel		=	#();
			local segs, p;
			
			for l = 1 to numSplines obj do(
				segs	=	getSegSelection obj l;
				for k = 1 to segs.count do(
					p	=	[l, segs[k]];
					append sel p;
				)
			)
			
			sel;
		),

		
		-- Extracts a list of integers from a multidimensional array.
		fn extract list index = (
			local out	=	#();
			for i = 1 to list.count do
				if((list[i][1] as integer) == index) then
					append out (list[i][2] as integer);
			out;
		),
		
		-- Similar to the extract method, extractSplines retrieves a list of the affected splines only
		fn extractSplines list = (
			local out	=	#();
			for i = 1 to list.count do
				appendIfUnique out (list[i][1] as integer);
			out;
		),

		-- Increases each numerical value found in an array by the designated amount.
		fn adjustArray list amount = (
			for i = 1 to list.count do
				if(isKindOf list[i] Number) then
					list[i] += amount;
			list;
		),

		
		fn segmentsByKnots obj selected keepOld:false = (
			local knots, segs;
			local changed = false;
			
			if(not keepOld) then
				dropSegSelection obj;
			
			for l = 1 to numSplines obj do(		
				segs	=	#();
				closed	=	isClosed obj l;
				knots	=	extract selected l;
				
				num_knots	=	numKnots obj l;
				num_seg		=	numSegments obj l;
				
				for k = 1 to knots.count do(
					val	=	knots[k];
					
					--	Spline's closed; insert last segment if first knot was included
					if(closed) then(
						if(val == 1) then			appendIfUnique segs num_seg;
						if(val >= num_knots) then	appendIfUnique segs 1;
					)
					
					--	Neighbouring Inclusion
					if(val > 1) then			appendIfUnique segs (val - 1);
					
					--	 Normal Inclusion
					if(val <= num_seg) then		appendIfUnique segs val;
				)
				
				if(segs.count > 0) then(
					changed	=	true;
					setSegSelection obj l segs keep:true;
				)
			)
			
			if(changed) then(
				updateShape obj;
				subobjectlevel = 2;
			)
		),
		
		
		fn segmentsBySplines obj selected keepOld:false = (
			local segs;
			local changed = false;
			
			if(not keepOld) then
				dropSegSelection obj;
			
			for l in selected do(
				segs	=	#();
				for s = 1 to numSegments obj l do append segs s;
				setSegSelection obj l segs
				if(segs.count > 0) then
					changed	=	true;
			)
			if(changed) then(
				updateShape obj;
				subobjectlevel = 2;
			)
		),
		
		
		fn knotsBySegments obj selected keepOld:false = (
			local segs, closed;
			local changed = false;
			
			if(not keepOld) then
				dropKnotSelection obj
			
			for l = 1 to numSplines obj do(
				knots		=	#();
				segs		=	extract selected l;
				
				closed		=	isClosed obj l;
				num_knots	=	numKnots obj l;
				
				for s = 1 to segs.count do(
					if(closed) then(
						appendIfUnique knots segs[s];
						if(segs[s] >= num_knots)
							then	appendIfUnique knots 1;
							else	appendIfUnique knots (segs[s]+1)
					)
					else(
						appendIfUnique knots segs[s];
						appendIfUnique knots (segs[s]+1);
					)
				)
				if(segs.count > 0) then(
					changed	=	true;
					setKnotSelection obj l knots keep:true
				)
			)
			
			if(changed) then(
				updateShape obj
				subobjectlevel = 1;
			)
		),
		
		
		fn knotsBySplines obj selected keepOld:false = (
			local splines;
			local changed = false;
			
			if(not keepOld) then
				dropKnotSelection obj;
			
			for l in selected do(
				splines	=	#();
				for k = 1 to numKnots obj l do append splines k;
				setKnotSelection obj l splines
				if(splines.count > 0) then
					changed	=	true;
			)
			if(changed) then(
				updateShape obj;
				subobjectlevel = 1;
			)
		),
		
		
		fn splinesByKnots obj selected keepOld:false = (
			local splines	=	extractSplines selected;
			setSplineSelection obj splines keepOld:keepOld;
			if(splines.count > 0) then(
				updateShape obj;
				subobjectlevel = 3;
			)
		),
		
		fn splinesBySegments obj selected keepOld:false = (
			splinesByKnots obj selected keepOld:keepOld
		)
		
	)
	global splineConv; splineConv = splineConverter();
--=====================================================================================================