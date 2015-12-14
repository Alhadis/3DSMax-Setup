macroScript Forksweeper
	category:			"Tools"
	internalCategory:	"Utilities"
	buttonText:			"ForkSweeper v1.1"
	toolTip:			"ForkSweeper.ms: Removes \"._dot\" files and similar resources used by Mac OS/X"
(
	--	Declare Global Variables
	global fs;
	global sweepPath;
	global clearCount;
	global bytesCleared;
	
	-- Remove previous rollout if it was left open
	try		(	destroyDialog fs;			)
	catch	(	/* Swallow The Error */		)

	
	/*===========================================================================
		FUNCTIONS
	============================================================================= */
		
		--	Major Name Literals
		#removeDotfiles;
		#removeDSStore;
		#removeIcons;
		#keepSystem;
		#useSubdirectory;
		#skipAppFolders;
		#markIconSystem;
		
		function getOption option = (
			return case option of(
				#removeDotfiles:	fs.remDotFiles.checked
				#removeDSStore:		fs.remDSStore.checked
				#removeIcons:		fs.remIcons.checked
				#keepSystem:		fs.optKeepSys.checked
				#useSubdirectory:	fs.optSubDirs.checked
				#markIconSystem:	fs.optMarkSys.checked
				#skipAppFolders:	fs.optSkipApp.checked
				default:			false;
			)
		)

		
		--	Returns TRUE if a string finishes with a trailing slash.
		function getTrailSlash value delimiter:"\\" = (
			local length	=	value.count;
			if(length < 1)	then return false;
			local sub		=	substring value length -1;
			return(sub == delimiter);
		)
		
		--	Checks to see if a pathname ends in a correct delimiter
		function addTrailSlash value delimiter:"\\"= (
			return(value + (if(getTrailSlash value delimiter:delimiter) then "" else delimiter));
		)
		
		function removeTrailSlash value delimiter:"\\" = (
			local output	=	value;
			if(getTrailSlash value delimiter:delimiter) then
				output	=	substring value 1 ((value.count)-1);
			return output;
		)
		
		
		--	Returns TRUE if string's prefixed by "._"
		function getDotPrefix value = (
			local count		=	value.count;
			if(count < 3) then return false;
			local substr	=	substring value 1 2;
			return(substr == "._");
		)
		
		--	Returns TRUE if folder's name qualifies as a Macintosh Application folder
		function isAppFolder value = (
			if(value == "" or value == undefined)
				then return false;
			
			local value		=	addTrailSlash(value);
			local match		=	".app\\";
			local length	=	value.count;
			local offset	=	4;

			if(length < 5)	then return false;
			
			local substr	=	substring value (length-offset) (offset+2);
			local result	=	(substr == match);
			return result;
		)
		
		
		--	Returns TRUE if value is a valid directory.
		function isDir value = (
			if(value == "" or value == undefined)
				then return false;
			else return (getFileAttribute value #directory);
		)
		
		--	Checks if folder's marked as an .app folder and the #skipAppFolders flag is on.
		function canSweepFolder value = (
			if((value == "") or (value == undefined)) then return false;
			if(not(isDir value)) then return false;
			if(getOption #skipAppFolders) then	return not(isAppFolder value);
			else								return true;
		)
		
		--	Checks that any file forks are checked for removal before beginning search
		--	*	Returns TRUE if at least one target's been listed as prey.
		function anyOptionsSelected = (
			return((getOption #removeDotfiles) or (getOption #removeDSStore) or (getOption #removeIcons));
		)
		
		--	Returns TRUE if global sweepPath variable's been set
		function dirSet = (
			if(sweepPath != "" and sweepPath != undefined)	then	return true;
			else													return false;
		)
		
		function getFilePathName value = (
			return(getFilenameFile(removeTrailSlash(value)));
		)
		
		
		--	Now, here's where things get confusing; because of irregular Private Use characters in
		--	Mac OS/X's custom icon resources, we can't access String literals directly.
		function isIcon file = (
			return((file == "._Icon?") or (file == "Icon?"));
		)
		
		--	Returns TRUE if filename's an archtypical, run-of-the-mill file fork for common files.
		function isDotFile file = (
			if		(isIcon file)	then	return	false;
			else							return	(getDotPrefix file);
		)
		

	
		
	/*===========================================================================
		PRIMARY METHODS
	============================================================================= */
		
		--	*	Collects files from folder and all subsequent directories and returns an array of complete filenames.
		function searchFolder root = (
			local result	= #();
			
			if(root != "" and root != undefined) then(
				
				--	Search folder's contents and collect the results.
				if(canSweepFolder root) then(
					local root	=	addTrailSlash root;
					local files	=	getFiles(root+"*.*");
					local dirs	=	getDirectories(root+"/*");
					
					local filename;
					for f in files do	result =	append result f;
						
					if(getOption #useSubdirectory) then
						for f in dirs do	join result (searchFolder f);
				)
			)
			return result;
		)
		
		function tryDelete file = (
			try(
				local shouldDelete	= true;
				if(getFileAttribute file #system) then(
					shouldDelete	= not(getOption #keepSystem);
				)
				if(shouldDelete) then(
					bytesCleared += (getFileSize file);
					print ((file as String) + " was toasted");
					deleteFile file;
					clearCount += 1;
				)
			)
			catch()
		)
		
		--	Attempts the set the system attribute of a filename.
		--	*	Returns TRUE if the attribute was successfully set.
		function setSystem filename value = (
			local result	= false;
			try(
				setFileAttribute filename #system value;
				result	= true;
			)
			catch( /* bluuuh... */);
			return result;
		)
		
		--	Reports the number of file forks cleared from the last sweep.
		function showSummary = (
			global formatBytes;
			local size		=	"(" + (formatBytes bytesCleared) + ")";
			local feedback	=	(clearCount as String) + " files " + size + " cleared.";
			print(feedback);
			displayTempPrompt feedback 3500;
			clearCount	= 0;
		)
		
		--	*	Main Filtering mechanism. This is where the slaughter takes place.
		--		@Files: Array of filenames to check before killing.
		function parseFiles files = (
			if(classof files == Array) then(
				local filename;
				-- Loop through the files...
				for i in files do(
					filename	=	filenameFromPath i;
					
					if(isDotFile(filename)) then(
						if(getOption #removeDotfiles) then
							tryDelete i;
					)
					else if(filename == ".DS_Store") then(
						if(getOption #removeDSStore) then
							tryDelete i;
					)
					/*
					else if(isIcon(filename)) then(
						if(getOption #removeIcons) then
							tryDelete i;
						else if(getOption #markIconSystem) then
							setSystem i true;
					)*/
				)
			)
			showSummary();
		)
		

		
		
	/*===========================================================================
		EVENT HANDLERS
	============================================================================= */
		function showPickedDir value = (
			fs.pickDir.text	=	(getFilePathName(value))+"/";
		)
		
		--	When Rollout's opened, check if the sweeping directory's been defined from a previously opened rollout.
		function updatePath = (
			if(dirSet()) then
				showPickedDir sweepPath;
		)
		
		--	Called when user presses the "Choose Directory" button.
		function changeDirectory = (
			local initpath		=	if(sweepPath == undefined) then unsupplied else sweepPath;
			local pathTo		=	getSavePath caption:"Choose Directory" initialDir:initpath;
			if(pathTo != undefined) then(
				sweepPath		=	pathTo;
				showPickedDir sweepPath;
			)
			else(
				sweepPath		=	undefined;
				fs.pickDir.text	=	"Choose Directory...";
			)
		)
		
		--	Initiates the Forksweeping sequence
		function startSweep = (
			clearCount		= 0;
			bytesCleared	= 0;
			
			--	Check that anything's even been marked for removal
			if(not anyOptionsSelected())			then	messageBox "Nothing marked for removal.";
			else if(not dirSet())					then	messageBox "No Directory selected for sweeping.";
			else if(not canSweepFolder(sweepPath))	then	messageBox "ERROR: Can't search .app folder with \"Skip .App Folders\" set.";
			else if(not isDir sweepPath)			then	messageBox "ERROR: Directory does not exist";
				
			--	Otherwise: it's killin' time.
			else(
				local files	=	searchFolder(sweepPath);
				parseFiles(files);
			)
		)
		
		--	Called when the value of $remIcons is changed.
		function changeRemoveIcons value = (
			fs.optMarkSys.enabled	=	not value;
		)
		
		
		
	/*===========================================================================
		INTERFACE DEFINITION
	============================================================================= */
	rollout fs	"ForkSweeper v1.0"	width:190	height:338(
		
		--	Action Buttons
		button		pickDir			"Choose Directory..."	pos:[21,23]		width:150	height:28	toolTip: "Pick Directory"
		button		btnSweep		"Sweep"					pos:[19,295]	width:142	height:29	toolTip: "Perform Sweep Action: Note this action cannot be undone!"
		
		--	Files to Remove
		groupBox	grpRemove		"Remove"				pos:[11,70]		width:162	height:142
		checkbox	remDSStore		".DS_Store"				pos:[19,112]	width:122	height:24	checked:true
		checkbox	remDotFiles		"._files"				pos:[19,89]		width:122	height:24	checked:true
		--checkbox	remIcons		".Icon"					pos:[19,135]	width:122	height:24	checked:false
		
		--	Options
		checkbox	optKeepSys		"Keep System Files"		pos:[19,225]	width:150	height:19	enabled:true	checked:true
		checkbox	optSubDirs		"Sub-Directories"		pos:[19,246]	width:150	height:19	enabled:true	checked:true
		checkbox	optSkipApp		"Skip .app folders"		pos:[19,267]	width:150	height:19	enabled:true	checked:true
		--													posY:	267 with above checkbox
		
		
		
		/*===========================================================================
			EVENT HANDLERS
		============================================================================= */
		on 	fs			open			do	updatePath();
		on	pickDir		pressed			do	changeDirectory();
		on	btnSweep	pressed			do	startSweep();
		on	remIcons	changed	value	do	changeRemoveIcons value;
	)


	function init = (
		clearListener();
		createDialog fs;
	)
	
	try		(	init();								)
	catch	(	/* Suppress Any Error Messages */	)
) 