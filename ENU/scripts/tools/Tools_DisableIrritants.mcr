macroScript DisableIrritants
	category: "Tools"
	toolTip: "Disable All Annoying Fucking Dialogues"
	buttonText: "Disable Superfluous Settings"
	Icon:#("CustomIcons", 11)
(
	-- Collective shortcut script for disabling options I get too sick of resetting all the frigging time.
	on Execute do(
		
		local major	=	keyboard.controlPressed;
		
		-- Hide the cage that's shown when a subdivided EPoly is viewed at Subobject level.
		if(classOf $ == Editable_Poly) then	$.showCage = off
		
		-- If executing command via CTRL+U, set background colour to commonly used grey instead.
		if(major) then backgroundColor = color 220 220 220;
		
		-- Disable that sodding message window.
		global vrayPref; vrayPref();

		-- Apropos of irritating feedback windows, disable those sodding Raytrace Messages too.
		RaytraceGlobalSettings showmessages:false showProgressDlg:false


	)
)