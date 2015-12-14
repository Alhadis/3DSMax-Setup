MacroScript BoxToChamferBox
	category:	"Mutations"
	buttonText:	"Box to ChamferBox"
	tooltip:	"Box to ChamferBox"
(
	on Execute do(
		
		function convertBox node = (

			if(classOf node == box) then(
				local length		= node.length;
				local width			= node.width;
				local height		= node.height;
				local lengthsegs	= node.lengthsegs;
				local widthsegs		= node.widthsegs;
				local heightsegs	= node.heightsegs;
				local mapCoords		= if(node.mapCoords) then 1 else 0;
				local realWorld		= node.realWorldMapSize;
				
				local position		= node.position;
				local rotation		= node.rotation;
				local scale			= node.scale;
				local pivot			= node.pivot;
				local material		= node.material;
				local parent		= node.parent;
				
				local output		= ChamferBox	length:length				\
													width:width					\
													height:height				\
													mapCoords:mapCoords			\
													fillet:0.5					\
													Length_Segments:lengthsegs	\
													Width_Segments:widthsegs	\
													Height_Segments:heightsegs	\
													realWorldMapSize:realWorld;
				output.position		= position;
				output.rotation		= rotation;
				output.scale		= scale;
				output.material		= material;
				output.parent		= parent;
				delete node;
				return output;
			)
		)
		
		for obj in selection do(
			convertBox obj
		)



	)
)