MacroScript Z
	category:	"Overrides"
	buttonText:	"Zoom Extents Selected"
	tooltip:	"Zoom Extents Selected"
	Icon:		#("ViewportNavigationControls", 7)
(
	on Execute do with undo off(
		global isEditingUVs;
		
		if(isEditingUVs()) then
			(Filters.GetModOrObj()).fitSelected();
		
		else with redraw off(
			local store	=	showEndResult;

			--	Store and disable "Show Trajectory" states
			local t; local tl	=	#{};
			local count	=	selection.count;
			for i = 1 to count do(
				t	=	selection[i].showTrajectory;
				if(t) then(
					tl[i] =	on;
					selection[i].showTrajectory	=	false;
				)
			)
			
			if(store == true) then
				showEndResult	=	false;

			actionMan.executeAction 0 "310"  -- Tools: Zoom Extents Selected

			--	Restore "Show Trajectory" states.
			for i = 1 to count do if(tl[i] == on) then
				selection[i].showTrajectory	=	true;

			showEndResult	=	store;
		)
		
	)
)