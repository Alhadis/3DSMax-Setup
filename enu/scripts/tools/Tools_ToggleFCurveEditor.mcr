MacroScript ToggleFCurveEditor
	category: "Tools"
	buttonText: "Toggle Track View"
	toolTip: "Curve Editor (Toggle)"
	icon: #("TrackViewTools", 23)
(
	on Execute do(
		local tv	=	trackviews.current;

		--	Open Track View
		if(tv == undefined) then(
			-- macros.run "Track View" "LaunchFCurveEditor";

			if((trackviews.open "Track View - Curve Editor") == true) then
				if(trackviews.current != undefined) do(
					trackviews.current.setname "Track View - Curve Editor"
					trackviews.current.modifySubTree = false
				)
			else print "Error opening new track view.";
		)

		--	Close currently open Track View
		else								trackviews.close (tv.getName());
	)
)