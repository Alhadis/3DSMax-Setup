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

	19 August 2009, John Gardner
	Tweaked the feedback mechanisms to provide better clarity for the result's Delta angles
	
	14 January 2011, John Gardner
	Repaired the missing restoreSnaps() mechanism; enhanced feedback.
	
	3rd February 2011, John Gardner
	Added abs() calls to return only positive numbers.
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
	global measureModeActive;
	
	--	Restores the snap mode that was setup before the command was invoked
	fn restoreSnaps = (
		global CurSnapModeActive, CurSnapModeType;
		snapMode.Active	=	CurSnapModeActive
		if(snapMode.type == undefined) do snapMode.type = #3D -- I have seen some old files where the mode was undefined, this is for security.
		snapMode.type	=	if(CurSnapModeType != undefined) then CurSnapModeType else #3D;
	)

	on isChecked do(
		global measureModeActive;
		measureModeActive == true;
	)
	
	on Execute do(
		local pt1, pt2, str1, str2, str3, str4, str5, strDist, dist,  strDx, strDy, strDz;
		global CurSnapModeActive, CurSnapModeType, measureModeActive;
		
		measureModeActive	=	true;
		
		/* Start localisation */
		str1	= "Dist:"
		str2	= "Delta X:"
		str3	= "Delta Y:"
		str4	= "Delta Z:"
		str5	= "Cancelled"
		div		= "====================";
		/* End localisation */


		--	Saves the snap that was used before the command was invoked
		CurSnapModeActive	=	snapMode.Active
		CurSnapModeType		=	snapMode.type

		--	Activate the snap mode
		snapMode.Active		=	true
		if(CurSnapModeActive == false) do snapMode.type = #3d -- If no snap was defined, assume that a default to per-vertex would be good
		
		--	Pick a first point
		pt1	=	pickpoint snap:#3d
		if(classof pt1 == point3) then(
			pt2	=	pickpoint snap:#3d rubberband:pt1

			if(classof pt2 == point3) then(
				dist	=	(distance pt1 pt2)
				strDist	=	units.formatValue dist

				strDx	=	units.formatValue (abs((((pt2.x-pt1.x) * 1000) as integer) / 1000.0));
				strDy	=	units.formatValue (abs((((pt2.y-pt1.y) * 1000) as integer) / 1000.0));
				strDz	=	units.formatValue (abs((((pt2.z-pt1.z) * 1000) as integer) / 1000.0));
				restoreSnaps();

				--	Supply Listener Feedback
				clearListener();
				replacePrompt((str1 + " " + strDist)+ (" "+str2+" " + strDx) + (" "+str3+" " + strDy) + (" "+str4+" " + strDz));
				print(div+"\n"+(str1+"\t\t"+strDist) + "\n\n" + (str2 + "\t" + strDx) + "\n" + (str3 + "\t" + strDy) + "\n" + (str4 + "\t" + strDz) + "\n"+div)

				--	Display enhanced feedback window
				global measureResults;
				try(destroyDialog measureResults) catch();
				createDialog measureResults width:373 height:320 modal:false escapeEnable:true;
				measureResults.distVal.text	=	strDist;
				measureResults.delXVal.text	=	strDx;
				measureResults.delYVal.text	=	strDy;
				measureResults.delZVal.text	=	strDz;
			)
			
			--	The user cancelled
			else(
				restoreSnaps();
				displayTempPrompt str5 1000
			)
		)
		
		--	User cancelled
		else(
			restoreSnaps();
			displayTempPrompt str5 1000
		)
		
		measureModeActive	=	false;
	)
)