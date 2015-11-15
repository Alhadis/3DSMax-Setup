MacroScript AltT
	category: "Overrides"
	buttonText: "Trim"
	tooltip: "Trim"
	icon:#("Max_Edit_Modifiers",14)
(
	on Execute do(
		
		--	Editable Spline: Trim
		if(Filters.Is_EditSpline()) then(
			if(subobjectlevel == undefined)	then	max modify mode;
			if(subobjectlevel == 0)			then	subobjectlevel = 3;

			else if(subobjectlevel < 3) then(
				macros.run "Tools" "ConvertToSplines"
				subobjectlevel = 3;
			)
			local op	=	if(keyboard.shiftPressed) then splineOps.startExtend else splineOps.startTrim;
			try(ApplyOperation Edit_Spline op) catch();
		)


		--	Editable Mesh: Turn Edge (if in Edge level)
		else if(Filters.Is_EditMeshSpecifyLevel #{3}) then
			try(ApplyOperation Edit_Mesh meshops.startTurn) catch();


		--	Toggle Trajectory Display
		else with undo off (max trajectories);
	)
)