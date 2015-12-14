--=====================================================================================================
/*		REFERENCE IMAGE LOADING	*/
--=====================================================================================================	

--	Returns the rotation needed for an object to face a viewer in an isometric viewport
global rotationFromViewport;
function rotationFromViewport = (
	case viewport.getType() of(
		#view_left:		(quat 0.5 -0.5 -0.5 0.5)
		#view_right:	(quat -0.5 -0.5 -0.5 -0.5)
		#view_front:	(quat 0.707107 0 0 0.707107)
		#view_back:		(quat 0 -0.707107 -0.707107 0)
		#view_top:		(quat 0 0 0 1)
		#view_bottom:	(quat -1 0 0 0)
		default:		(quat 0 0 0 1)
	)
)

--	Custom Attributes: Image Adjustment Sliders
global imgAdjustments;
imgAdjustments	=	attributes imageAdjustments(
	parameters main rollout:params(
		brightness	type:#float	ui:brightSld default:0 animatable:true
		contrast	type:#float	ui:contrastSld default:0 animatable:true
	)
	rollout params "Tonal Adjustments"(
		slider brightSld "Brightness:" pos:[6,9] width:156 height:44 range:[-100,100,0] type:#float orient:#horizontal ticks:10
		spinner brightSpn "" pos:[105,9] width:50 height:16 enabled:true range:[-100,100,0]
		
		slider contrastSld "Contrast:" pos:[6,72] width:156 height:44 range:[-100,100,0] type:#float orient:#horizontal ticks:10
		spinner contrastSpn "" pos:[106,72] width:50 height:16 enabled:true range:[-100,100,0]


		--	Connect sliders with type-in fields
		on brightSld changed v do		brightSpn.value		=	v;
		on brightSpn changed v do		brightSld.value		=	v;
		on contrastSld changed v do		contrastSpn.value	=	v;
		on contrastSpn changed v do		contrastSld.value	=	v;


		--	Foreground Flagging
		on brightSld	buttonDown	do flagForeground $ true;
		on brightSld	buttonUp	do flagForeground $ false;
		on brightSpn	buttonDown	do flagForeground $ true;
		on brightSpn	buttonUp	do flagForeground $ false;

		on contrastSld	buttonDown	do flagForeground $ true;
		on contrastSld	buttonUp	do flagForeground $ false;
		on contrastSpn	buttonDown	do flagForeground $ true;
		on contrastSpn	buttonUp	do flagForeground $ false;
	)
)