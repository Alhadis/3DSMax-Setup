MacroScript FreeSpline
	category:"Tools"
	tooltip:"Freehand Spline"
	buttonText:"Draw Freehand Spline"
	Icon:#("CustomIcons", 1)
(
	global FreehandSpline;
	struct FreehandSpline(
		oldPos				=	undefined,
		newSpline			=	undefined,
		setSecondKnot		=	undefined,
		spacing				=	7,
		
		--	Inserts the next knot into the newly created spline.
		fn drawNext pos nextPos = (
			if(oldPos == undefined)
				then oldPos	=	nextPos;
			
			if(distance pos oldPos > spacing) then(
				if(setSecondKnot)
					then	addKnot newSpline 1 #smooth #curve pos;
					else(
						setKnotPoint newSpline 1 2 pos;
						setSecondKnot	=	true;
					)
				
				oldPos	=	pos;
				updateShape newSpline
			)
		),
		
		
		fn start pos:unsupplied closed:#auto = (
			oldPos		=	if(pos == unsupplied) then pickPoint() else pos;
			newSpline	=	splineShape();
			
			if(oldPos == #RightClick) then
				delete newSpline;
			else(
				select newSpline;
				newSpline.pos	=	oldPos
				addNewSpline newSpline;
				addKnot newSpline 1 #smooth #curve oldPos;
				addKnot newSpline 1 #smooth #curve oldPos;
				setSecondKnot	=	false;
				pickPoint mouseMoveCallback:#(drawNext, oldPos);
				
				if(closed == #always or (closed == #auto and querybox "Close Spline?" title:"Free Spline")) then(
					close newSpline 1
					updateshape newSpline
				)
				select newSpline
			)
		)
	)
	
	global freeSpline	=	FreehandSpline();
	
	
	on Execute do(
		undo "Freehand Spline" on
			freeSpline.start closed:#never
	)
)