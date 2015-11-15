MacroScript ToggleFloorPlan
	category: "Tools"
	buttonText: "Toggle Floor Plan Display"
	tooltip: "Toggle Floor Plan Display"
	icon: #("CustomIcons", 18)
(
	--	Retrieves a LayerProperties object for the targeted floor plan
	global getFloorPlan;
	fn getFloorPlan = (
		LayerManager.getLayerFromName "Floor Plan"
	)


	--	Returns a reference to the overlaying building object
	global getBuildingNode;
	fn getBuildingNode = (
		global buildingNode;
		if(buildingNode != undefined)
			then	buildingNode
			else	getNodeByName "Building";
	)



	on isEnabled do (getFloorPlan() != undefined);
	on isChecked do(
		local plan	=	getFloorPlan();
		(plan != undefined and (not plan.isHidden));
	);
	
	on Execute do with undo on(
		local plan	=	getFloorPlan();
		
		if(plan != undefined) then(
			local hidden	=	not(plan.ishidden);
			
			--	If Building Object exists in the scene, toggle See Through property
			local building	=	getBuildingNode();
			if(isKindOf building Node and isDeleted building != true) then
				if(not hidden) then(
					building.xray	=	on;
					if(building.showVertexColors)
						then building.showVertexColors	=	off;
				)
				else(
					building.xray	=	off;
					if(building.vertexColorsShaded) then
						building.showVertexColors	=	on;
				)
			
			--	If revealing floor plan, disable wireframe mode in current viewport
			if(hidden != true and viewport.isWire()) then max wire smooth
			
			plan.ishidden	=	hidden;
		)
	)
)