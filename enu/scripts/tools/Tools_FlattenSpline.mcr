MacroScript FlattenSpline
	category:"Tools"
	tooltip:"Flatten Spline"
	buttonText:"Flatten Spline"
(
	-- Reach into the global scope
	global flattenSpline;
	global isSpline, getHiddenAxis;
	
	function flattenSpline obj axis:3 ground:unsupplied = (
		if(isSpline obj) then(
			obj.transform	=	obj.transform
			
			-- Allow an axis to be optionally specified using a string
			if(classof axis == String) then(
				axis = case (toLower axis) of(
					"x":		1
					"y":		2
					default:	3
				)
			)
			
			-- Value to set spline's tangents and vertices to
			if(ground == unsupplied or ground == undefined)
				then	flat	=	obj.pos[axis];
				else	flat	=	ground;
			
			-- Loop through each of the shape's splines and knots
			for s = 1 to (numSplines obj) do(
				for k = 1 to (numKnots obj s) do(
					knt			=	getKnotPoint obj s k
					in_vec		=	getInVec obj s k
					out_vec		=	getOutVec obj s k
					knt[axis]	=	in_vec[axis] = out_vec[axis] = flat
					setInVec obj s k in_vec
					setOutVec obj s k out_vec
					setKnotPoint obj s k knt
				)
			)
			updateShape obj
		)
		else(
			clearListener();
			print obj;
		)
	)
	
	
	function flattenSplineDialog = (
		global flattenDialog;
		global fd_init_flatval;

		-- If Rollout was already open, kill it
		try		(	destroyDialog flattenDialog;	)
		catch	(	/* Swallow The Error */			)

		rollout flattenDialog "Flatten Spline"(
			
			group "Axis:"(
				radioButtons flatAxis labels:#("X   ", "Y   ", "Z   ") columns:3;
			)
			group "Flatten To:"(
				radioButtons flatGround labels:#("Object's Position", "Custom Value:") columns:1
				spinner flatValue "Value:" range:[-1000000, 100000, 0];
			)
			button cancel "Cancel" width:70 align:#left across:2 offset:[-5,0]
			button apply "Apply" width:70 align:#right offset:[5,0]
			
			
			/*	METHODS	*/
			
			--	Returns the axis currently selected for flattening
			function getAxis = (
				flattenDialog.flatAxis.state;
			)
			
			--	Returns the coordinate at which to flatten the spline's vertices and tangents to.
			function getGround obj axis = (
				if(flattenDialog.flatGround.state == 2)
					then	flattenDialog.flatValue.value;
					else	obj.pos[axis];
			)
			
			-- Returns TRUE if at least one Editable Spline exists in the current selection set.
			function splinesSelected = (
				local result = false;
				if(selection.count > 0) then(
					for o in selection while not result do
						result = (isSpline o == true)
				)
				result;
			)
			
			
			/*	EVENT HANDLERS	*/
			
			--	Called when rollout's opened.
			--	*	 Set some initial values for the input fields.
			function onOpen = (
				flattenDialog.flatAxis.state	=	getHiddenAxis default:3;
				flattenDialog.flatValue.value	=	\
					if(fd_init_flatval != undefined)			then	fd_init_flatval;
					else if(flattenDialog.splinesSelected())	then	selection[1].pos[flattenDialog.getAxis()];
					else										3;
				
				if(flattenDialog.flatGround.state != 2) then
					flattenDialog.flatValue.enabled = false;
			)
			
			--	Triggered when rollout's closed; stores the last user-entered position value, if any.
			function onClose = (
				global fd_init_flatval;
				if(flattenDialog.splinesSelected() and flattenDialog.flatValue.value != selection[1].pos[flattenDialog.getAxis()]) then
					fd_init_flatval	=	flattenDialog.flatValue.value;
			)
			
			-- Called when the value of flatValue's been changed or updated.
			function onChangeFlatValue val = (
				flattenDialog.flatValue.enabled	=	true;
				if(val != undefined) then
					fd_init_flatval	=	val;
			)
			
			-- Flattens all selected splines using the appropriate values; close dialog on success.
			function onApply = (
				if(flattenDialog.splinesSelected()) then(
					for o in selection do(
						local axis		=	flattenDialog.getAxis();
						local ground	=	flattenDialog.getGround o axis;
						flattenSpline o axis:axis ground:ground;
					)
					destroyDialog flattenDialog;
				)
				else
					messageBox "ERROR: No splines selected!";
			)
			
			--	Event Handlers
			on flattenDialog open do flattenDialog.onOpen();
			on flattenDialog close do flattenDialog.onClose();
			on cancel pressed do destroyDialog(flattenDialog);
			on apply pressed do flattenDialog.onApply();
			
			--	Handlers for flatValue spinner
			on flatValue changed val do	flattenDialog.onChangeFlatValue val;
			on flatValue buttonDown do	flattenDialog.flatGround.state = 2;
			on flatGround changed val do(
				if(val == 2)
					then flattenDialog.onChangeFlatValue undefined;
					else flattenDialog.flatValue.enabled = false;
			)
		)
		createDialog flattenDialog;
	)
	
	
	--	Event Handlers
	on isVisible return 	Filters.Is_EditSpline();
	on execute do			flattenSpline $ axis:(getHiddenAxis default:3);
	on altExecute type do	flattenSplineDialog();
)