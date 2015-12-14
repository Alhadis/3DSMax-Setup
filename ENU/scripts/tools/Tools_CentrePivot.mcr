MacroScript CentrePivot
	category:"Tools"
	tooltip:"Anchors pivot to selection centre"
	buttonText:"Centre Pivot"
(
	
	-- Returns the midpoint between every value in an Array
	function getMidpoint a = (
		local sorted	= sort a;
		local length	= sorted.count;

		(sorted[1] + sorted[length]) / 2;
	)

	-- Returns the average coordinate as a Point3 value
	function findAverage a = (
		local x	= #();
		local y	= #();
		local z	= #();
		
		for i = 1 to a.count do(
			x[i]	= a[i][1];
			y[i]	= a[i][2];
			z[i]	= a[i][3];
		)
		x	= getMidpoint x;
		y	= getMidpoint y;
		z	= getMidpoint z;
		
		Point3 x y z
	)
	
	
	/*===========================================================*/
	/*	EDITABLE SPLINE : VERTEX LEVEL
	/*===========================================================*/
	
		-- Runs through the splines and stores the vertex position of each selected integer
		function parseKnots shape spline indices = (
			local output	= #();
			for i in indices do(
				knotPos		= in coordsys #world (getKnotPoint shape spline i)
				output		= append output knotPos
			)
			output;
		)

		-- Runs through the shape's splines and outputs an array of Point3 coordinates for each selected index.
		function getKnotCoords shape = (

			-- Gather the selected vertices of each spline in a seperate array index
			local splines	= #();
			for i = 1 to numSplines shape do
				splines[i] = getKnotSelection shape i

			local coords	= #();
			for i = 1 to splines.count do(
				knotPos = parseKnots shape i splines[i];
				coords	= join coords knotPos
			)
			coords;
		)
		
		
		function getSegmentCoords shape = (
			
		)
		
		function getSplineCoords shape = (
			
		)
		
		-- Returns the centre of the Spline's subobject selection, dependent on currently active level
		function getSplineCentre shape = (
			local coords = #();
			
			if(Filters.Is_EditSplineSpecifyLevel #{2})		then	coords	=	getKnotCoords shape;
			--else if(Filters.Is_EditSplineSpecifyLevel #{3})	then	coords	=	getSegmentCoords shape;
			--else if(Filters.Is_EditSplineSpecifyLevel #{4})	then	coords	=	getSplineCoords shape;
			
			if(coords.count < 1)
				then	shape.center
				else	findAverage coords;
		)
		
		
	--	Bootstrap
	on Execute do(
		if(selection.count > 0) then(
			
			-- Editable Splines
			if(Filters.Is_EditSpline()) then
				$.pivot = getSplineCentre $;
			
			
			else CenterPivot $
		)
	)
)