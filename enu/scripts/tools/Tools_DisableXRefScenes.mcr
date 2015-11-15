MacroScript DisableXRefScenes
	category: "Tools"
	buttonText: "Disable XRef Scenes"
	tooltip: "Disable XRef Scenes"
	icon: #("Containers", 12)
(
	/* Global Variables */
	global _getXRefFileCount	=	xrefs.getXRefFileCount;
	global _getXRefFile			=	xrefs.getXRefFile;


	on isChecked do(
		global _getXRefFileCount, _getXRefFile;
		try((_getXRefFileCount() > 0 and (_getXRefFile 1).disabled == true))
		catch(false);
	)
	
	on isEnabled do(
		global _getXRefFileCount; _getXRefFileCount() > 0
	)
	
	/* Toggle the Enabled state of all XRefScenes */
	on Execute do with undo off(
		global _getXRefFileCount, _getXRefFile;
		
		local disabled	=	not ((_getXRefFile 1).disabled);
		local count		=	_getXRefFileCount();
		
		for i = 1 to count do
			(_getXRefFile i).disabled	=	disabled;
	)
)