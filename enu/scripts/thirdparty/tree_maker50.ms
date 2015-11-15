-- Tree Maker Version 5.
--
-- This scripts creates the branches and leaves for trees. It was
-- written for MAX 4.x but most of it works under MAX 3.x.
--
-- Modified on 
--
--
-- By: Shawn Lewis
-- Date: 27 Mar 2001
--
-- 		inspired, in part, by routines written by
--
--   		M. Wengenroth, ilumi GbR, Interactive 
--      	J. Curtis                         
--                                        
-------------------------------------------------------------------
--
-- Make sure we have a large enough heap
--
if ( heapSize < 7500000 ) then heapSize = 7500000

g_sDataFileTitle	= "Tree Maker Data File"
g_sDataFileVersion 	= "5."

if( ( maxVersion() )[ 1 ] < 4000 ) then	
	g_bMax4 = false
else
	g_bMax4 = true

g_RandomSeed      =    12345		-- Random number seed
g_RadiusChange    =		 1.2		-- number of times bigger the large end of a branch is than the small end
g_Thickness       =       15		-- Branchthickness in aspect to Length
g_TrunkLength     =      100		-- Length of Trunk
g_BranchMinLen    =       20		-- Mimimum Branchlength in %
g_BranchDistance  =		  4.		-- Multiplier to "spread out" or length the connection area between a branch and its parent
g_CatchValue	  =        2		-- The branchlength is decreased with this value at each iteration
									-- so the script won't lock up or suck up all the memory.
g_StartPosition   =  [0,0,0]		-- g_StartPosition
g_BranchAngle  	  =       40		-- half angle between two Branches
g_Randomness      =       15		-- g_Randomness factor in %
g_BranchScaleA    =       .9		-- Factor for the next A - Branch generation
g_BranchScaleB 	  =       .7		-- Factor for the next B - Branch generation
g_bTreeRoots	  =	  	true		-- The trunk has roots
g_LeafSize		  =        6		-- Size of the Leaves
g_LeafSizeRandom  =       50        -- percent variation in leaf size
g_LeafViewPercent = 	 100		-- The percent of leaves to show in view
g_LeafNum  		  =		 500  		-- Number of leaves per branch
g_LeafNumRandom   =       50        -- percent variation in number of leaves
g_LeafSpread	  =       35		-- radius for leaf creation
g_LeafType		  =        5        -- type of leaf
g_TreeName 		  =   "Tree"		-- base name for tree
g_LeafExtName     = "_leaf_"		-- extension name for leaf
g_BranchExtName   ="_brnch_"  		-- extension name for a branch
g_ConnectExtName  ="_cnnct_" 		-- extension name for a branch to branch connection
g_BranchLenSegs   = 	   1		-- the number of segments the branch has along its length
g_AngleIndex	  =		   1		-- the index into g_AngleValues

g_AngleValues 	  = #( 9.0, 18.0, 30.0, 45.0, 90.0 ) -- angle between sides on a branch 
													-- (360 divided by ( 4 * [g_AngleIndex] ) MUST BE AN INTEGER)
--
-- The following Variables are present so the interpreter will 
-- recognize them when they're referenced later
--
g_TM_roGreenThumbCentral
g_TM_roBranchOptions
g_TM_roConnectionTools
g_TM_roLeafOptions
g_TM_roLeafOptionsVIZ
g_TM_roAbout
g_TM_roTreeIO
g_TM_dlgProgress	= undefined
z					= 0
g_LeavesNumber 		= 0
g_BranchNumber		= 0
g_Limits			= 0
g_StartLength     	= 0
g_StartSize    		= 0


-- --------------------------------------------------------------------
-- fn LocalIsValidNode nd =
--
-- Under MAX 4, this is just a wrapper for {IsValidNode}. Under MAX 3,
-- the node is checked to see if it exists and hasn't been deleted
-- --------------------------------------------------------------------
fn LocalIsValidNode nd =
(
	--
	-- {IsValidNode} doens't exist under MAX 3, so
	-- we perform our own
	--
	if( IsValidNode != undefined ) then
	(
		return ( isValidNode nd )
	)
	else
	(
		try
		(
			if( nd == undefined ) then 
				return false

			if( isDeleted nd ) then 
				return false

			return true
		)
		catch
		(
			return false
		)
	)
)

-- ------------------------------------------------------------------------
-- fn LocalIsVIZ = 
--
-- Returns true if the script is running under VIZ
-- ------------------------------------------------------------------------
fn LocalIsVIZ = 
(
	retValue = false

	try
	(
		if( maxOps.productAppID == #Viz ) then
			retValue = true

	)
	catch
	()

	retValue
)

--
-- If the user accidentally closes the floater, they sure don't 
-- want these values to be forgotten. So, we only want to
-- initialize them once.
--
global g_TM_dlgMain
global g_TM_dlgHelp
global g_TreeMesh
global g_LeafMesh
global g_Branches
global g_Connections
global g_LeafNodes
if( not ( LocalIsValidNode g_TreeMesh ) ) then g_TreeMesh = undefined
if( not ( LocalIsValidNode g_LeafMesh ) ) then g_LeafMesh = undefined
if( g_Branches == undefined ) then g_Branches = #()
if( g_Connections == undefined ) then g_Connections = #()
if( g_LeafNodes == undefined ) then g_LeafNodes = #()

struct strctBranchReturn ( branchMesh, newPos )
struct strctConnections ( trunk, branch1, branch2, Connect, angleInc )
struct strctLeafNode ( branch, leafMesh )

-- ------------------------------------------------------------------------
-- Rollout g_RollOutDlgTrees "" SilentErrors:true
--
-- The rollout which gives feedback to user (this rollout is declared here
-- so that it has "global" scope and can be referenced from anywhere
-- ------------------------------------------------------------------------
Rollout g_RollOutDlgTrees "" SilentErrors:true
(
	Label Text1 "" Align:#Left OffSet:[0,-5]
	Label Text2 "" Align:#Left OffSet:[0, 5]
)

-- ------------------------------------------------------------------------
-- fn ShowProgressDialog title =
--
-- Shows the progress dialog box. [title] is the title of the progress
-- dialog
-- ------------------------------------------------------------------------
fn ProgressShowDialog title =
(
	g_TM_dlgProgress = NewRolloutFloater Title 300 120
	AddRollout g_RollOutDlgTrees g_TM_dlgProgress
)

-- ------------------------------------------------------------------------
-- fn ProgressSetFirstString userString =
--
-- Sets the first line of text in the progress dialog box to be [string]
-- ------------------------------------------------------------------------
fn ProgressSetFirstString userString =
(
	g_RollOutDlgTrees.Text1.Text = ( userString + "               " )
)

-- ------------------------------------------------------------------------
-- fn ProgressSetSecondString userString =
--
-- Sets the second line of text in the progress dialog box to be [string]
-- ------------------------------------------------------------------------
fn ProgressSetSecondString userString =
(
	g_RollOutDlgTrees.Text2.Text = ( userString + "               " )
)

-- ------------------------------------------------------------------------
-- fn ProgressHideDialog =
--
-- Closes down the progress dialog box
-- ------------------------------------------------------------------------
fn ProgressHideDialog =
(
	try( CloseRolloutFloater g_TM_dlgProgress ) catch()
)

-- ------------------------------------------------------------------------
-- function SettingsSaveDataFile sFileName =
--
-- Saves the current settings to [sFileName]
-- ------------------------------------------------------------------------
fn SettingsSaveDataFile sFileName =
(
	--
	-- Sanity check
	--
	if( sFileName == undefined ) then
		return false

	--
	-- Open the file for writing
	--
	fOutput = openfile sFileName mode:"w"
	if( fOutput == undefined ) then
	(
		MessageBox ( "Unable to open \"" + sFileName + "\" for output." )
		return false
	)

	--
	-- write out the data
	--
	format "%\n"		g_sDataFileTitle 	to:fOutput
	format "%\n" 		g_sDataFileVersion 	to:fOutput

	format "g_RandomSeed = %\n" 		g_RandomSeed 		to:fOutput
	format "g_Thickness = %\n"			g_Thickness 		to:fOutput
	format "g_TrunkLength = %\n"		g_TrunkLength 		to:fOutput
	format "g_BranchMinLen = %\n"		g_BranchMinLen		to:fOutput
	format "g_BranchDistance = %\n"		g_BranchDistance	to:fOutput
	format "g_CatchValue = %\n"			g_CatchValue		to:fOutput
	format "g_StartPosition = %\n"		g_StartPosition		to:fOutput
	format "g_BranchAngle = %\n"		g_BranchAngle		to:fOutput
	format "g_Randomness = %\n"			g_Randomness		to:fOutput
	format "g_BranchScaleA = %\n"		g_BranchScaleA		to:fOutput
	format "g_BranchScaleB = %\n"		g_BranchScaleB		to:fOutput
	format "g_bTreeRoots = %\n"			g_bTreeRoots		to:fOutput
	format "g_LeafSize = %\n"			g_LeafSize			to:fOutput
	format "g_LeafSizeRandom = %\n"		g_LeafSizeRandom	to:fOutput
	format "g_LeafViewPercent = %\n"	g_LeafViewPercent	to:fOutput
	format "g_LeafNum = %\n"			g_LeafNum			to:fOutput
	format "g_LeafNumRandom = %\n"		g_LeafNumRandom		to:fOutput
	format "g_LeafSpread = %\n"			g_LeafSpread		to:fOutput
	format "g_LeafType = %\n"			g_LeafType			to:fOutput
	format "g_AngleIndex = %\n"			g_AngleIndex		to:fOutput
	format "g_TreeName = \"%\"\n"		g_TreeName			to:fOutput
	format "g_BranchLenSegs = %\n" 		g_BranchLenSegs 	to:fOutput

	--
	-- The user can't change the following, but we store them so that they
	-- can be accurately reclaimed if the default values change in
	-- a later version of this script.
	--
	format "g_RadiusChange = %\n" 		g_RadiusChange 		to:fOutput
	format "g_LeafExtName = \"%\"\n"	g_LeafExtName		to:fOutput
	format "g_BranchExtName = \"%\"\n"	g_BranchExtName		to:fOutput
	format "g_ConnectExtName = \"%\"\n"	g_ConnectExtName	to:fOutput

	--
	-- flush the file and close it
	--
	flush fOutput
	close fOutput

	--
	-- Hey, it all worked. Let the calling routine know.
	--
	return true
)

-- ------------------------------------------------------------------------
-- function SettingsLoadDataFile sFileName =
--
-- Loads settings from [sFileName]
-- ------------------------------------------------------------------------
fn SettingsLoadDataFile sFileName =
(
	--
	-- Sanity check
	--
	if( sFileName == undefined ) then
		return false

	fInput = openFile sFileName mode:"r"
	if( fInput == undefined ) then
	(
		MessageBox ( "Unable to open \"" + sFileName + "\" for input." ) 
		return false
	)

	--
	-- Check to make sure this file contains the
	-- expected data
	--
	sInput = readLine fInput
	if( sInput != g_sDataFileTitle ) then
	(
	 	close fInput

		MessageBox ( "\"" + sFileName + "\" didn't appear to contain tree maker data." )
		return false
	)

	--
	-- Currently, we do nothing with
	-- the version info
	--
	sInput = readLine fInput

	--
	-- Read data from the file and execute it
	--
	while( not ( eof fInput ) ) do
	(
		sInput = readLine fInput
		execute sInput
	)

	--
	-- We're done with the file, so close it
	--
	close fInput

	return true
)


-- ------------------------------------------------------------------------
-- fn ParticleSnapShot pSys frame newName sel
--
-- This function makes a 'snapshot' of a particle system. [pSys] is the
-- particle system to snapshot (if not specified, then current selected
-- object is used). [frame] is the time frame at which to take the snapshot
-- (if not specified, then the current time is used), [newName] is the name
-- to give the resulting mesh, [sel] controls whether or not to select
-- the created mesh (default is false).
--
-- Returns the snapshotted particle system, or 'undefined' if an error
-- occurs.
--
-- Original function written by:
-- 			04.28.01, swami*, a.k.a. "codeWarrior()", swami@cfl.rr.com
-- 			Written for MAX r4.x
-- ------------------------------------------------------------------------
fn ParticleSnapShot pSys:(getCurrentSelection())[1]	frame:currentTime newName:#autoName sel: false = 
(
	local pm
	
	try
	(
		if( newName == #autoName ) then
			newName=( pSys.name + "_mesh" )
		
		if( pSys.category == #Particle_Systems ) then	
		(
			try
			(
				pm = particleMesher name:newName pos:pSys.pos pick:pSys isSelected:sel
				pm.transform = pSys.transform
				at time frame ( convertToMesh pm )
			)
			catch
			(
				pm = undefined
			)
			
		)
	)
	catch
	(
		pm = undefined
	)
	
	return pm
)

-- ------------------------------------------------------------------------
-- fn GCAE arr index =
--
-- Treats [arr] as a circular array and returns the value held in [index]
-- (GCAE = GetCircularArrayElement)
-- ------------------------------------------------------------------------
fn GCAE arr index =
(
	try
	(
		while( index < 1 ) do index += arr.count
		while( index > arr.count ) do index -= arr.count

		return arr[ index ]
	)
	catch
	(
		return undefined
	)
)

-- ------------------------------------------------------------------------
-- fn ConnectionMake1to1Mesh trunk branch angleInc =
--
-- [trunk] is the "main" branch for which an Connection to [branch1] and 
--		[branch2] is to be made
-- [branch] is the branch to form the Connection to
-- [angleInc] is the number of degrees between faces for the branch's 
--		circumference
--
-- NOTES: 
--	1) none of the input objects are altered by this routine.
--
-- returns the newly formed branch Connection.
-- ------------------------------------------------------------------------
fn ConnectionMake1to1Mesh trunk branch angleInc =
(
	numSides = ( 360. ) / angleInc
	retMesh = undefined

	--
	-- Sanity checks
	--
	if not ( LocalIsValidNode trunk ) then
	(
		return retMesh
	)

	if not ( LocalIsValidNode branch ) then
	(
		return retMesh
	)

	--
	-- Only need to make an Connection for [branch]. So, get
	-- the end vertices for [trunk] and [branch]. We use
	-- [tr] and [br] as fake circular arrays. This enables correct
	-- handling of the end cases by the for loops.
	--
	tr = #()
	br = #()
	vertsArr = #()
	for i in 1 to numSides do 
	(
		append vertsArr ( getVert trunk ( 2 + 2 * ( i - 1 ) ) )
		append tr ( i * 2 - 1 )

		append vertsArr ( getVert branch ( 1 + 2 * ( i - 1 ) ) )
		append br ( i * 2 )
	)

	--
	-- Determine the array indeces which produce a connection with
	-- the minimum total edge length (this should be the best match)
	--
	iIndexOffset = 0
	minLength = -1
	for i in -( numSides - 1 ) to ( numSides - 1 ) do
	(
		totalLength = 0
		for j in 1 to numSides do
		(
			totalLength += distance vertsArr[ ( GCAE tr j ) ] vertsArr[ ( GCAE br ( j + i ) ) ]
		)

		if( ( minLength == -1 ) or ( totalLength < minLength ) ) then
		(
			iIndexOffset = i
			minLength = totalLength
		)
	)

	--
	-- Make the faces
	--
	facesArr = #()
	for i in 1 to numSides do 
	(
		j = i + iIndexOffset
	 	append facesArr [ GCAE tr i, GCAE tr ( i + 1 ), GCAE br j ]
		append facesArr [ GCAE tr ( i + 1 ), GCAE br ( j + 1 ), GCAE br j ]
	)

	--
	-- Build the mesh
	--
	retMesh = mesh vertices:vertsArr faces:facesArr
	update retMesh

	--
	-- Free memory
	--
	facesArr = #()
	vertsArr = #()
	br = #()
	tr = #()

	return retMesh
)

-- ------------------------------------------------------------------------
-- fn ConnectionMake1to2Mesh trunk branch1 branch2 angleInc =
--
-- [trunk] is the "main" branch for which an Connection to [branch1] and 
--		[branch2] is to be made
-- [branch1] is the first branch in the Connection (can be "undefined")
-- [branch2] is the second branch in the Connection (can be "undefined")
-- [angleInc] is the number of degrees between faces for the branch's 
--		circumference
--
-- NOTES: 
--	1) none of the input objects are altered by this routine.
--	2) the created Connection is given texture coordinates based on
--		the length of [trunk]
--  3) the order of [branch1] and [branch2] is important, passing them
--		in the incorrect order will create an Connection with internal
--		polygon crossings. When looking at [trunk] such that it's first
--		vertex is closest to the view, [branch1] is the left-hand branch.
--
-- returns the newly formed branch Connection.
-- ------------------------------------------------------------------------
fn ConnectionMake1to2Mesh trunk branch1 branch2 angleInc =
(
	retMesh = undefined

	--
	-- Sanity check
	--
	if( not( LocalIsValidNode trunk ) or ( not ( ( LocalIsValidNode branch1 ) ) and ( not ( LocalIsValidNode branch2 ) ) ) ) then
	(
		return retMesh
	)

	if( not ( LocalIsValidNode branch1 ) ) then
	(
		retMesh = ConnectionMake1to1Mesh trunk branch2 angleInc
	)
	else if( not ( LocalIsValidNode branch2 ) ) then
	(
		retMesh = ConnectionMake1to1Mesh trunk branch1 angleInc
	)
	else
	(
		--
		-- Ok, need to make an Connection for both branches We use
		-- [tr], [b1] and [b2] as fake circular arrays. This enables 
		-- correct handling of the end cases by the for loops.
		--
		numSides = ( 360.) / angleInc

		tr=#()
		b1=#()
		b2=#()
		vertsArr = #()
		for i in 1 to numSides do
		(
			append vertsArr ( getVert trunk   ( 2 + 2 * ( i - 1 ) ) )
			append tr i
		)

		for i in 1 to numSides do
		(
			append vertsArr ( getVert branch1 ( 1 + 2 * ( i - 1 ) ) )
			append b1 ( i + NumSides )
		)

		for i in 1 to numSides do
		(
			append vertsArr ( getVert branch2 ( 1 + 2 * ( i - 1 ) ) )
			append b2 ( i + 2 * NumSides )
		)

		--
		-- Set up vars needed in calculations
		--
		quarterThru = numSides / 4 + 1
		halfThru = numSides / 2 + 1 
		threeQuartersThru = numSides * 3 / 4 + 1

		--
		-- Determine the array indeces which produce connections between
		-- the [trunk] and the branches. 
		--
		i = 0
		iInc = 1
		bDone = false
		iTrunkOffset = 0
		do
		(
			totalLength = 0

			--
			-- trunk to branch1
			--												 
			for j in quarterThru to threeQuartersThru do
			(
				totalLength += distance vertsArr[ ( GCAE tr ( j + i ) ) ] vertsArr[ ( GCAE b1 ( j + 1 ) ) ]
			)

			--
			-- Trunk to branch2
			--
			for j in threeQuartersThru to NumSides do
			(
				totalLength += distance vertsArr[ ( GCAE tr ( j + i ) ) ] vertsArr[ ( GCAE b2 ( j + 1 ) ) ]
			)

			if( ( i == 0 ) or ( totalLength < minLength ) ) then
			(
				iTrunkOffset = i
				minLength = totalLength
			)

			--
			-- Only search until we start to find larger values
			--
			if( totalLength > minLength ) then
			(
				if( i == 1 ) then
				(
					--
					-- We immediately found increasing values, so we
					-- want to check in the other direction
					--
					i = 0
					iInc = -iInc
				)
				else
					bDone = true
			)

			i += iInc
		) while( bDone == false )

		--
		-- Determine the array indeces which produce connections between
		-- [trunk]-[branch1] possessing the minimum total edge length 
		-- (this should be a good match).
		--
		i = 0
		iInc = 1
		bDone = false 
		iBranch1Offset = 0
		minLength = 0
		do
		(
			totalLength = 0
			for j in quarterThru to threeQuartersThru do
			(
				totalLength += distance vertsArr[ ( GCAE tr ( j + iTrunkOffset ) ) ] vertsArr[ ( GCAE b1 ( j + i + 1 ) ) ]
			)

			if( ( i == 0 ) or ( totalLength < minLength ) ) then
			(
				iBranch1Offset = i
				minLength = totalLength
			)

			--
			-- Only search until we start to find larger values
			--
			if( totalLength > minLength ) then
			(
				if( i == 1 ) then
				(
					--
					-- We immediately found increasing values, so we
					-- want to check in the other direction
					--
					i = 0
					iInc = -iInc
				)
				else
					bDone = true
			)
			i += iInc
		) while( bDone == false )

		--
		-- Determine the array indeces which produce connections between
		-- [trunk]-[branch2] possessing the minimum total edge length 
		-- (this should be a good match).
		--
		i = 0
		iInc = 1
		bDone = false
		iBranch2Offset = 0
		do
		(
			totalLength = 0
			for j in 1 to quarterThru do
			(
				totalLength += distance vertsArr[ ( GCAE tr ( j + iTrunkOffset ) ) ] vertsArr[ ( GCAE b2 ( j + i + 1 ) ) ]
			)
			for j in threeQuartersThru to NumSides do
			(
				totalLength += distance vertsArr[ ( GCAE tr ( j + iTrunkOffset ) ) ] vertsArr[ ( GCAE b2 ( j + i + 1 ) ) ]
			)

			if( ( i == 0 ) or ( totalLength < minLength ) ) then
			(
				iBranch2Offset = i
				minLength = totalLength
			)

			--
			-- Only search until we start to find larger values
			--
			if( totalLength > minLength ) then
			(
				if( i == 1 ) then
				(
					--
					-- We immediately found increasing values, so we
					-- want to check in the other direction
					--
					i = 0
					iInc = -iInc
				)
				else
					bDone = true
			)

			i += iInc
		) while( bDone == false )

		--
		-- We recalculate [iTrunkOffset] to be sure we have the minimum
		-- value
		--
		i = 0
		iInc = 1
		bDone = false
		iTrunkOffset = 0
		do
		(
			totalLength = 0

			--
			-- trunk to branch1
			--												 
			for j in quarterThru to threeQuartersThru do
			(
				totalLength += distance vertsArr[ ( GCAE tr ( j + i ) ) ] vertsArr[ ( GCAE b1 ( j + iBranch1Offset + 1 ) ) ]
			)

			--
			-- Trunk to branch2
			--
			for j in threeQuartersThru to NumSides do
			(
				totalLength += distance vertsArr[ ( GCAE tr ( j + i ) ) ] vertsArr[ ( GCAE b2 ( j + iBranch2Offset + 1 ) ) ]
			)

			if( ( i == 0 ) or ( totalLength < minLength ) ) then
			(
				iTrunkOffset = i
				minLength = totalLength
			)

			--
			-- Only search until we start to find larger values
			--
			if( totalLength > minLength ) then
			(
				if( i == 1 ) then
				(
					--
					-- We immediately found increasing values, so we
					-- want to check in the other direction
					--
					i = 0
					iInc = -iInc
				)
				else
					bDone = true
			)

			i += iInc
		) while( bDone == false )

		--
		-- Make faces for [branch1]
		--
		facesArr = #()
		for i in 1 to numSides do 
		(
			i1 = i + iBranch1Offset
			i2 = i - iBranch2Offset
			iT = i + iTrunkOffset

			if ( i < quarterThru ) then
			(
				--
				-- Connect to [branch2]'s 2nd quarter
				--
				append facesArr [ ( GCAE b1 i1 ), ( GCAE b2 ( halfThru - i2 ) ), ( GCAE b1 ( i1 + 1 ) ) ]
			)
			else if ( i <= threeQuartersThru ) then
			(
				--
				-- Connect to [trunk]
				--
				append facesArr [ ( GCAE b1 i1 ), ( GCAE tr iT ), ( GCAE b1 ( i1 + 1 ) ) ]
			)
			else
			(
				--
				-- connect to [branch2]'s 3rd quarter
				--
				append facesArr [ ( GCAE b1 i1 ), ( GCAE b2 ( 2 * threeQuartersThru - i2 ) ), ( GCAE b1 ( i1 + 1 )) ]
			)
		)

		--
		-- Faces for [branch2]
		--
		for i in 1 to numSides do 
		(
			i1 = i - iBranch1Offset
			i2 = i + iBranch2Offset
			iT = i + iTrunkOffset

			if( i < quarterThru ) then
			(
				--
				-- Connect to [trunk]
				--
				append facesArr [ ( GCAE b2 i2 ), ( GCAE tr iT ), ( GCAE b2 ( i2 + 1 ) ) ]
			)
			else if( i < halfThru ) then
			(
				--
				-- Connect to [branch1]'s 1st quarter
				--
				append facesArr [ ( GCAE b2 i2 ), ( GCAE b1 ( halfThru - i1 ) ), ( GCAE b2 ( i2 + 1 ) ) ]
			)
			else if( i < threeQuartersThru ) then
			(
				--
				-- connect to [branch1]'s 3rd quarter
				--
				append facesArr [ ( GCAE b2 i2 ), ( GCAE b1 ( b1.count - ( i1 - halfThru ) + 1 ) ), ( GCAE b2 ( i2 + 1 ) )]
			)
			else
			(
				--
				-- Connect to [trunk]
				--
				append facesArr [ ( GCAE b2 i2 ), ( GCAE tr iT ), ( GCAE b2 ( i2 + 1 ) ) ]
			)
		)

		--
		-- Faces for [trunk]
		--
		bSide1 = false
		bSide2 = false
		for i in 1 to numSides do 
		(
			i1 = i + iBranch1Offset
			i2 = i + iBranch2Offset
			iT = i + iTrunkOffset

			if( i < quarterThru ) then
			(
				--
				-- Connect to [branch2]
				--
				append facesArr [ ( GCAE tr iT ), ( GCAE tr ( iT + 1 ) ), ( GCAE b2 ( i2 + 1 ) ) ]
			)
			else if( i < threeQuartersThru ) then
			(
				--
				-- Connect [branch1] to [branch2] to [trunk]
				--
				if( bside1 == false ) then
				(
					append facesArr [ ( GCAE tr iT ), ( GCAE b1 i1 ), ( GCAE b2 ( i2 ) ) ]
					bSide1 = true
				)

				--
				-- Connect to [branch1]
				--
				append facesArr[ ( GCAE tr iT ), ( GCAE tr ( iT + 1 ) ), ( GCAE b1 ( i1 + 1 ) ) ]
			)
			else
			(
				--
				-- Connect [branch1] to [branch2] to [trunk]
				--
				if( bside2 == false ) then
				(
					append facesArr [ ( GCAE tr iT ), ( GCAE b2 i2 ), ( GCAE b1 ( i1 + 1 ) ) ]
					bSide2 = true
				)

				--
				-- Connect to [branch2]
				--
				append facesArr [ ( GCAE tr iT ), ( GCAE tr ( iT + 1 ) ), ( GCAE b2 ( i2 + 1 ) ) ]
			)
		)

		--
		-- Build the mesh
		--
		retMesh = mesh vertices:vertsArr faces:facesArr
		update retMesh

		--
		-- Free memory
		--
		facesArr = #()
		vertsArr = #()
		b1=#()
		b2=#()
		tr=#()
	)

	--
	-- Apply smoothing and a UVW map to the newly created
	-- Connection
	--
	if( retMesh != undefined ) then
	(
		retMesh.parent = trunk
		addmodifier retMesh (Smooth autoSmooth:true threshold:90.)
		addmodifier retMesh (uvwmap maptype:1)

		--
		-- Rather than check for the all of the necessary divide by zeros,
		-- we merely attempt the math and do nothing if it fails
		--
		try
		(
			scaleX = abs( ( trunk.max.X - trunk.min.X ) / ( retMesh.max.X - retMesh.min.X ) )
			scaleY = abs( ( trunk.max.Y - trunk.min.Y ) / ( retMesh.max.Y - retMesh.min.Y ) )
			scaleZ = abs( ( trunk.max.Z - trunk.min.Z ) / ( retMesh.max.Z - retMesh.min.Z ) )
			posZ = ( ( retMesh.max.z + retMesh.min.z ) / 2.0  - retMesh.min.z ) * ( scaleZ - 1.0 )

			retMesh.modifiers[ #UVW_Mapping ].gizmo.scale = [ scaleX, scaleY, scaleZ ]
			retMesh.modifiers[ #UVW_Mapping ].gizmo.pos += [ 0, 0, posZ ]
		)
		catch
		(
		)

		ConvertToMesh retMesh
		retMesh.name = uniqueName ( g_TreeName + g_ConnectExtName )
	)

	return retMesh
)

-- ------------------------------------------------------------------------
-- fn ConnectionStore tr br1 br2 angle =
--
-- Stores the supplied data into a global array ([g_Connections]) so that
-- the connections can later be made.
--
-- See also: {ConnectionMakeAll}
-- ------------------------------------------------------------------------
fn ConnectionStore tr br1 br2 angle =
(
	append g_Connections ( strctConnections trunk:tr branch1:br1 branch2:br2 Connect:undefined angleInc:angle )
)

-- ------------------------------------------------------------------------
-- fn ConnectionMakeAll =
--
-- Makes all of the connections previously stored. Doesn't make already
-- existing nodes
--
-- See also: {ConnectionStore}
-- ------------------------------------------------------------------------
fn ConnectionMakeAll =
(
	--
	-- Switch away from modify panel mode (which
	-- is always updated while scene items are
	-- being created)
	--
	max create mode

	--
	-- Disable screen draws (makes things faster),
	-- show a wait cursor and do the work
	--
	ProgressShowDialog "Generating connections..."
	setWaitCursor()

	disablesceneredraw()
	undo off 
	(
		ProgressSetFirstString "Building..."
	
		count = 1
		for i in g_Connections do
		(
			prcntDone = ( ( count as float ) * 1000. / (g_Connections.count as float ) ) as integer
			prcntDone = prcntDone / 10. as float

			if( not ( LocalIsValidNode i.connect ) ) then
			(
				if( LocalIsValidNode i.trunk ) then 
				(
					ProgressSetSecondString ( "Progress: " + prcntDone  as string + "% done              " )

					i.Connect = ConnectionMake1to2Mesh i.trunk i.branch1 i.branch2 i.angleInc
				)
			)

			count += 1
		)
	)
	
	--
	-- Done!
	--
	enablesceneredraw()
	setArrowCursor()
	ProgressHideDialog()
)

-- ------------------------------------------------------------------------
-- fn BranchMakeMesh radius1 radius2 Length angleInc bCloseTop =
--
-- [Radius1] is the radius of the "large" end of the branch
-- [Radius2] is the radius of the "small" end of the branch
-- [Length] is the length of the branch
-- [angleInc] is the number of degrees between faces for the branch's 
--		circumference
-- [bCloseTop] controls whether or not the "small" end of the branch
--		is closed
--
-- NOTES: The branch is created with the center of it's "large" end
-- centered at the origin, and the center of it's "small" end centered
-- about the z axis.
--
-- returns the newly made branch mesh
-- ------------------------------------------------------------------------
fn BranchMakeMesh radius1 radius2 Length angleInc bCloseTop =
(
	--
	-- Make the vertices
	--
	vertsArr = #()
	for theta in 0 to ( 360 - angleInc ) by angleInc do
	(
		x1 = radius1 * cos( theta )
		y1 = radius1 * sin( theta )
		z1 = 0

		x2 = radius2 * cos( theta )
		y2 = radius2 * sin( theta )
		z2 = Length

		append vertsArr [ x1, y1, z1 ]
		append vertsArr [ x2, y2, z2 ]
	)

	--
	-- Make the side faces
	--
	facesArr = #()
	for i in 1 to ( vertsArr.count - 2 ) by 2 do
	(
		append facesArr [ i, i + 2, i + 1 ]
		append facesArr [ i + 2, i + 3, i + 1 ]
	)

	i = vertsArr.count
	append facesArr [ i - 1, 1, i ]
	append facesArr [ 1, 2, i ]

	--
	-- Make the top faces (if necessary)
	--
	if( bCloseTop ) then
	(
		append vertsArr [ 0, 0, length + length / 8.0 ]
		i = vertsArr.count

		for j in 2 to ( vertsArr.count - 3 ) by 2 do 
		(
			append facesArr [ j, j + 2, i ]
		)

		--
		-- Final face
		--
		append facesArr [ i - 1, 2, i ]
	)

	--
	-- Build the mesh
	--
	branchMesh = mesh vertices:vertsArr faces:facesArr
	update branchMesh

	--
	-- Apply modifiers and then collapse
	--
	addmodifier branchMesh (Smooth autoSmooth:true threshold:60.)
	addmodifier branchMesh (uvwmap maptype:1)

	--
	-- Add segments along the length of the mesh
	--
	dist = Length / ( g_BranchLenSegs )
	for i in 2 to g_BranchLenSegs do 
	(
		addModifier branchMesh (SliceModifier())
		branchMesh.modifiers[ 1 ].Slice_type = 0

		--
		-- Move it appropriately
		--
		branchMesh.modifiers[1].slice_plane.pos += [ 0, 0, dist * ( ( i - 1. ) as float ) ]
	)

	--
	-- Collapse the mesh
	--
	ConvertToMesh branchMesh

	--
	-- Free up memory
	--
	facesArr = #()
	VertsArr = #()

	append g_Branches branchMesh
	branchMesh.name = uniqueName ( g_TreeName + g_BranchExtName )
	return branchMesh
)

-- ------------------------------------------------------------------------
-- fn BranchCreateNext position xDeviation yDeviation Size bClose=
--
-- Makes a new branch at [postion] using [xDeviation] and [yDeviation]
-- to control rotation. The branch has a length of [Size] and it's
-- radius is given by [size]*[size] / 10000. * [g_Thickness] ([g_Thickness]
-- is a global variable which determines the aspect ratio of the branches.
-- If [bClose] is true, then the created branch is given a closed tip, 
-- else it's left open.
--
-- returns a struct of type strctBranchReturn containing the newly
-- formed branch and the location of the next branch to make
-- ------------------------------------------------------------------------
fn BranchCreateNext position xDeviation yDeviation Size bClose =
(
	r1 = ( Size^2 / 10000. * g_Thickness ) * g_RadiusChange
	r2 = r1 / g_RadiusChange
	b = BranchMakeMesh r1 r2 size g_AngleValues[ g_AngleIndex ] bClose
	
	--
	-- Try to keep branches out of each other's way
	--
	in coordsys local rotate b xDeviation x_axis
	in coordsys local rotate b yDeviation y_axis

	--
	-- Move the branch to minimize overlap with siblings
	--
	b.pos = position + ( b.dir * r1 * g_BranchDistance )

	z += 1
	g_BranchNumber += 1

	ProgressSetSecondString ( "Making branch: " + ( g_BranchNumber as string ) ) 

	--
	-- Return relevant information
	--
	Result = strctBranchReturn branchMesh:b newPos:(b.pos + b.dir * Size )
	return Result
)

-- ------------------------------------------------------------------------
-- fn LeafStore val =
--
-- Stores [val] in the global array of branchs for which to make leaves
-- ------------------------------------------------------------------------
fn LeafStore val =
(
	append g_LeafNodes ( strctLeafNode branch:val leafMesh:undefined)
)

-- ------------------------------------------------------------------------
-- fn LeafMakeNodes =
--
-- Makes a series of particle clouds at the end of each of the branches
-- ------------------------------------------------------------------------
fn LeafMakeNodes =
(
	--
	-- Switch away from modify panel mode (because it
	-- is always updated when scene items are created, and hence
	-- slows everything WAY down)
	--
	max create mode

	--
	-- Turn off undo, screen redraw and show
	-- dialog box
	--
	ProgressShowDialog "Building leaf nodes..."
	setWaitCursor()
	disablesceneredraw()

	--
	-- We define these to make the for loop faster
	--
	fMinRan = g_LeafNum * ( 1.0 - ( g_LeafNumRandom / 100. ) )
	fMaxRan = g_LeafNum * ( 1.0 + ( g_LeafNumRandom / 100. ) )

	fMinScale = g_LeafSize * ( 1.0 - ( g_LeafSizeRandom / 100. ) )
	fMaxScale = g_LeafSize * ( 1.0 + ( g_LeafSizeRandom / 100. ) )

	--
	-- Build the nodes
	--
	iCount = 0
	for i in g_LeafNodes do 
	(
		--
		-- Delete any existing leaf node here (get it's material, though)
		--
		mtl = undefined
		if( LocalIsValidNode i.leafMesh ) then
		(
			mtl = i.leafMesh.material
			delete i.LeafMesh
		)

		--
		-- The user could have deleted the original branch, so
		-- we check for it. If it isn't there, we don't
		-- create a leaf node.
		--
		if( LocalIsValidNode i.branch ) then
		(
			if( not LocalIsVIZ() ) then
			(
				newNode = pcloud()
			
				i.leafMesh = newNode

				newNode.pos = ( getVert i.branch ( i.branch.numVerts ) )
				newNode.name = uniqueName ( g_TreeName + g_LeafExtName )
				newNode.Parent = i.branch

				if( mtl != undefined ) then
					newNode.material = mtl

				newNode.formation = 1
				newNode.standardParticle = g_LeafType
				newNode.emitter_rad_len = g_LeafSpread
				newNode.emitterHidden = true
				newNode.viewType = 2
				newNode.quantityMethod = 1
				newNode.total_Number = random fMinRan fMaxRan
				newNode.emitter_Start = 0
				newNode.emitter_Stop = 0
				newNode.Display_Until = 999999
				newNode.size = g_LeafSize
				newNode.size_variation = g_LeafSizeRandom
				newNode.growth_time = 0
				newNode.fade_time = 0
				newNode.spin_time = 0
				newNode.spin_phase = 360
				newNode.viewPercent = g_LeafViewPercent
				newNode.spin_phase_variation = 100
			
				newNode.seed = iCount + g_RandomSeed
			)
			else
			(
				--
				-- Under VIZ, we create generic, tetrahedral leaves
				--
				i.leafMesh = undefined

				iNumLeaves = ( random fMinRan fMaxRan ) as integer
				for j in 1 to iNumLeaves do
				(
					case g_LeafType of
					(
						0:
						(
							newLeaf = mesh vertices:#( [ 0, 0.33, 0 ], [ 1, 0.33, 0 ], [ 1, -0.33, 0 ], [ 0, -0.33, 0 ] ) faces:#( [ 4, 3, 2 ], [ 2, 1, 4 ] ) 
						)

						1:
						(
							newLeaf = mesh vertices:#( [ 0,0,0 ], [ 1, 0, 0 ], [ 0.33, 0.33, 0 ], [ 0.33, -0.33, 0 ] ) faces:#( [1,2,3], [1,4,2] )
						)
					)

					newLeaf.pivot = [ 0, 0, 0 ]
					newLeaf.scale *= random fMinScale fMaxScale
					newLeaf.dir = ( normalize [ random -1. 1., random -1. 1., random -1. 1. ] )
					newLeaf.pos = ( getVert i.branch ( i.branch.numVerts ) ) + ( normalize [ random -1. 1., random -1. 1., random -1. 1. ] ) * ( random  0. g_LeafSpread )

					addModifier newLeaf (uvwmap())
					convertToMesh newLeaf

					--
					-- If this is the first leaf, then we use it as
					-- the base mesh, else we append the leaf to the 
					-- leaf base mesh
					--
					if( i.leafMesh == undefined ) then
					(
						i.leafMesh = newLeaf

						i.leafMesh.name = uniqueName ( g_TreeName + g_LeafExtName )
						i.leafMesh.parent = i.branch

						if( mtl != undefined ) then
							i.leafMesh.material = mtl
					)
					else
						attach i.leafMesh newLeaf
				) 	
			)

			iCount += 1
			prcntDone = ( ( iCount  as float ) * 1000. / ( g_LeafNodes.count as float ) ) as integer
			prcntDone = prcntDone / 10. as float
			ProgressSetFirstString ( "Progress: " + prcntDone as string + "% done              " )
		)
	)

	--
	-- Turn screen update back on and
	-- kill dialog box
	--
	enablesceneredraw()
	setArrowCursor()
	ProgressHideDialog()
)

-- ------------------------------------------------------------------------
-- fn LeafCollapseToMesh =
--
-- Collapses all of the leaf nodes into a single mesh
-- ------------------------------------------------------------------------
fn LeafCollapseToMesh =
(
	--
	-- Switch away from modify panel mode (because it
	-- is always updated while scene items are created, and hence
	-- slows everything WAY down)
	--
	max create mode

	--
	-- Turn off undo, screen redraw and show
	-- dialog box
	--
	ProgressShowDialog "Collapsing leaves..."
	setWaitCursor()
	disablesceneredraw()

	--
	-- Build the nodes
	--
	retMesh = undefined
	for i in g_LeafNodes.count to 1 by -1 do 
	(
		tmp = undefined 

		if( LocalIsValidNode g_LeafNodes[ i ].leafMesh ) then
		(
			if( LocalIsVIZ() ) then
			(
				--
				-- In VIZ, the leaves are already a mesh, so there
				-- is no need to convert them into a mesh
				--
				tmp = g_LeafNodes[ i ].leafMesh
			)
			else
			(
				--
				-- We want to include all of the leaves, not
				-- just the visible ones
				--
				g_LeafNodes[ i ].leafMesh.viewPercent = 100
				tmp = ParticleSnapShot pSys:g_LeafNodes[ i ].leafMesh
				delete g_LeafNodes[ i ].LeafMesh
			)

			if( retMesh == undefined ) then
			(
				retMesh = tmp
			)
			else
			(
				attach retMesh tmp			 	
			)

			g_LeafNodes[ i ].LeafMesh = undefined
		)

		--
		-- Update the percent done dialog
		--
		prcntDone = ( ( ( g_LeafNodes.count - i ) as float ) * 1000. / ( g_LeafNodes.count as float ) ) as integer
		prcntDone = prcntDone / 10. as float
		ProgressSetFirstString ( "Progress: " + prcntDone as string + "% done              " )

	)

	--
	-- Turn screen update back on and
	-- kill dialog box
	--
	enablesceneredraw()
	setArrowCursor()
	ProgressHideDialog()

	return retMesh
)


-- ------------------------------------------------------------------------
-- fn TreeMakeTrunk position Size =
--
-- Makes the main trunk (and root ball if specified)
-- ------------------------------------------------------------------------
fn TreeMakeTrunk position Size =
(
	--
	-- Main trunk
	--
	mainRadius = ( Size^2) / 10000. * g_Thickness
	r1 = mainRadius 
	r2 = mainRadius / g_RadiusChange
	scale = 1.0

	if ( g_bTreeRoots ) then
	(
		scale = 6.0 / 7.0
	)
	else
	(
		scale = 1.0
	)

	retMesh = BranchMakeMesh r1 r2 ( Size * scale ) g_AngleValues[ g_AngleIndex ] false

	--
	-- Do we need to make roots?
	--
	if( g_bTreeRoots ) then
	(
		r1 = mainRadius * g_RadiusChange * 1.5
		r2 = mainRadius 

		rootMesh = BranchMakeMesh r1 r2 ( size / 7.0 ) g_AngleValues[ g_AngleIndex ] false

		--
		-- Adjust the mapping to create a smooth transition with trunk
		--
		addmodifier rootMesh ( uvwmap maptype:1 )
		rootMesh.modifiers[ #UVW_Mapping ].height = size
		rootMesh.modifiers[ #UVW_Mapping ].width = r1
		rootMesh.modifiers[ #UVW_Mapping ].length = r1
--
-- This generates an error, and I don't know why.
--
--		rootMesh.modifiers[ #UVW_Mapping ].gizmo.pos = [ 0, 0, -size * 5.0 / 7.0 ]
		ConvertToMesh rootMesh

		retMesh.pos = position + [ 0, 0, ( size / 7.0 )]
		retMesh.parent = rootMesh
	)

	return retMesh
)

-- ------------------------------------------------------------------------
-- fn TreeMakeBifurcation Position Deviation_x Deviation_y Size Pulse parent =
--
-- Makes two new branches at [position] with rotations and size given
-- by [Deviation_X], [Deviation_Y] and [Size], respectively.
-- [pulse] is used to determine if the branches are part of an "A" or a "B" 
-- parent branch. [parent] is the branch that these two new branches are
-- growing off of.
-- ------------------------------------------------------------------------
fn TreeMakeBifurcation Position Deviation_x Deviation_y Size Pulse parent =
(
	--
	-- Check size to determine if we're a branch or a leaf
	--
	if Size >= g_Limits then
	(
		--
		-- Ok, we're still make limbs
		--
		Pulse = -Pulse
		if( ( random 0 ( 100 - g_Randomness ) ) < 3 ) then
			Pulse = - Pulse

		new_Deviation_A_x = Deviation_x + random -g_Randomness g_Randomness
		new_Deviation_A_y = Deviation_y + random -g_Randomness g_Randomness

		new_Deviation_B_x = Deviation_x + random -g_Randomness g_Randomness
		new_Deviation_B_y = Deviation_y + random -g_Randomness g_Randomness  

		if( z <= 3 ) then
			Actual_g_BranchAngle = g_BranchAngle / 2.
		else 
			Actual_g_BranchAngle = g_BranchAngle

		Actual_g_BranchAngle_A = Actual_g_BranchAngle_B = Actual_g_BranchAngle

		zf = 100 - g_Randomness
		if Size * 2 > g_StartLength do zf = 10000

		if( ( random 0 zf ) < 20 ) then
			Actual_g_BranchAngle_A = 0

		if( ( random 0 zf ) < 20 ) then
			Actual_g_BranchAngle_B = 0

		if( Pulse == 1 ) then
		(
			new_Deviation_A_x = new_Deviation_A_x + Actual_g_BranchAngle_A
			new_Deviation_B_x = new_Deviation_B_x - Actual_g_BranchAngle_B
		)
		else
		(
			new_Deviation_A_y = new_Deviation_A_y + Actual_g_BranchAngle_A
			new_Deviation_B_y = new_Deviation_B_y - Actual_g_BranchAngle_B
		)

		GVA = Size * g_BranchScaleA - g_CatchValue
		GVA = GVA + ( random (-( GVA / ( 100 - g_Randomness ) ) ) ( GVA / ( 100 - g_Randomness ) ) ) / 2
		GVB = Size * g_BranchScaleB - g_CatchValue										    
		GVB = GVB + ( random (-( GVB / ( 100 - g_Randomness ) ) ) ( GVB / ( 100 - g_Randomness ) ) ) / 2

		if( GVA < g_Limits ) then
			bCloseA = true
		else
			bCloseA = false

		if( GVB < g_Limits ) then
			bCloseB = true
		else
			bCloseB = false 

		brInfoA = BranchCreateNext Position new_Deviation_A_x new_Deviation_A_y GVA bCloseA
		brInfoB = BranchCreateNext Position new_Deviation_B_x new_Deviation_B_y GVB bCloseB

		--
		-- Give the branches the correct parents
		--
		brInfoA.branchMesh.parent = parent
		brInfoB.branchMesh.parent = parent

		--
		-- We'll want to append these later
		--
		ConnectionStore parent brInfoB.branchMesh brInfoA.branchMesh g_AngleValues[ g_AngleIndex ]

		TreeMakeBifurcation brInfoA.newPos new_Deviation_A_x new_Deviation_A_y GVA Pulse brInfoA.branchMesh
		TreeMakeBifurcation brInfoB.newPos new_Deviation_B_x new_Deviation_B_y GVB Pulse brInfoB.branchMesh
	)
	else
	(
		--
		-- We're at the end of a branch, so want to make leaves
		--
		LeafStore parent
	)	
)


-- ------------------------------------------------------------------------
-- fn TreeBuild =
--
-- This builds all of the branches, leaves, etc. for a tree.
-- ------------------------------------------------------------------------
fn TreeBuild =
(
	--
	-- Switch away from modify panel mode (because it
	-- is always updated while scene items are created, and hence
	-- slows everything WAY down)
	--
	max create mode

	--
	-- Turn off undo, screen redraw and show
	-- dialog box
	--
	ProgressShowDialog "Generating branches..."

	setWaitCursor()
	disablesceneredraw()
	undo off 
	(
		ProgressSetFirstString "Initializing..."
		z = 0
		g_BranchNumber = 0
		g_LeavesNumber = 0
		g_Limits = g_BranchMinLen * g_TrunkLength / 100.0
		g_StartLength = g_TrunkLength
		g_Connections = #()
		g_Branches = #()
		g_LeafNodes = #()

		trunk = TreeMakeTrunk g_StartPosition g_TrunkLength

		ProgressSetFirstString "Building..."
		TreeMakeBifurcation [ g_StartPosition.x, g_StartPosition.y, g_StartPosition.z + g_TrunkLength ] 0 0 g_TrunkLength 1 trunk
		ProgressSetSecondString ""

	)
	
	--
	-- Turn screen update back on and
	-- kill dialog box
	--
	enablesceneredraw()
	setArrowCursor()
	ProgressHideDialog()
)

-- ------------------------------------------------------------------------
-- fn TreeCollapseToMesh  =
--
-- Collapses the contents of [g_Branches] and [g_Connections] into a 
-- mesh. It then welds all of the vertices of the created mesh.
--
-- Returns the collapses mesh
-- ------------------------------------------------------------------------
fn TreeCollapseToMesh  =
(
	retMesh = undefined

	--
	-- Determine the "main branch" (we do it this way
	-- because the user may have deleted the "original" 
	-- main branch)
	--
	for i in g_Branches do 
	(
		if ( LocalIsValidNode i ) then
		(
			retMesh = i
			exit
		)
	)

	--
	-- Sanity check
	--
	if( retMesh == undefined ) then
	(
		return retMesh
	)

	--
	-- Progress
	--
	setWaitCursor()
	disableSceneRedraw()
	ProgressShowDialog "Collapsing..."

	--
	-- Gather up all of the branches
	--
	ProgressSetFirstString "...branches"
	for i in g_Branches.count to 1 by -1 do 
	(
		if( ( LocalIsValidNode g_Branches[ i ] ) and ( g_Branches[ i ] != retMesh ) ) then
		(
			attach retMesh g_Branches[ i ]
		)
	)

	--
	-- Gather up all of the connections
	--
	ProgressSetFirstString "...connections"
	for i in g_Connections.count to 1 by -1 do 
	(
		if( LocalIsValidNode g_Connections[ i ].Connect ) then
		(
			attach retMesh g_Connections[ i ].Connect
		)
	)

	--
	-- Select all of the vertices and weld them together
	--
	ProgressSetFirstString "Welding Results"
	ProgressSetSecondString "This could take awhile. Reminisce about past..."
	retMesh.selectedvertices = for i in 1 to retMesh.numverts collect i
	
	--
	-- In MAX 4, there is an error in which if the panels are docked 
	-- on the left, the panels are in inverse order. So we have
	-- this check here to address the issue.
	--
	max utility mode
	max create mode
	max modify mode
	if( subObjectLevel == undefined ) then 
	(				  
		max create mode
		max display mode
	)

	select retMesh
	modPanel.setCurrentObject retMesh
	subObjectLevel = 1

	--
	-- We use try()/catch() here because this .setUIParam doesn't
	-- exist under MAX 3.X
	--
	try( meshop.setUIParam retMesh #WeldDist 0.1 ) catch()
	meshops.weld retMesh 
	subObjectLevel = 0

	--
	-- Reparent leaf nodes accordingly
	--
	if( LocalIsValidNode g_LeafMesh ) then
	(
		g_LeafMesh.parent = retMesh
	)
	else
	(
		for i in g_LeafNodes do
		(
			if( LocalIsValidNode i.LeafMesh ) then
				i.LeafMesh.parent = retMesh
		)
	)

	--
	-- Close down the progress meter
	--
	ProgressHideDialog()
	EnableSceneRedraw()

	--
	-- Free up memory
	--
	g_Branches = #()
	g_Connections = #()
	setArrowCursor()

	return retMesh
)

--
-- If the main floater exists, close it.
--

fn InitializeFloater =
(
	try( CloseRolloutFloater g_TM_dlgMain ) catch()
	g_TM_dlgMain = NewRolloutFloater "Tree Maker version 5.0" 400 500
	
	--
	-- Populate floater
	--
	AddRollout g_TM_roGreenThumbCentral g_TM_dlgMain 
	addrollout g_TM_roBranchOptions   	g_TM_dlgMain rolledup:true
	addrollout g_TM_roConnectionTools 	g_TM_dlgMain rolledup:true
	
	--
	-- If this is VIZ, we have slightly different leaf options
	--
	if( LocalIsVIZ()) then
	(
		if( g_LeafType > 1 ) then
			g_LeafType = 0

	  	addrollout g_TM_roLeafOptionsVIZ   	g_TM_dlgMain rolledup:true
	)
	else
		addrollout g_TM_roLeafOptions     	g_TM_dlgMain rolledup:true

	addrollout g_TM_roTreeIO   			g_TM_dlgMain rolledup:true
	addrollout g_TM_roAbout	   			g_TM_dlgMain rolledup:true
)

(
	rollout TreeHelp_Window_1 "OverView:"
	(
		label lab1_01 "This script can be used to generate a single mesh tree. This is done in several steps. First," align:#left offset:[0,-5]
		label lab1_02 "choose the desired random seed (Green Thumb Central (GTC) rollout), second choose the desired" align:#left offset:[0,-5]
		label lab1_03 "branch options (Branch Option (BO) rollout), finally click the \"Generate Branches\" button (GTC)." align:#left offset:[0,-5]
		label lab1_04 "Once the basic tree has been generated, move and/or rotate the created limbs into the final shape. " align:#left offset:[0,-5]
		label lab1_05 "Try to AVOID overlapping any of the branches and also try to fix any existing overlapping branches" align:#left offset:[0,-5]
		label lab1_06 "(the creation routines do some of this for you, but they aren't perfect.) NOTE: overlapping" align:#left offset:[0,-5]
		label lab1_07 "branches don't cause scripting errors, just funky looking branch connections; so for a first pass," align:#left offset:[0,-5]
		label lab1_08 "you probably only need to worry about the bigger branches. You can delete branches you don't" align:#left offset:[0,-5]
		label lab1_09 "want, but do so carefully. Once a branch has been deleted, it will not be used in further calculations" align:#left offset:[0,-5]
		label lab1_10 "even if you undelete it. You can move, scale, rotate and edit the meshes for each of the branches." align:#left offset:[0,-5]
		label lab1_11 "But do NOT add or delete vertices/faces or use the mirror command on a branch. " align:#left offset:[0,-5]
		label lab1_12 ""
		label lab1_13 "Once you're satisfied with the branch layout, press the \"generate connections\" button (GTC). This" align:#left offset:[0,-5]
		label lab1_14 "will create connections between all of the branches. If you find that you don't like a connection," align:#left offset:[0,-5]
		label lab1_15 "you can move/rotate the branches that it's connected to and then click the \"Regenerate " align:#left offset:[0,-5]
		label lab1_16 "Selected connections\" button on the Tree Tools (TT) rollout. If a given connection" align:#left offset:[0,-5]
		label lab1_17 "is particularly bad, you can try the \"Flip selected connections\" button (TT). This will swap the order" align:#left offset:[0,-5]
		label lab1_18 "that the smaller branches are connected to the bigger one." align:#left offset:[0,-5]
		label labl_19 ""
		label labl_20 "After you're happy with the connections, press the \"Generate Leaves\" button to populate the" align:#left offset:[0,-5]
		label labl_21 "branches with leaves. You should note that leaves are only generated for existing branches. So" align:#left offset:[0,-5]
		label labl_22 "if you delete a branch no leaves will be created for it. As such, you can only generate leaves" align:#left offset:[0,-5]
		label labl_23 "BEFORE you collapse the mesh." align:#left offset:[0,-5]
		label lab1_24 ""
		label lab1_25 "Once you have the branches and leaves to your liking, press the \"Collapse Branches\" button" align:#left offset:[0,-5]
		label lab1_26 "(GTC). This will collapse the branches and connections into a single mesh. The resulting" align:#left offset:[0,-5]
		label lab1_27 "mesh will already have texture coordinates applied." align:#left offset:[0,-5]
	)
	   
	rollout TreeHelp_Window_2 "Green Thumb Central:"
	(
		label lab2_00 "\"Name:\" is the name to call the mesh once it is collapsed." align:#left
		label lab2_01 "\"Seed:\" is the random number seed." align:#left 
				   
		label lab2_03 "\"Detail\" controls the number of sides branches and connections have. When set to \"very" align:#left
		label lab2_04 "high\", branches have 40 sides; for \"high\" 20 sided branches are created; for \"medium\" branches" align:#left offset:[0,-5]
		label lab2_05 "have 12 sides; for \"low\" 8 sides are generated; and for \"very low\" 4 sides are generated." align:#left offset:[0,-5]
				   
		label lab2_07 "\"Generate Branches\" press this button to build the branches for a tree. To control how the " align:#left
		label lab2_08 "branches are created, change the values found in the \"Branch Options\" rollout." align:#left offset:[0,-5]
				   
	   	label lab2_10 "\"Generate connections\" press this button to generate the connections between the branches." align:#left
	   	label lab2_11 "This does the same thing as pressing the \"Generate missing connections\" button on the " align:#left offset:[0,-5]
	   	label lab2_12 "\"Tree Tools\" rollout." align:#left offset:[0,-5]

		label lab2_19 "\"Generate Leaves\" press this button to generate leaves at the end of each branch. Any existing" align:#left
		label lab2_20 "leaves are deleted before new ones are created. So you can change leaf parameters in the" align:#left offset:[0,-5]
		label lab2_21 "\"Leaf Options\" rollout and then press this button to create leaves using the new values." align:#left offset:[0,-5]
				   
		label lab2_14 "\"Collapse Branches\" collapses all of the branches and connections into a single mesh. The" align:#left
		label lab2_15 "resulting mesh already has texture coordinates and can be further refined via normal mesh editting" align:#left offset:[0,-5]
		label lab2_16 "routines. NOTE: Currently, collapsing a tree is NOT UNDOABLE!!!!!" align:#left offset:[0,-5]
	  
		label lab2_22 "\"Collapse Leaves\" collapses all of the leaves into a single mesh. If you selected \"facing\" or" align:#left
		label lab2_23 "\"constant\" as your leaf type, this may not produce the desired results. Collapsing leaves is NOT" align:#left offset:[0,-5]
		label lab2_24 "UNDOABLE! Collapsing leaves is only supported on MAX 4.x." align:#left offset:[0,-5]
			   
		label lab2_18 "\"Help Me\" you already know what this does, you're here, right?" align:#left
	)
	   
	rollout TreeHelp_Window_3  "Branch Options:"
	(
	   	label lab3_00 "\"Trunk Length:\" the length of the trunk to the first branching." align:#left
		label lab3_01 "The \"Branch radius\" controls the diameter of the branch. When at 100%, a branch is as thick" align:#left offset:[0,5]
		label lab3_02 "as it is long." align:#left offset:[0,-5]
		label lab3_03 "The \"Minimum Branch Length\" parameter adjusts the minimum length of a branch as a percent of" align:#left offset:[0,5]
		label lab3_04 "trunk size. Smaller values result in more detailed trees and longer creation times." align:#left offset:[0,-5]
		label lab3_05 "The \"Angle between branches\" adjusts the average angle between 2 new branches. Lower" align:#left offset:[0,5]
		label lab3_06 "values result in more vertical trees. Higher values cause spralling trees." align:#left offset:[0,-5]
	   	label lab3_07 "\"Randomness\" controls the amount of randomness used in branch creations. Higher values " align:#left
	   	label lab3_08 "result in more irregular looking trees." align:#left offset:[0,-5]
		label lab3_09 "When two new branches (Branch A and Branch B) grow off the end of a branch, they will be" align:#left offset:[0,5]
		label lab3_10 "smaller than their parent-branch. \"Branch A Size\" and \"Branch B Size\" control the new branch" align:#left offset:[0,-5]
		label lab3_11 "sizes as a percentage of the parent-branch. If the two values are different, the tree will look like" align:#left offset:[0,-5]
		label lab3_12 "it has been growing in the wind. Higher values result in greater branch detail and higher" align:#left offset:[0,-5]
		label lab3_13 "creation times. Values higher than 95% can lead to creation times of hours." align:#left offset:[0,-5]
		label lab3_14 "\"Branch to branch distance\" is a multiplier value used to move child branches away from their" align:#left
		label lab3_15 "parents. This effectively creates longer connection areas and helps to prevent sibling branches" align:#left offset:[0,-5] 
		label lab3_16 "from overlapping." align:#left offset:[0,-5]
	
		label lab3_17 "\"Branch number length segments\" is the number of segments the branch has along its length" align:#left
	
		label lab3_18 "\"Flare bottom\" creates a flare in the lower seventh of the trunk to simulate the roots." align:#left offset:[0,5]
	)

	rollout TreeHelp_Window_4  "Tree Tools:"
	(
		label lab4_00 "\"Select Subbranches\" will select all of the \"child\" branches and connections for any currently" align:#left
		label lab4_01 "selected branches." align:#left offset:[0,-5]
		label lab4_02 "\"Generate Missing Connections\" creates any connection currently not present in the scene." align:#left
		label lab4_03 "\"Regenerate Selected Connections\" will delete and reform any currently selected connections. " align:#left
		label lab4_04 "Use this after you have changed the branches around a connection." align:#left offset:[0,-5]
		label lab4_05 "\"Delete Connections\" deletes all of the tree's connections." align:#left
		label lab4_06 "\"Flip Selected Connections\" press this button if the selected connection(s) contain many faces" align:#left
		label lab4_07 "that appear to intersect. This will regenerate the connection, but switch the order of the two" align:#left offset:[0,-5]
		label lab4_08 "subordinate branches. This new order is kept in memory so that if the connection is later " align:#left offset:[0,-5]
		label lab4_09 "destroyed, the new order will again be used when the connection is regenerated." align:#left offset:[0,-5]
		label lab4_10 "\"Select Branch Ends\" selects the final branch on each limb. This is useful for \"pruning\"" align:#left
		label lab4_11 "the tree because you can press this button and then delete the end branches." align:#left offset:[0,-5]
	)			   

	rollout TreeHelp_Window_5 "Leaf Options:"
	(
	   	label lab5_02 "\"Leaf Size\" is the size of each of the leaves to be created." align:#left 
	   	label lab5_03 "\"Leaf Size Randomization\" is the percent by which a leaf may deviate from the value specified" align:#left
	   	label lab5_04 "in \"Leaf Size\"." align:#left offset:[0,-5]
	   	label lab5_05 "\"Number of Leaves per Twig\" controls how many leaves to create at then end of each branch." align:#left 
	   	label lab5_06 "\"Leaf Number Randomization\" is the percent by which the number of leaves at the end of a branch" align:#left 
	   	label lab5_07 "may differ from the number specified in \"Number of Leaves per Twig\"." align:#left offset:[0,-5]
	   	label lab5_08 "\"Percent of Leaves to Show in Viewport\" controls how many of the leaves are displayed in the" align:#left
	   	label lab5_09 "viewports. NOTE: not available under VIZ." align:#left offset:[0,-5]
	   	label lab5_10 "\"Leaf Spread Radius\" specifies in world units how far away from the end of a branch a leaf can" align:#left
	   	label lab5_11 "be created." align:#left offset:[0,-5]
	   	label lab5_12 "\"Leaf Type\" allows you to control the geometry of the leaves created. For more information" align:#left
	   	label lab5_13 "look up \"particle type\" for pCloud particle generators in the MAX documents." align:#left offset:[0,-5]
	   	label lab5_14 "NOTE: leaf types of \"facing\" and \"constant\" do NOT correctly collapse into a single mesh." align:#left
		label lab5_15 "NOTE: under VIZ, you can only choose rectangular or tetra for leaf type." align:#left
	)

	rollout TreeHelp_Window_6 "Load and Save Tree maker settings:"
	(
	   	label lab6_01 "Use \"Load settings\" to load previously stored tree maker settings." align:#left offset:[0,-5]
		label lab6_02 "Use \"Save settings\" to save out the current tree settings to a file so that you can use them again" align:#left
		label lab6_03 "later." align:#left offset:[0,-5]
	)

	rollout TreeHelp_Window_7 "misc notes:"
	(
		label lab7_00 "The branch positioning routines used in this script were inspired, in part, by code written by " align:#left offset:[0,-5]
		label lab7_01 "M. Wengenroth, ilumi GbR, Interactive and J. Curtis." align:#left offset:[0,-5]
		label lab7_02 ""
		label lab7_03 "You can only generate one tree at a time. When you start a new tree, you can no longer" align:#left
		label lab7_04 "edit connections or generate a mesh for any pre-existing trees. So,  do not start a new tree until" align:#left offset:[0,-5]
		label lab7_05 "you are completely satisfied with the current one." align:#left offset:[0,-5]
		label lab7_06 ""
		label lab7_07 "During the editting of the branches, you can NOT reassign a branch to a different location." align:#left
		label lab7_08 "It will be connected to the branch it was originally parented to. So while you can move the branch" align:#left offset:[0,-5]
		label lab7_09 "about the screen, it will STILL be connected to its original parent." align:#left offset:[0,-5]
		label lab7_10 ""
		label lab7_11 "Branch to branch connections (i.e., one to one connections) are made by connecting the nearest" align:#left
		label lab7_12 "vertices on each mesh. Branch to two branch connections are formed by connecting half of each" align:#left offset:[0,-5]
		label lab7_13 "branch to half of each other branch in the connection. The vertices are connected in such a " align:#left offset:[0,-5]
		label lab7_14 "manner as to minimize the total edge length for each branch to parent branch connection. As" align:#left offset:[0,-5]
		label lab7_15 "such, you can rotate branches or move a branch's vertices, but you can NOT add new vertices" align:#left offset:[0,-5]
		label lab7_16 "to a branch (e.g., meshsmooth) or change the vertex order (e.g., mirror the mesh)." align:#left offset:[0,-5]
		label lab7_17 ""
		label lab7_18 "A tree must be completed in the same MAX session that it was started. All of the information" align:#left offset:[0,-5]
		label lab7_19 "regarding the branches and connections are stored in memory, so they're only available at the" align:#left offset:[0,-5]
		label lab7_20 "time the tree is being created/editted." align:#left offset:[0,-5]
		label lab7_21 ""
		label lab7_22 "The connection formed when two branchs of vastly different size are connected to a parent branch" align:#left offset:[0,-5]
		label lab7_23 "can often be made better by selected the end vertices of the smaller branch and using scale to" align:#left offset:[0,-5]
		label lab7_24 "spread them further apart (i.e., make the ends of both branches more similar in size)." align:#left offset:[0,-5]
		label lab7_25 ""
		label lab7_26 "Sub-branches and connections are linked to their parent branches. As such, you can rotate and " align:#left offset:[0,-5]
		label lab7_27 "move the parent branch and have the subordinate meshes move appropriately. If you use scale," align:#left offset:[0,-5]
		label lab7_28 "however, you'll quickly notice that the subordinates are also scaled at the same time. To avoid " align:#left offset:[0,-5]
		label lab7_29 "this, select the first branch you don't want to have scaled and disable inherit scale (see MAX" align:#left offset:[0,-5]
		label lab7_30 "manuals for details). NOTE: the branches are parented to each other, not to the connections. So" align:#left offset:[0,-5]
		label lab7_31 "you should change the inheritance for a branch, not a connection." align:#left offset:[0,-5]
		label lab7_32 ""
		label lab7_33 "Once you've collapsed the tree to a mesh, you can use meshsmooth, relax or optimize to further" align:#left offset:[0,-5]
		label lab7_34 "edit your tree. Care should be taken, however, so that the applied texture coordinates are not" align:#left offset:[0,-5]
		label lab7_35 "lost or invalidated (i.e., screwed up)." align:#left offset:[0,-5]
		label lab7_36 ""
		label lab7_37 "When \"Generate branches\", \"Generate connections\", or \"Generate Missing Connections\" are" align:#left offset:[0,-5]
		label lab7_38 "pressed, the command panel is set to the create panel. This is done to avoid the modify panel being " align:#left offset:[0,-5]
		label lab7_39 "active during the building routines. If it is active, it is continuously updated which severely slows " align:#left offset:[0,-5]
		label lab7_40 "down the creation process." align:#left offset:[0,-5]
		label lab7_41 ""
		label lab7_42 "You can only generate leaves before a tree's branches have been collapsed." align:#left offset:[0,-5]
		label lab7_43 ""
		label lab7_44 "After a tree's branches have been collapsed, each of the leaf nodes is parented to the" align:#left offset:[0,-5]
		label lab7_45 "collapsed mesh. Prior to the collapse, each leaf node is parented to the corresponding branch." align:#left offset:[0,-5]
	)

	rollout g_TM_roGreenThumbCentral "Green Thumb Central"
	(
		edittext Treename "Name:" pos:[ 10, 5 ]  text:g_TreeName FieldWidth:175 
		on Treename entered val do g_TreeName = val

		spinner  Seed_ "Seed:" pos:[ 250, 5 ] range:[0,99999,g_RandomSeed] type:#integer fieldwidth:42  align:#left
		on Seed_ changed num do g_RandomSeed = num

		group "Detail" 
		(
	 		radiobuttons smoothNess labels:#( "Very high     ", "High     ", "Medium     ", "Low     ", "Very low" ) default:g_AngleIndex
		)
 		on smoothNess changed val do g_AngleIndex = val

		button make_now "Generate Branches" width:150 pos:[ 10, 78 ]
		on make_now pressed do
		(
			g_TreeMesh = undefined
			seed g_RandomSeed
			TreeBuild()
		)
		
		checkbutton CreateConnections "Generate connections" width:150 pos:[ 210, 78 ]
		on CreateConnections changed state do
		(
			if( state == on ) then 
			(
				--
				-- Do it and pop button back up
				--
				ConnectionMakeAll()
				CreateConnections.checked = false
			)
		)

		button MakeLeaves "Generate Leaves" width:150 pos:[ 10, 105 ] 
		on MakeLeaves pressed do
		(
			g_LeafMesh = undefined
			LeafMakeNodes()
		)

		button CollapseTree "Collapse Branches" width:150 pos: [ 210, 105 ]
		on CollapseTree pressed do 
		(
			g_TreeMesh = TreeCollapseToMesh()
			if( g_TreeMesh != undefined ) then
			(
				g_TreeMesh.name = uniqueName TreeName.text
			)
		)
		
		button CollapseLeaves "Collapse Leaves" width:150 pos:[ 10, 132] enabled:g_bMax4
		on CollapseLeaves pressed do
		(
			g_LeafMesh = LeafCollapseToMesh()
			if( g_LeafMesh != undefined ) then
			(
		 		g_LeafMesh.name = uniqueName ( TreeName.text + "_Leaves" )

				--
				-- Parent to the tree mesh
				--
				if( LocalIsValidNode g_TreeMesh ) then
				(
					g_LeafMesh.parent = g_TreeMesh
				)
				else
				(
					--
					-- Parent to the first branch
					--
				 	if ( LocalIsValidNode g_Branches[ 1 ] ) then
						g_LeafMesh.parent = g_Branches[ 1 ]
				)
			)
		)

		button help "Help me" width:350 
		on help pressed do
		(
			try( closeRolloutFloater g_TM_dlgHelp ) catch( )

			g_TM_dlgHelp = newRolloutFloater "What the ???? (Tree Maker Help)" 515 600
			addRollout TreeHelp_Window_1 g_TM_dlgHelp
			addRollout TreeHelp_Window_2 g_TM_dlgHelp rolledup:true
			addRollout TreeHelp_Window_3 g_TM_dlgHelp rolledup:true
			addRollout TreeHelp_Window_4 g_TM_dlgHelp rolledup:true
			addRollout TreeHelp_Window_5 g_TM_dlgHelp rolledup:true
			addRollout TreeHelp_Window_6 g_TM_dlgHelp rolledup:true
			addRollout TreeHelp_Window_7 g_TM_dlgHelp rolledup:true
		)
	)

	rollout g_TM_roBranchOptions "Branch Options"
	(
		label tl1 "Trunk Length:............................................................................." pos:[ 5, 5 ] 
	   	spinner Size "" range:[1,10000,g_TrunkLength] type:#float scale:1.0 fieldwidth:50 pos: [ 305, 5 ]
		on Size changed val do g_TrunkLength = val

		label bt1 "Branch radius (percent of branch length):.................................................." align:#left pos:[ 5, 25 ]
	   	spinner Branch_thick "" range:[1, 100, g_ThickNess] type:#float scale:.1 fieldwidth:50 align:#left pos:[ 305, 25 ]
		on Branch_thick changed val do g_Thickness = val

		label ml1 "Minimum branch length (percent of trunk length):................................................" align:#left pos:[ 5, 45 ]
	   	spinner min_Length "" range:[1, 100, g_BranchMinLen] scale:1.0 fieldwidth:50 align:#left pos:[ 305, 45]
		on min_Length changed val do g_BranchMinLen = val
	   	
		label ad1 "Angle between branches (in degrees):............................................................" align:#left pos:[ 5, 65 ]
		spinner angle_div "" range:[0, 180, g_BranchAngle * 2] scale:1.0 fieldwidth:50 align:#left pos:[ 305, 65 ]
		on angle_div changed val do g_BranchAngle = val / 2.
	
		label ch1 "Randomness (as a percent):.........................................................................." align:#left pos:[ 5, 85 ]
		spinner Chance "" range:[1, 100, g_Randomness] type:#float fieldwidth:50 scale:.1 align:#left pos:[ 305, 85 ]
		on Chance changed val do g_Randomness = val

		label scA "Branch A size (percent of parent size):............................................................" align:#left pos:[ 5, 105 ]
		spinner scaledwn_A "" range:[1, 100, ( g_BranchScaleA * 100)] fieldwidth:50 scale:1 align:#right pos:[ 305, 105 ]
		on scaledwn_A changed val do g_BranchScaleA = val / 100.
		
		label scB "Branch B size (percent of parent size):............................................................" align:#left pos:[ 5, 125 ]
		spinner scaledwn_B "" range:[1, 100, ( g_BranchScaleB * 100)] fieldwidth:50 scale:1 align:#left pos:[ 305, 125 ]
		on scaledwn_B changed val do g_BranchScaleB = val / 100.

		label bbd "Branch to branch distance:................................................................" align:#left pos:[ 5, 145 ]
		spinner brnch2brnch "" range:[ 0.1, 10., g_BranchDistance ] type:#float fieldwidth:50 scale:1 align:#left pos:[ 305, 145 ]
		on brnch2brnch changed val do g_BranchDistance = val

		label bsd "Branch number length segments:................................................................" align:#left pos:[ 5, 165 ] 
		spinner brnchLengthSegs "" range:[ 1, 100, g_BranchLenSegs ] type:#integer fieldwidth:50 scale:1 align:#left pos:[ 305, 165 ]
		on brnchLengthSegs changed val do g_BranchLenSegs = val
		
		label fl1 "Flare bottom of trunk (to simulate start of roots):................................................" align:#left pos:[ 5, 185 ]
		checkbox rt "" checked:g_bTreeRoots align:#left pos:[ 354, 185 ]
		on rt changed val do g_bTreeRoots = val
	)

	rollout g_TM_roConnectionTools "Tree Tools"
	(
		button slctDescendants "Select Subbranches" width:350
		on slctDescendants pressed do
		(
			setWaitCursor
			for j in selection do
			(
				selectmore j.children				
			)
			setArrowCursor
		)

		button regMissCnnct "Generate missing connections" width:350
		on regMissCnnct pressed do
		(
			ConnectionMakeAll()
		)

		button regSelCnnct "Regenerate selected connections" width:350
		on regSelCnnct pressed do 
		(
 			for j in selection.count to 1 by -1 do
 			(
				obj = selection[ j ]

 				--
 				-- Check to see if [i] is actually a connection
 				--
 				for i in g_Connections do
 				(
 					if( ( LocalIsValidNode i.connect ) and ( i.connect == obj ) ) then
 					(
 						delete obj
 						i.Connect = ConnectionMake1to2Mesh i.trunk i.branch1 i.branch2 i.angleInc
 					)
 				)
			)
		)

		checkbutton DeleteConnections "Delete Connections" width:350
		on DeleteConnections changed state do 
		(
			if ( state == on ) then 
			(
				setWaitCursor()
				for i in g_Connections do 
				(
					try
					(
						delete i.connect					
						i.connect = undefined
					) catch( )					
				)
				setArrowCursor()

				--
				-- Pop the button back up
				--
				DeleteConnections.checked = false
			)
		)

		button flipSelCnnct "Flip selected connections" width:350
		on flipSelCnnct pressed do
		(
 			for i in selection.count to 1 by -1 do
 			(
				obj = selection[ i ]

				--
				-- Check to see if [i] is actually a connection
				--
				for j in g_Connections do
				(
					if( ( LocalIsValidNode j.connect ) and ( j.connect == obj ) ) then
					(
						delete obj

						--
						-- Flip the connections
						--
						swap j.branch1 j.branch2
						j.Connect = ConnectionMake1to2Mesh j.trunk j.branch1 j.branch2 j.angleInc
					)
				)
			)
		)

		button slctEnds "Select Branch Ends" width:350
		on slctEnds pressed do
		(
			--
			-- First deselect everything
			--
			deselect $*

			--
			-- Now select all branches that do NOT have children. 
			-- (these are the end branches)
			--
			for i in g_Branches do
			(
				if( LocalIsValidNode i ) then
				(
					--
					-- The branch is valid, lets see if ANY of
					-- its children are
					--
					bFoundBranch = false
					for j in 1 to i.children.count do
					(
					 	if( LocalIsValidNode i.children[ j ] ) then
							bFoundBranch = true
					)

					if( not bFoundBranch ) then
					(
						selectmore i
					)
				)
			)
		)
	)

	rollout g_TM_roLeafOptions "Leaf Options"
	(  
		label ls "Leaf size:............................................................................................................" align:#left pos:[ 5, 5 ] 
		spinner leafsize "" range:[1, 100, g_LeafSize] scale:1.0 fieldwidth:50 align:#left pos:[305,5]
		on leafsize	changed val do g_LeafSize = val

		label lr "Leaf size randomization (in percent):..................................................................................." align:#left pos:[ 5, 25 ]
		spinner leafSizeRand "" range:[0, 100, g_LeafSizeRandom] type:#integer fieldwidth:50 scale:1 pos:[ 305, 25]
		on leafSizeRand changed val do g_LeafSizeRandom = val

		label nl "Number of leaves per twig:................................................................" align:#left pos:[ 5, 45 ]
		spinner num_leaves "" range:[0, 10000, g_LeafNum] type:#integer fieldwidth:50 scale:1 pos:[ 305, 45]
		on num_leaves changed val do g_LeafNum = val

		label nlr "Leaf number randomization (in percent):..................................................................................." align:#left pos:[ 5, 65 ]
		spinner leafNumRand "" range:[0, 100, g_LeafNumRandom] type:#integer fieldwidth:50 scale:1 pos:[ 305, 65]
		on leafNumRand changed val do g_LeafNumRandom = val

		label vp "Percent of leaves to show in viewports:....................................................................................." align:#left pos:[ 5, 85 ]
		spinner viewPercent "" range:[0, 100, g_LeafViewPercent] type:#integer fieldwidth:50 scale:1 pos:[ 305, 85] 
		on viewPercent changed val do g_LeafViewPercent = val

		label lsr "Leaf spread radius:........................................................................................................." align:#left pos:[ 5, 105 ]
		spinner SpreadRadius "" range:[0, 1000000, g_LeafSpread] type:#integer fieldwidth:50 scale:1 pos:[ 305, 105]
		on SpreadRadius changed val do g_LeafSpread = val

		group "Leaf Type" 
		(
			radioButtons lt default:(g_LeafType+1) labels:#( "Triangle        ", "Cube            ", "Special              ", "Facing*", "Constant*", "Tetra", "SixPoint", "Sphere" ) columns:3 
			label ltw "* these types do NOT accurately collapse into a single mesh."
		)
		on lt changed state do
		(
			g_LeafType = state - 1
		)
	)

	rollout g_TM_roLeafOptionsVIZ "Leaf Options"
	(
		label ls "Leaf size:............................................................................................................" align:#left pos:[ 5, 5 ] 
		spinner leafsize "" range:[1, 100, g_LeafSize] scale:1.0 fieldwidth:50 align:#left pos:[305,5]
		on leafsize	changed val do g_LeafSize = val

		label lr "Leaf size randomization (in percent):..................................................................................." align:#left pos:[ 5, 25 ]
		spinner leafSizeRand "" range:[0, 100, g_LeafSizeRandom] type:#integer fieldwidth:50 scale:1 pos:[ 305, 25]
		on leafSizeRand changed val do g_LeafSizeRandom = val

		label nl "Number of leaves per twig:................................................................" align:#left pos:[ 5, 45 ]
		spinner num_leaves "" range:[0, 10000, g_LeafNum] type:#integer fieldwidth:50 scale:1 pos:[ 305, 45]
		on num_leaves changed val do g_LeafNum = val

		label nlr "Leaf number randomization (in percent):..................................................................................." align:#left pos:[ 5, 65 ]
		spinner leafNumRand "" range:[0, 100, g_LeafNumRandom] type:#integer fieldwidth:50 scale:1 pos:[ 305, 65]
		on leafNumRand changed val do g_LeafNumRandom = val

		label lsr "Leaf spread radius:........................................................................................................." align:#left pos:[ 5, 85 ]
		spinner SpreadRadius "" range:[0, 1000000, g_LeafSpread] type:#integer fieldwidth:50 scale:1 pos:[ 305, 85]
		on SpreadRadius changed val do g_LeafSpread = val

		group "Leaf Type" 
		(
			radioButtons lt default:(g_LeafType+1) labels:#( "Rectangular        ", "Tetra            " ) columns:2 
		)
		on lt changed state do
		(
			g_LeafType = state - 1
		)
	)

	rollout g_TM_roTreeIO "Load and save Tree Maker settings"
	(
		button btnLoad "Load settings" width:350
		on btnLoad pressed do
		(
			sFileName = getOpenFileName caption:"Load settings" filename:"*.txt" types:"Tree Maker settings(*.txt)|(*.txt)"
			if( ( SettingsLoadDataFile sFileName ) == true ) then
			(
				--
				-- Reinitialize the floater so that it uses the new values
				--
				p = g_TM_dlgMain.pos
				InitializeFloater()
				g_TM_dlgMain.pos = p
			)
		)

	 	button btnSave "Save settings" width:350
		on btnSave Pressed do
		(
		 	sFileName = getSaveFileName caption:"Save settings" filename:"*.txt" types:"Tree Maker settings(*.txt)|(*.txt)"

			if( ( getFileNameType sFileName ) == "" ) then
				sFileName += ".txt"

		 	SettingsSaveDataFile sFileName
		)
	)
 
	rollout g_TM_roAbout "About"
	(  
		Group ""
		(
			label lab_1 "Tree Maker version 5.0"
			label lab_2 "Copyright: 2002 Shawn Lewis" offset:[0,-5]
		)
	)

	--
	-- Initalize the floater
	--
	InitializeFloater()
)

