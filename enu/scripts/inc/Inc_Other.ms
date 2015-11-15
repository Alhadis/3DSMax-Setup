/**
 *	Other
 *
 *	Precisely what "other" implies; a place for code that doesn't fit anywhere else.
 *	This typically applies to MacroScript rollouts, lengthy ad-hoc functions, and
 *	independent structs too short to warrant their own file.
 *
 *	Helpful, reuseable functions should really go to "Inc_Utils.ms"
*/


--	Rollout for displaying and copying distance measurements
global measureResults;
rollout measureResults "Measurement Results" width:373 height:320(
	local imgs	=	#("bip_mflscript_i.bmp", undefined, 22, 15, 15, 16, 16, true);

	--	Transfers the designated text to the system clipboard and supplies feedback
	function copy val = (
		local msg	=	case setClipboardText val of(
			true:	"DONE: Successfully transferred \""+val+"\" to system clipboard."
			(-1):	"ERROR: Memory could not be allocated."
			(-2):	"ERROR: Problem accessing clipboard."
			(-3):	"ERROR: Problem clearing clipboard's contents."
			(-4):	"ERROR: Clipboard could not be set."
		);
		displayTempPrompt msg 3000;
		destroyDialog measureResults;
	)

	--	Distance Field
	label distLbl "Distance:" pos:[48,33] width:48 height:18
	editText distVal "" pos:[97,28] width:179 height:26 readOnly:true text:"";
	button distCopy "" pos:[283,26] width:30 height:30 images:imgs
	
	--	Begin Axis Group
	groupBox axisGrp "By Axis" pos:[18,72] width:331 height:187
	
	--	Delta X
	label delXLbl "Delta X:" pos:[48,110] width:48 height:14
	editText delXVal "" pos:[97,104] width:179 height:26 readOnly:true text:"";
	button delXCopy "" pos:[283,102] width:30 height:30 images:imgs
	
	--	Delta Y
	label delYLbl "Delta Y:" pos:[48,149] width:48 height:14
	editText delYVal "" pos:[97,143] width:179 height:26 readOnly:true text:"";
	button delYCopy "" pos:[283,141] width:30 height:30 images:imgs
	
	--	Delta Z
	label delZLbl "Delta Z:" pos:[48,187] width:48 height:14
	editText delZVal "" pos:[97,181] width:179 height:26 readOnly:true text:"";
	button delZCopy "" pos:[283,179] width:30 height:30 images:imgs
	
	--	Point3 Copy Button
	button p3Copy "Copy Point3" pos:[223,222] width:90 height:24
	
	--	Feedback Bar and Close Button
	button closeBtn "Close" pos:[222,271] width:90 height:24
	label statusLbl "" pos:[18,300] width:340 height:14;

	
	on distCopy pressed	do	(	measureResults.copy	measureResults.distVal.text	);
	on delXCopy pressed	do	(	measureResults.copy	measureResults.delXVal.text	);
	on delYCopy pressed	do	(	measureResults.copy	measureResults.delYVal.text	);
	on delZCopy pressed	do	(	measureResults.copy	measureResults.delZVal.text	);
	on closeBtn pressed do	(	destroyDialog measureResults;	)
	on p3Copy pressed	do	(
		measureResults.copy	("[" + measureResults.delXVal.text + ","+measureResults.delYVal.text + ","+measureResults.delZVal.text+"]");
	);
)



--=====================================================================================================
/*		SELECTION STORAGE INTERFACE 	*/
--=====================================================================================================	
global SelStore;
struct SelStore(
	so,
	index,
	selected,
	endResult,
	
	--	Use subject keyword to supply pre-evaluated variables for quicker execution.
	--	*	E.g., use when having already stored a call to Filters.GetModOrObj()
	fn store subject:unsupplied = (
		so			=	subobjectlevel;
		index		=	if(subject != unsupplied) then subject else modPanel.getCurrentObject();
		endResult	=	showEndResult;
		selected	=	selection[1];
	),
	
	fn restore = (
		local pos	=	findItem (getCurrentSelection()) selected;
		if(pos == 0) then
			select selected;
		
		modPanel.setCurrentObject index;
		subobjectlevel	=	so;
		showEndResult	=	endResult;
		ok;
	)
)
--=====================================================================================================



--	Returns the distances between two selected nodes.
--	*	ignoreAxes: If FALSE, distances will only be measured using the active transform axes.
--	*	Function marked as temporary; will be replaced with a more flexible MacroScript in future.
global dist;
function dist ignoreAxes:false = (
	if(selection.count >= 2) then(
		local o1	=	selection[1];
		local o2	=	selection[2];
		if(ignoreAxes) then o1.pos - o2.pos;

		else(
			local a		=	getActiveAxes();
			if(a.numberSet == 1) then(
						if(a[1]) then		o1.pos[1] - o2.pos[1];
				else	if(a[2]) then		o1.pos[2] - o2.pos[2];
				else	if(a[3]) then		o1.pos[3] - o2.pos[3];
			)

			else(
				local p	=	#();
				for i = 1 to a.count while p.count < 2 do
					if(a[i]) then append p (o1.pos[i] - o2.pos[i]);
				[p[1], p[2]];
			)
		)
	)
	else undefined;
)