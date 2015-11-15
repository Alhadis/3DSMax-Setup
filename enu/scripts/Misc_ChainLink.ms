if(selection.count > 0) then(
	local lastObj		= undefined;
	local currentObj	= undefined;
	for i = 1 to selection.count do(
		currentObj	= selection[i];
		if(lastObj != undefined) then(
			currentObj.parent = lastObj;
		)
		lastObj = currentObj;
	)
)