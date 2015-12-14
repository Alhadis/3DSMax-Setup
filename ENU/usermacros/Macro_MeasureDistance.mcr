-- Macro Scripts File
-- Created:  Sep 06 2001
-- Author:   Alexander Esppeschit Bicalho


/*
Revision History
	13 sept 2001; Pierre-Felix Breton
	added snap mode toggle
	changed the cancellation prompt to be shown for 1 second
	
	19 sept 2001; Pierre-Felix Breton
	removed snap mode toggle

	24 mai 2003; Pierre-Felix Breton
	Added to 3ds MAX 6
	
	12 dec 2003, Pierre-Felix Breton, 
	added product switcher: this macro file can be shared with all Discreet products

	UPDATE 19/08/2009 John Gardner
	Tweaked the feedback mechanisms to provide better clarity for the result's Delta angles
*/

-- Macro Script to measure the distance between 2 points
--***********************************************************************************************
-- MODIFY THIS AT YOUR OWN RISK

macroScript two_point_dist
enabledIn:#("max", "viz", "vizr") --pfb: 2003.12.12 added product switch
            category:"Tools" 
            internalcategory:"Tools" 
            tooltip:"Measure Distance..." 
            buttontext:"Measure Distance..."
			Icon:#("Helpers", 5)
(

	local pt1, pt2, str1, str2, str3, str4, str5, strDist, dist,  strDx, strDy, strDz

	local CurSnapModeActive, CurSnapModeType
	/* Start localization */
	

	fn RestoreSnaps = 
	(
			-- restores the snap mode that was setup before the command was invoked	
			snapMode.Active = CurSnapModeActive
			if snapMode.type == undefined do snapMode.type = #3D -- I have seen some old files where the mode was undefined, this is for security.
			snapMode.type = CurSnapModeType
	)
		
	str1	= "Dist:"
	str2	= "Delta X:"	-- there are leading and a trailing spaces
	str3	= "Delta Y:"	--	*	UPDATE 19/08/2009: Not anymore, mate ~ John
	str4	= "Delta Z:"
	str5	= "Canceled"
	div		= "====================";
	
	/* End localization */

	-- saves the snap mode that was used before the command was invoked
	--CurSnapModeActive = snapMode.Active
	--CurSnapModeType = snapMode.type

	-- activate the snap mode
	--snapMode.Active = True
	--if CurSnapModeActive == false do snapMode.type = #3d --if no snap was defined, assume that a default to per vertex would be good
		
	-- picks a first point
	pt1 = pickpoint snap:#3d
	
	if classof pt1 == point3 then
	(
		pt2 = pickpoint snap:#3d rubberband:pt1
		if classof pt2 == point3 then
		(
			dist = (distance pt1 pt2)
			strDist =  units.formatValue dist
	        strDx = units.formatValue ((((pt2.x-pt1.x) * 1000) as integer) / 1000.0)
			strDy = units.formatValue((((pt2.y-pt1.y) * 1000) as integer) / 1000.0)
			strDz = units.formatValue((((pt2.z-pt1.z) * 1000) as integer) / 1000.0)
			--RestoreSnaps()
			clearListener();
			replacePrompt((str1 + " " + strDist)+ (" "+str2+" " + strDx) + (" "+str3+" " + strDy) + (" "+str4+" " + strDz));
			print(div+"\n"+(str1+"\t\t"+strDist) + "\n\n" + (str2 + "\t" + strDx) + "\n" + (str3 + "\t" + strDy) + "\n" + (str4 + "\t" + strDz) + "\n"+div)
		)
		else 
		(
			--RestoreSnaps() 	
			displayTempPrompt str5 1000 --the user cancelled
		)
	)
	else 
	(
		--RestoreSnaps() 	
		displayTempPrompt str5 1000 --the user cancelled
	)
)