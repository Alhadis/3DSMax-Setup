--=====================================================================================================
/*		LEGACY VIEWPORT SWITCHER INTERFACE	*/
--=====================================================================================================
global LegacyViewports;
struct LegacyViewports(
	zoomExtents	=	true,
	throttle	=	true,
	allowStore	=	true,

	--	Internals
	numViews	=	if(viewport.numViews) > 1 then viewport.numViews else 4,


	--	Returns the opposite view type to the given value. E.g., Front/Back, Left/Right, etc
	fn opposite type = (
		case type of(
			#view_top:		#view_bottom
			#view_bottom:	#view_top
			#view_right:	#view_left
			#view_left:		#view_right
			#view_front:	#view_back
			#view_back:		#view_front
			default:		undefined
		)
	),


	--	Returns the Index of the queried viewport type.
	fn get type throttle:false = (
		local result;
		
		--	Throttled check
		if(throttle) then(
			local t;
			for i = 1 to numViews while result == undefined do(
				t	=	viewport.getType index:i
				if(t == type or t == opposite type) then
					result	=	i;
			)
		)
		
		--	Regular check
		else for i = 1 to numViews while result == undefined do
			if((viewport.getType index:i) == type) then
				result	=	i;
		result;
	),
	
	
	fn switch toView = (
		if(toView != viewport.getType()) then(
			local views	=	viewport.numViews;
			if(views > 1) then
				numViews	=	views;

			local index	=	get toView throttle:throttle;

			if(allowStore) then	actionMan.executeAction 0 "40227"  -- Views: Save Active View

			--	No viewport of that type exists; set existing viewport instead.
			if(index == undefined) then
				viewport.setType toView;

			--	Otherwise, jump to the other viewport.
			else with redraw off(
				if(viewport.numViews > 1) then(
					viewport.activeViewport	=	index;
					if(throttle)	then	viewport.setType toView;
					if(allowStore)	then	actionMan.executeAction 0 "40228"
				)

				else(
					max tool maximize;

					--	Allow one attempt at recovering from a sudden change in viewport layout.
					try		(	viewport.activeViewport	=	get toView throttle:throttle;		)
					catch	(
						numViews	=	viewport.numViews;
						try		(	viewport.activeViewport	=	get toView throttle:throttle;	)
						catch	(	print "Error caught"; )
					)

					if(throttle) then viewport.setType toView;
					if(allowStore) then		actionMan.executeAction 0 "40228"
					else if(zoomExtents == true and selection.count > 0) then
						max tool zoomextents;

					max tool maximize;
				)

			)
		)
	)
)
global lvs; lvs = LegacyViewports();
--=====================================================================================================