macroScript ReferenceImage
	category: "Tools"
	buttonText: "Reference Image"
	tooltip: "Reference Image"
(

	on Execute do(
		local img			=	selectBitmap caption:"Choose a Reference Image";
		local addControls	=	false;

		if(img != undefined) then(
			local w		=	img.width;
			local h		=	img.height;
			local file	=	filenameFromPath img.filename;
			
			--	Prepare the Material
			local map						=	BitmapTexture filename:img.filename;
			if(addControls) then	map		=	Color_Correction map:map;
			local mat	=	StandardMaterial name:("REF_" + file) selfIllumAmount:100.0 diffuseMap:map twoSided:true;
			
			--	Create and position newly created Plane
			global rotationFromViewport;
			local size		=	getViewSize();
			local rect		=	Box2 (mapScreenToView [0,0] 0.0) (mapScreenToView size 0.0);
			local obj		=	Plane name:("_Guide - "+file) length:h width:w lengthsegs:1 widthsegs:1 pos:(mapScreenToView (size / 2) 0.0) rotation:(rotationFromViewport()) material:mat isSelected:true;
			
			obj.showFrozenInGray	=	false;
			obj.backfacecull		=	false;
			obj.renderable			=	false;
			
			max tool zoomextents
			viewport.setRenderLevel #smooth
			viewport.setGridVisibility viewport.activeViewport false


			--	Workaround for a stupid bug preventing material from updating in viewports
			local storeMat		=	meditmaterials[1];
			meditmaterials[1]	=	mat;
			
			enableHardwareMaterial meditmaterials[1] true
			showTextureMap meditmaterials[1] true;
			showHWTextureMap meditmaterials[1] true
			
			--	Restore previous material slot
			meditmaterials[1]	=	storeMat;


			--	Add Colour Correction Controls if enabled
			if(addControls) then(
				max modify mode
				global imgAdjustments;
				custAttributes.add obj imgAdjustments;
				
				paramWire.connect2way obj.material.diffuseMap[#Brightness] obj.baseObject.imageAdjustments[#brightness] "brightness" "Brightness";
				paramWire.connect2way obj.material.diffuseMap[#Contrast] obj.baseObject.imageAdjustments[#contrast] "contrast" "Contrast";
			)
		)
	)

)