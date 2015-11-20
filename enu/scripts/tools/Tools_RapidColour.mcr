MacroScript RapidColour
	category:	"Tools"
	internalCategory: "Utilities"
	buttonText:	"Rapid Colour"
	toolTip:	"Rapid Colour"
(

	-- Declare Global Variables
	global rapidColour;
	global rcColourPicker;
	global defaultColour	= [128,128,128] as color;
	
	-- Globalise Functions
	global updateFromSelection;
	global getSelectionColours;
	global averageColours;
	global selectByColour;
	
	
	-- If Rollout was already open, kill it
	try		(	destroyDialog rapidColour;	)
	catch	(	/* Swallow The Error */		)
	
	
	/*===========================================================================
		FUNCTIONS
	============================================================================= */
		
		-- Updates the rollout's colour picker with the value of a newly selected object
		function updateFromSelection = (
			if(selection.count > 0) then(
				colours		= getSelectionColours(selection)
				nextColour	= averageColours(colours)
				rapidColour.rcColourPicker.color = nextColour
			)
		)
			-- Returns an Array holding the wirecolour for each node in an array
			function getSelectionColours nodes = (
				colourList = #()
				for obj in nodes do
					colourList = append colourList obj.wirecolor
				return colourList
			)
			
			-- Finds the Average Colour between a range of colour values
			function averageColours colourArray = (
				red		= 0;
				green	= 0;
				blue	= 0;
			
				for colour in colourArray do(
					red		+= colour.red
					green	+= colour.green
					blue	+= colour.blue
				)
				
				div = colourArray.count
				average = [(red / div), (green / div), (blue / div)] as color
			
				return average;
			)
		
		mapped function doColoursMatch colour1 colour2 strict:false= (
			local evalType	= if(strict) then Integer else Float;
			
			local red1		= colour1.r as evalType
			local green1	= colour1.g as evalType
			local blue1		= colour1.b as evalType
			
			local red2		= colour2.r as evalType
			local green2	= colour2.g as evalType
			local blue2		= colour2.b as evalType
			
			return(
						red1	== red2		and
						green1	== green2	and
						blue1	== blue2
					)
		)
		
		function selectByColour value = (
			nodes	= #()
			for obj in $* do(
				if(doColoursMatch obj.wirecolor value strict:true)
					then nodes = append nodes obj
			)
			select nodes
		)
		
		
		-- Remove/Add Callback Scripts
		function clearListeners	=	callbacks.removeScripts id:#rcSel
		function addListeners	=	callbacks.addScript #selectionSetChanged "updateFromSelection()" id:#rcSel



	/*===========================================================================
		INTERFACE DEFINITION
	============================================================================= */
	
		rollout rapidColour "Rapid Colour Setter"(		
	
			colorPicker	rcColourPicker		"Colour:"			color:defaultColour modal:false
			button		rc_selColour		"Select By Colour"
			
			on rcColourPicker	changed newColour	do	selection.wirecolor = newColour
			on rapidColour		okToClose			do	clearListeners();
			on rc_selColour		pressed				do	selectByColour(rcColourPicker.color);
		)
	
		function init = (
			if(selection.count > 0) do(
				colourList		= getSelectionColours(selection);
				defaultColour	= averageColours(colourList);
			)
			
			createDialog rapidColour pos:[659, 927]
			clearListeners();
			addListeners();
		)
	
		try		(	init();							)
		catch	(	/* Suppress Error Messages	*/	)
	
)