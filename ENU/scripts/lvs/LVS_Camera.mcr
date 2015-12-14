MacroScript Camera
	category: "LVS"
	buttonText: "Camera"
	toolTip: "Camera"
(
	on Execute do with undo off(
		global lvs;
		if(cameras.count > 0) then
			if(lvs != undefined)
				then(
					--	Check if we're already in a Camera viewport
					if(viewport.getType() == #view_camera) then(
						hideByCategory.cameras	=	false;
						actionMan.executeAction 0 "40247"
					)
					--	Otherwise, just make the normal switch
					else	lvs.switch #view_camera;
				)
				else	actionMan.executeAction 0 "40068";
	)
)