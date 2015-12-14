--	Selects every Nth vertex in the shape's selected splines.
function selectNthPoint obj nth keep:false = (
	local splines	=	getSplineSelection obj;
	for s = 1 to (splines.count) do(
		local sel		=	#();
		local knotCount	=	numKnots obj s;
		local skip		=	nth;
		for k = 1 to knotCount do(
			skip -= 1;
			if(skip <= 0) then(
				skip	=	nth;
				append sel k;
			)
		)
		setKnotSelection obj s sel keep:keep
	)
	
)

selectNthPoint $ 2 keep:false