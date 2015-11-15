MacroScript Swap
	category:	"Overrides"
	buttonText:	"Swap Position"
	toolTip:	"Swap Position"
(
	on Execute do(
	
		--	Check if one object's selected
		if(selection.count > 0) then(
			
			--	Let user pick an object
			pushPrompt "Pick an object to swap positions with...";
			local swapWith	=	pickObject forceListenerFocus:false;
			
			--	Assuming it wasn't cancelled, start exchanging positions
			--	*	NOTE: If more than one object's contained in the current selection set, ALL objects
			--		will be set to the designated object's position! As of now, this script is intended
			--		only to be used with solitary objects, though additional behaviour may be added in future.
			--
			--	*	If more than one object is selected, the picked object
			--		is swapped with the position of the first node.
			if(swapWith != undefined) then(
				local here		=	selection[1].pos;
				local there		=	swapWith.pos;
				
				swapWith.pos	=	here;
				
				for i in selection do(
					i.pos = there;
				)
			)
			
			popPrompt();
		)
		
		
	)
)