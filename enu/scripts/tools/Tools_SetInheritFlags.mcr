MacroScript SetInheritFlags
	category:	"Tools"
	internalCategory: "Utilities"
	buttonText:	"Set Inheritance Flags"
	toolTip:	"Set Inheritance Flags"
(

	-- Declare Global Variables
	global	setInheritance;
	global	holdPosition	= on;
	global	updateFromSelection;
	
	-- Remove previous rollout if it was left open
	try		(	destroyDialog setInheritance	)
	catch	(	/* Swallow The Error */			)


	/*===========================================================================
		FUNCTIONS
	============================================================================= */
		
		function setHoldPos value = (
			holdPosition	= value;
		)
		
		function changeFlag nodes id value = (
			local flags;
			local i;
			
			for i in nodes do(
				flags		= getInheritanceFlags i;
				flags[id]	= value;
				setInheritanceFlags i flags keepPos:holdPosition;
			)
		)


		function updateFromSelection = (
			/*
			Currently Not Used
			local move_X;
			local move_Y;
			local move_Z;
			local rotate_X;
			local rotate_Y;
			local rotate_Z;
			local scale_X;
			local scale_Y;
			local scale_Z;
			local obj;
			
			for obj in selection do(
				--if(move_X == undefined) then move_X = 
			)
			*/
		)

		function addListeners		= callbacks.addScript #selectionSetChanged "updateFromSelection()" id:#sif
		function clearListeners		= callbacks.removeScripts #selectionSetChanged id:#sif;


	/*===========================================================================
		INTERFACE DEFINITION
	============================================================================= */
	rollout setInheritance "Set Inheritance Flags"	width: 308	height: 209
	(

			global keepPos;
			
			groupBox	setFlags	"Inherit:"	pos:[19, 16]	width: 243	height: 127
			label		lblX		"X"			pos:[124, 31]	width: 15	height: 19
			label		lblY		"Y"			pos:[160, 31]	width: 15	height: 19
			label		lblZ		"Z"			pos:[200, 31]	width: 15	height: 19
				
				-- Move:
				label		lblMove	"Move:"			pos:[30, 56]	width: 61	height: 16
				checkbox	moveX					pos:[122, 50]	width: 19	height: 28	checked: true
				checkbox	moveY					pos:[158, 50]	width: 19	height: 28	checked: true
				checkbox	moveZ					pos:[198, 50]	width: 19	height: 28	checked: true
				
				-- Rotate:
				label		lblRotate	"Rotate:"	pos:[30, 83]	width: 59	height: 16
				checkbox	rotX		""			pos:[122, 77]	width: 19	height: 28	checked: true
				checkbox	rotY		""			pos:[158, 77]	width: 19	height: 28	checked: true
				checkbox	rotZ		""			pos:[198, 77]	width: 19	height: 28	checked: true
				
				-- Scale:
				label		lblScale	"Scale:"	pos:[29, 110]	width: 56	height: 16
				checkbox	scaleX		""			pos:[122, 104]	width: 19	height: 28	enabled: true	checked: true
				checkbox	scaleY		""			pos:[158, 104]	width: 19	height: 28	checked: true
				checkbox	scaleZ		""			pos:[198, 104]	width: 19	height: 28	checked: true
				
			-- Keep Position:
			checkbox	keepPos	"Keep Position"		pos:[51, 151]	width: 193	height: 24	enabled: true	checked: true
		
		
		/*===========================================================================
			EVENT HANDLERS	
		============================================================================= */
			on setInheritance	okToClose	do		clearListeners();
			on moveX	changed newState	do		changeFlag selection 1 newState;
			on moveY	changed newState	do		changeFlag selection 2 newState;
			on moveZ	changed newState	do		changeFlag selection 3 newState;
	
			on rotX		changed newState	do		changeFlag selection 4 newState;
			on rotY		changed newState	do		changeFlag selection 5 newState;
			on rotZ		changed newState	do		changeFlag selection 6 newState;
			
			on scaleX	changed newState	do		changeFlag selection 7 newState;
			on scaleY	changed newState	do		changeFlag selection 8 newState;
			on scaleZ	changed newState	do		changeFlag selection 9 newState;
			
			on keepPos	changed newState	do		setHoldPos newState;
	)

	function init = (
		createDialog setInheritance;
		clearListeners();
		addListeners();		
	)
	
	try		(	init();								)
	catch	(	/* Suppress Any Error Messages */	)
	
)