/**
 *	Utils
 *
 *	General purpose functions
 */

global percent;
function percent amount outOf startAt:0 = (
	local amount	=	amount as Float;
	local outOf		=	outOf as Float;
	local startAt	=	startAt as Float;
	((amount-startAt) / (outOf-startAt)) * 100;
)


global percentOf;
function percentOf percentage outOf startAt:0 = (
	local percentage	=	percentage as Float;
	local outOf			=	outOf as Float;
	local startAt		=	startAt as Float;
	((percentage / 100) * (outOf - startAt));
)


--	Rounds a float to the nearest whole number
global round;
fn round v = (
	if((v as Integer) + 0.5 > v) then floor v else ceil v;
)


--	Converts a number of bytes into an appropriate unit of measurement for human-readable format.
--	*	E.g., passing 1073741824 would return a value of "1 GBs".
global formatBytes;
function formatBytes val length:2 = (
	local unit		=	#("bytes", "KBs", "MBs", "GBs", "TBs", "PBs");
	local amount	=	0;
	local result;
	
	for i = 0 to unit.count while result == undefined do(
		amount	=	val / (pow 1024 i);
		if(amount < 1024) then(
			local dec	=	cutFloat amount length:length;
			result	=	dec + " " + unit[i+1];
		)
	)
	result;
)


--	Returns a string representation of the number in fixed-point notation, trimmed to the maximum allowable length.
global cutFloat;
function cutFloat val length:2 alwaysFloat:false = (
	local result	=	undefined;
	if(isKindOf val Number) then(
		local trim		=	val as String;
		
		--	If we're not forcing a decimal result for 'whole' numbers, clip any trailing ".0"
		if(not alwaysFloat) then
			trim		=	trimRight(trimRight trim "0") ".";
		
		local split		=	filterString trim "." splitEmptyTokens:false;
		local last		=	split[split.count];
		
		--	Check if the trailing string falls outside requested decimal length.
		local length	=	if(length < 0) then 0 else length;
		if(last.count > length) then	result		=	substring last 1 length;
		else							result		=	last;
		
		--	Stitch the remaining results together to form the compiled left-hand side.
		local rest		=	"";
		for i = 1 to (split.count - 1) do
			rest	+=	split[i];
		
		--	Clean any trailing or leading decimals from the returned result
		result	=	trimLeft(trimRight(rest + "." + result) ".") ".";
	)
	result;
)


--	Converts a Hexadecimal value to a Point3 value
global hexToPoint3;
fn hexToPoint3 v = (
	local out;
	local val	=	case classOf v of(
		String:		substituteString (trimLeft v "# ") "0x" ""
		Name:		v as String
	)
	
	--	Allow CSS-style shorthand
	if(val.count == 3) then	val	=	(v[1] + v[1] + v[2] + v[2] + v[3] + v[3]);
	
	if(val.count == 6) then(
		local	r	=	("0x"+(substring val 1 2)) as Float;
		local	g	=	("0x"+(substring val 3 2)) as Float;
		local	b	=	("0x"+(substring val 5 2)) as Float;
		out			=	[r,g,b];
	)
	out;
)


--	Returns a Hexadecimal string concatenated from a Point3 value
global point3ToHex;
fn point3ToHex v = (
	global round;
	local	r	=	substituteString (formattedPrint (round v[1] as Integer) format:"#x") "0x" "";
	local	g	=	substituteString (formattedPrint (round v[2] as Integer) format:"#x") "0x" "";
	local	b	=	substituteString (formattedPrint (round v[3] as Integer) format:"#x") "0x" "";
	r + g + b;
)


--	Converts an sRGB value to a "Pre-Gammafied" linear value
global degamma;
fn degamma r g b amount:2.2 = (

	--	Convert 0-255 range to 0-1
	local red	=	(r as Float) / 255.0;
	local green	=	(g as Float) / 255.0;
	local blue	=	(b as Float) / 255.0;

	--	Linearise Colours
	local lRed		=	pow red amount;
	local lGreen	=	pow green amount;
	local lBlue		=	pow blue amount;

	[round (lRed*255), round (lGreen*255), round (lBlue*255)] as Color;
)


--	Returns a "de-gammafied" colour value from a Hexadecimal value
global degammaHex;
fn degammaHex v amount:2.2 keepHex:true = (
	local out;
	local val	=	hexToPoint3 v;
	
	--	Hex string was found
	if(val != undefined) then
		out	=	degamma val[1] val[2] val[3] amount:amount;

	if(out != undefined) then(
		global rapidColour;
		if(rapidColour != undefined) then
			rapidColour.rcColourPicker.color = out;
		
		--	Define whether to return a modified hex string, or an actual Color value
		if(keepHex)
			then	point3ToHex (out as Point3);
			else	out;
	)
)



--	Returns an integer representing the "hidden" (unseen) axis for isometric viewports.
--	*	Returns #default keyword for non-orthographic viewports or unrecognised values.
global getHiddenAxis;
function getHiddenAxis index:unsupplied default:undefined = (
	case viewport.getType index:index of(
		#view_top:		3
		#view_bottom:	3
		#view_right:	1
		#view_left:		1
		#view_front:	2
		#view_back:		2
		default:		default
	)
)


--	Returns a BitArray depicting the current working axes
global getActiveAxes;
function getActiveAxes = (
	output	=	case toolmode.axisConstraints of(
		#X:			#{1}
		#Y:			#{2}
		#Z:			#{3}
		#XY:		#{1, 2}
		#YZ:		#{2, 3}
		#ZX:		#{3, 1}
		default:	#{}
	)
	return output;
)


--	Returns TRUE if an Unwrap UVW Modifier's Editing window is open.
global isEditingUVs;
fn isEditingUVs = (
	local obj	=	modPanel.getCurrentObject();
	if(isKindOf obj Unwrap_UVW)
		then	(obj.getWindowW() > 0 and obj.getWindowH() > 0) 
		else	false;
)


--	Returns TRUE if array contains only instances of the same node.
global instancedSel;
fn instancedSel val = (
	local first;
	local instances;
	local searching = true;
	for i in selection while searching do(
		if(first == undefined) then(
			first = i;
			instanceMgr.getInstances first &instances;
		)
		else searching	=	((findItem instances i) > 0);
	)
	searching;
)



--	Returns an Array composed of the value's class and superclass,
--	relative to the currently selected modifer in the modifer stack.
global getTrueClass;
function getTrueClass val = (
	
	--	Initialise a Blank variable
	local type;
	local superclass;
	
	--	Drop the "Show End Result" setting to correctly identify the
	--	selection's class type at the current selection index in modifier stack.
	with redraw off for i=1 to 1 do(
		local show	=	showEndResult;
		if(show)	then	showEndResult	=	false;
							type			=	classOf val;
							superclass		=	superClassOf val;
		if(show)	then	showEndResult	=	true;
	)
	
	#(type, superclass);
)



--	Returns TRUE if an object matches an editable form of a GeometryClass.
global isEditModOrObj;
function isEditModOrObj obj type = (obj != undefined and obj != unsupplied) and(
	try(
		local CO_class	=	classOf obj
		case type of(
			Editable_Mesh:	findItem #(Edit_Mesh, Editable_Mesh)		CO_class != 0
			Editable_Poly:	findItem #(Editable_Poly, Edit_Poly)		CO_class != 0
			Editable_Patch:	findItem #(Edit_Patch, Editable_Patch)		CO_class != 0
			Shape:			findItem #(Edit_Spline, Line, SplineShape)	CO_class != 0
			default:		false
		)
	)
	catch(false)
)



--	Returns the index of the object's currently selected modifier
global getModifierIndex;
fn getModifierIndex obj = (
	
	if(selection.count == 1 and selection[1] == obj) then(
		--	Switch to Modify Panel if not open
		if(subobjectlevel == undefined) then max modify mode;

		local modify	=	modPanel.getCurrentObject();

		if(isKindOf modify modifier) or (superclassOf modify == SpacewarpModifier)
			then modPanel.getModifierIndex obj modify;
		else(
			local count	=	obj.modifiers.count;
			if(count > 0) then count+1 else 0;
		)
	)
	
	--	Targeting an object that's not selected; fall back on top-most modifier
	else (if(obj.modifiers.count > 0) then 1 else 0);
)



--	Deletes all modifiers from the object's stack up to the specified index
--	*	@index: The index of the first modifier to preserve.
global pruneModifiers;
function pruneModifiers obj index = (
	if(obj != undefined) then
		if(obj.modifiers.count > 0) then(
			local prune	=	#();
			if(index < 1 or index > obj.modifiers.count) then
				index = obj.modifiers.count+1;

			for s = 1 to index - 1 do	append prune obj.modifiers[s];
			for s in prune do			deleteModifier obj s;
		)
)



--	Returns a Point3 holding the width, length and height of a node's bounding box.
global getNodeBounds;
function getNodeBounds obj = (
	local bb	=	nodeLocalBoundingBox obj;
	local d		=	bb[1] - bb[2];
	[abs d[1], abs d[2], abs d[3]];
)

--	Shortcuts for the above function
global getNodeLength, getNodeWidth, getNodeHeight;
function getNodeLength obj = 	(	local bb	=	nodeLocalBoundingBox obj;	abs (bb[1][1] - bb[2][1]);	)
function getNodeWidth obj	=	(	local bb	=	nodeLocalBoundingBox obj;	abs (bb[1][2] - bb[2][2]);	)
function getNodeHeight obj	=	(	local bb	=	nodeLocalBoundingBox obj;	abs (bb[1][3] - bb[2][3]);	)