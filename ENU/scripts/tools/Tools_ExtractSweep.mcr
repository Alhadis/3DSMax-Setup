MacroScript ExtractSweep
	category: "Tools"
	buttonText: "Extract Sweep Section"
	tooltip: "Extract Sweep Section"
(
	on Execute do(
		local obj	=	Filters.GetModOrObj();
		
		if(classOf obj == Sweep) then(
			local extract;
			
			--	Custom Section
			if(obj.customShape > 0 and obj.CustomShapeName != undefined) then(
				local nodes	=	#();
				if(maxOps.cloneNodes (GetNodeByName obj.CustomShapeName) cloneType:#instance newNodes:nodes) then
					extract	=	nodes[1];
			)

			--	Built-in Section
			else(
				local s		=	obj[4];
				extract		=	case classOf s.object of(
					Angle:	Angle \
						angle_length:(s.angle_length)						\
						angle_width:(s.angle_width)							\
						angle_thickness:(s.angle_thickness)					\
						angle_syncCornerFillets:(s.angle_syncCornerFillets)	\
						angle_radius:(s.angle_radius)						\
						angle_radius2:(s.angle_radius2)						\
						angle_edgeFillet:(s.angle_edgeFillet);

					Bar:	Rectangle	\
						length:(s.length)				\
						width:(s.width)					\
						Corner_Radius:(s.corner_radius);

					Channel:	Channel	\
						channel_length:(s.channel_length)						\
						channel_width:(s.channel_width)							\
						channel_thickness:(s.channel_thickness)					\
						channel_syncCornerFillets:(s.channel_syncCornerFillets)	\
						channel_radius:(s.channel_radius)						\
						channel_radius2:(s.channel_radius2);
					
					Cylinder:	NGon	\
						radius: s.radius	\
						nSides: 4			\
						circular: true;

					HalfRound:	Arc	\
						radius: s.radius	\
						from: 360.0			\
						to: 180.0			\
						pie: true;
					
					PipeObject:	Donut	\
						radius1:	s.radius	\
						radius2:	(s.radius - s.pipe_thickness);
					
					QuarterRound:	Arc	\
						radius: s.radius	\
						from: 360.0			\
						to: 90.0			\
						pie: true;

					Tee:	Tee	\
						tee_length:		s.tee_length		\
						tee_width:		s.tee_width			\
						tee_thickness:	s.tee_thickness		\
						tee_radius:		s.tee_radius;

					Tube:	WalledRectangle	\
						wrect_length:				s.wrect_length				\
						wrect_width:				s.wrect_width				\
						wrect_thickness:			s.wrect_thickness			\
						wrect_syncCornerFillets:	s.wrect_syncCornerFillets	\
						wrect_radius:				s.wrect_radius				\
						wrect_radius2:				s.wrect_radius2;

					WideFlange:	WideFlange	\
						wide_flange_length:			s.wide_flange_length		\
						wide_flange_width:			s.wide_flange_width			\
						wide_flange_thickness:		s.wide_flange_thickness		\
						wide_flange_radius:			s.wide_flange_radius;
				)
			)


			--	We instantiated a new node successfully
			if(extract != undefined) then(
				
				
			)
		)
	)
)