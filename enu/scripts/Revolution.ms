/* FILE DEPRECATED: Refer to "Tools_CentrePivot.mcr" for building the working script */

-- Returns the midpoint between every value in an Array
function getMidpoint a = (
	local sorted	= sort a;
	local length	= sorted.count;

	return ((sorted[1] + sorted[length]) / 2);
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
	
	return Point3 x y z
)


-- Runs through the splines and stores the vertex position of each selected integer
function parseKnots shape spline indices = (
	local output	= #();
	for i in indices do(
		knotPos		= in coordsys #world (getKnotPoint shape spline i)
		output		= append output knotPos
	)
	return output;
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
	return coords;
)

function revolution shape = (
	local coords	= getKnotCoords shape;
	print (findAverage coords);
)

$.pivot = revolution $