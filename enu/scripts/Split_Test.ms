function extractSegment shape = (

	-- Temporary segments that're cloned and snapped off main shape to analyse
	local phantasm	= copy shape;
	
	print(phantasm);
)

function isolateSegment shape = (
	-- The list of Segments to split
	local knots		= #();
		
	for i = 1 to numSplines shape do(
		offset		= 0;
		segments	= getSegSelection shape i;
		
		splits		= #();
		for j in segments do(
			splits	= append splits (refineSegment shape i (j+offset) 0.5);
			offset	+= 1;
		)
		knots[i]	= splits
	)
	print knots #noMap
)

isolateSegment $