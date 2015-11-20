macroScript VRayLightLister
enabledIn:#("max") --pfb: 2003.12.12 added product switch
category:"VRay" 
ButtonText:"V-Ray Light Lister"
Icon:#("Lights",7)
(

struct VRayLightListerStruct (GlobalLightParameters, LightInspectorSetup, LightInspectorFloater, LightInspectorListRollout, ShadowPlugins, \
							ShadowPluginsName, maxLightsList, LSLightsList, SkyLightsList, SunLightsList, enableUIElements, \
							LuminairesList, maxLightsRC, CreateLightRollout, UIControlList, DeleteCallback, disableUIElements, \
							LightInspectorListRollout, LLUndoStr, count, lbcount, lightIndex, decayStrings, totalLightCount, \
							miLightsList, getLightProp, setLightProp, setShdProp, getShdProp, fnShadowClass, enableRefreshBtn, \
							mrSkyLightsList, mrSunLightsList, mrSkyPortalLightsList, MRSkyPortal_ShadowSamples, MRSkyPortal_Modes, \
							VRayLightsList, VRayIESLightsList, VRayAmbientLightsList, VRaySunSkyLightsList, yOffset, LineOffset)

global vrayLLister, vrayLListerYOffset
if vrayLLister == undefined or debug == true do vrayLLister = VRayLightListerStruct()

-- Strings for Localization

vrayLLister.decayStrings = #("None","Inverse","Inv. Square")
vrayLLister.LLUndoStr = "LightLister"

local dialogUp = false

-- End Strings

-- Positioning to help localization

vrayLListerYOffset = 0
vrayLLister.yOffset = vrayLListerYOffset
vrayLLister.LineOffset = 0

-- Useful Functions

fn subtractFromArray myArray mySub =
(
	tmpArray = #()
	for i in myArray do append tmpArray i
	for i in mySub do


	(
		itemNo = finditem tmpArray i
		local newArray = #()
		if itemNo != 0 do
		(
			for j in 1 to (itemNo-1) do append newArray tmpArray[j]
			for j in (itemNo+1) to tmpArray.count do append newArray tmpArray[j]
			tmpArray = newArray
		)
	)
	tmpArray
)

fn SortNodeArrayByName myArray =
(
qsort myArray (fn myname v1 v2 = (if v1.name < v2.name then 0 else 1))
myArray
)

fn copyArray array1 = for i in array1 collect i

fn wrapString inString =
(
	local string1In = "\\"
	local string1Out = "\\\\"
	local string2In = "\""
	local string2Out = "\\\""
	local temp_text_string = substituteString inString string1In string1Out
	temp_text_string = substituteString temp_text_string string2In string2Out
	temp_text_string = string2In + temp_text_string + string2In
	temp_text_string -- return value
)

fn disableUIElements array1 = for i in array1 do execute ("maxLightsRollout." + i as string + ".enabled = false")
vrayLLister.disableUIElements = disableUIElements

fn enableRefreshBtn lightobj =
(
	if (vrayLLister.GetLightProp lightObj #useGlobalShadowSettings) == true do
	(
		vrayLLister.LightInspectorSetup.BtnReload.Checked = true
	)
)
vrayLLister.enableRefreshBtn = enableRefreshBtn

fn getLightProp obj prop =
(
	if (isProperty obj prop) and not (isProperty obj #delegate) then
		getProperty obj prop
	else 
		if isProperty obj #delegate then 
			if isProperty obj.delegate prop then
				getProperty obj.delegate prop
			else undefined
		else undefined
)
vrayLLister.getLightProp = getLightProp

fn setLightProp obj prop val =
(
	if (isProperty obj prop) and not (isProperty obj #delegate) then
		setProperty obj prop val
	else
		if isProperty obj #delegate then 
			if isProperty obj.delegate prop then
				setProperty obj.delegate prop val
			else undefined
		else undefined
)
vrayLLister.setLightProp = setLightProp

fn getShdProp obj prop =
(
	if (isProperty obj #shadowGenerator) and not (isProperty obj #delegate) then
		if (isProperty obj.ShadowGenerator prop) do getProperty obj.ShadowGenerator prop
	else 
		if isProperty obj #delegate then 
			if isProperty obj.delegate #ShadowGenerator then
				if (isProperty obj.delegate.ShadowGenerator prop) do getProperty obj.delegate.ShadowGenerator prop
			else undefined
		else undefined
)
vrayLLister.getShdProp = getShdProp

fn setShdProp obj prop val =
(
	if (isProperty obj #shadowGenerator) and not (isProperty obj #delegate) then
		if (isProperty obj.ShadowGenerator prop) do
		(
			setProperty obj.ShadowGenerator prop val
			vrayLLister.enableRefreshBtn obj
		)
	else 
		if isProperty obj #delegate then 
			if isProperty obj.delegate #ShadowGenerator then
				if (isProperty obj.delegate.ShadowGenerator prop) do
				(
					setProperty obj.delegate.ShadowGenerator prop val
					vrayLLister.enableRefreshBtn obj
				)
			else undefined
		else undefined
)
vrayLLister.setShdProp = setShdProp

fn fnShadowClass obj = classof (vrayLLister.getLightProp obj #shadowGenerator)
vrayLLister.fnShadowClass = fnShadowClass

-- Hardcoded shadow plugins to the ones available

	vrayLLister.ShadowPlugins = #(Adv__Ray_Traced, mental_ray_Shadow_Map, Area_Shadows, shadowMap, raytraceShadow, VRayShadow, VRayShadowMap)
	vrayLLister.ShadowPluginsName = #("Adv. Ray Traced", "mental_ray_Shadow_Map", "Area Shadows", "Shadow Map", "Raytrace Shadow", "VRayShadow", "VRayShadowMap")

/* -- uncomment if you want the Blur Shadows
vrayLLister.ShadowPlugins = #(Adv__Ray_Traced, mental_ray_Shadow_Map, Area_Shadows, Blur_Adv__Ray_Traced, shadowMap, raytraceShadow, VRayShadow, VRayShadowMap)
vrayLLister.ShadowPluginsName = #("Adv. Ray Traced", "mental_ray_Shadow_Map", "Area Shadows", "Blur Adv. Ray Traced","Shadow Map", "Raytrace Shadow", "VRayShadow", "VRayShadowMap")
*/
	vrayLLister.MRSkyPortal_ShadowSamples = for i = 1 to 10 collect (2^i) as string
	vrayLLister.MRSkyPortal_Modes = #("Existing", "Envir.", "Custom") -- correspond to mode values of 2, 0, 1

-- Main Function

local CreateLightRollout

fn createLightRollout myCollection selectionOnly:false =
(
	vrayLLister.LightInspectorSetup.pbar.visible = true

	-- Class Definitions
	
	maxLights = #(TargetDirectionallight, targetSpot, Directionallight, Omnilight, freeSpot)
	SkyLights = #(IES_Sky, Texture_Sky, Skylight)
	SunLights = #(IES_Sun) -- AB: Jun 20, 2002
	LSLights = #(Free_Area, Target_Area, Free_Linear, Target_Linear, Free_Point, Target_Point, 
					   Free_Sphere, Target_Sphere, Free_Disc, Target_Disc, Free_Cylinder, Target_Cylinder)
	Luminaires = #(Luminaire)
	mrLights = #(miAreaLight, miAreaLightomni)
	mrSkyLight = #(mr_sky)
	mrSunLight = #(mr_sun)
	mrSkyPortalLight = #(mr_sky_portal)
	VRayLights = #(VRayLight)
	VRayIESLights = #(VRayIES)
	VRayAmbientLights = #(VRayAmbientLight)
	VRaySunSkyLights = #(VRaySun)
	
	-- Scene parser
	
	try (SceneLights = myCollection as array)
    catch (if (classof myCollection == SelectionSet) do (SceneLights = myCollection))
	sceneMaxLights = #()
	sceneLSLights = #()
	sceneSkyLights = #()
	sceneSunLights = #()
	sceneLuminaires = #()
	scenemiLights = #()
	scenemrSkyLights = #()
	scenemrSunLights = #()
	scenemrSkyPortalLights = #()
	sceneVRayLights = #()
	sceneVRayIESLights = #()
	sceneVRayAmbientLights = #()
	sceneVRaySunSkyLights = #()
	
	for i in SceneLights do
	(
		LightClass = classof i
		if findItem MaxLights LightClass != 0 do append sceneMaxLights i
		if findItem LSLights LightClass != 0 do append sceneLSLights i
		if findItem SkyLights LightClass != 0 do append sceneSkyLights i
		if findItem SunLights LightClass != 0 do append sceneSunLights i
		if findItem Luminaires LightClass != 0 do append sceneLuminaires i
		if findItem mrLights LightClass != 0 do append scenemiLights i
		if findItem mrSkyLight LightClass != 0 do append scenemrSkyLights i
		if findItem mrSunLight LightClass != 0 do append scenemrSunLights i
		if findItem mrSkyPortalLight LightClass != 0 do append scenemrSkyPortalLights i
		if findItem VRayLights LightClass != 0 do append sceneVRayLights i
		if findItem VRayIESLights LightClass != 0 do append sceneVRayIESLights i
		if findItem VRayAmbientLights LightClass != 0 do append sceneVRayAmbientLights i
		if findItem VRaySunSkyLights LightClass != 0 do append sceneVRaySunSkyLights i
	)
	
	-- Collect Light Instances and build array to be displayed
	
	tmpParser = #( \
		tmpsceneMaxLights = copyArray sceneMaxLights, \
		tmpscenemiLights = copyArray scenemiLights, \
		tmpscenemrSkyLights = copyArray scenemrSkyLights, \
		tmpscenemrSunLights = copyArray scenemrSunLights, \
		tmpscenemrSkyPortalLights = copyArray scenemrSkyPortalLights, \
		tmpsceneLSLights = copyArray sceneLSLights, \
		tmpsceneSkyLights = copyArray sceneSkyLights, \
		tmpsceneSunLights = copyArray sceneSunLights, \
		tmpsceneLuminaires = copyArray sceneLuminaires, \
		tmpsceneVRayLights = copyArray sceneVRayLights, \
		tmpsceneVRayIESLights = copyArray sceneVRayIESLights, \
		tmpsceneVRayAmbientLights = copyArray sceneVRayAmbientLights, \
		tmpsceneVRaySunSkyLights = copyArray sceneVRaySunSkyLights \
	)
	
	ListParser = #( \
		vrayLLister.maxLightsList = #(), \
		vrayLLister.miLightsList = #(), \
		vrayLLister.mrSkyLightsList = #(), \
		vrayLLister.mrSunLightsList = #(), \
		vrayLLister.mrSkyPortalLightsList = #(), \
		vrayLLister.LSLightsList = #(), \
		vrayLLister.SkyLightsList = #(), \
		vrayLLister.SunLightsList = #(), \
		vrayLLister.LuminairesList = #(), \
		vrayLLister.VRayLightsList = #(), \
		vrayLLister.VRayIESLightsList = #(), \
		vrayLLister.VRayAmbientLightsList = #(), \
		vrayLLister.VRaySunSkyLightsList = #() \
	)
	
	for i in 1 to tmpParser.count do
	(
		while tmpParser[i].count > 0 do
		(
			tmpNode = tmpParser[i][1].baseObject
			depends = refs.dependents tmpNode
			discard = #()
			for k in depends do if classof k != classof tmpNode or (superclassof k != light and superclassof k != helper) do append discard k
			for k in depends do 
				try
				(
					if classof k == DaylightAssemblyHead or classof k == ParamBlock2ParamBlock2 then 
						append discard k 
					else
						if k.AssemblyMember and not k.AssemblyHead and classof k.parent != DaylightAssemblyHead do append discard k
				) 
				catch()
			depends2 = subtractFromArray depends discard
			depends = SortNodeArrayByName depends2
			if depends.count > 0 do append listParser[i] depends
			tmpParser[i] = subtractFromArray tmpParser[i] (discard + depends)
		)
	)
	
	vrayLLister.totalLightCount = 	vrayLLister.maxLightsList.count + \
								vrayLLister.LSLightsList.count + \
								vrayLLister.SkyLightsList.count + \
								vrayLLister.SunLightsList.count + \
								vrayLLister.LuminairesList.count + \
								vrayLLister.miLightsList.count + \
								vrayLLister.mrSkyLightsList.count + \
								vrayLLister.mrSkyPortalLightsList.count + \
								vrayLLister.mrSunLightsList.count + \
								vrayLLister.VRayLightsList.count + \
								vrayLLister.VRayIESLightsList.count + \
								vrayLLister.VRayAmbientLightsList.count + \
								vrayLLister.VRaySunSkyLightsList.count
	
	-- build controls and rollouts
	
	-- MAX Lights
	
	vrayLLister.maxLightsRC = rolloutCreator "maxLightsRollout" "Lights" -- Localize the 2nd string only
	vrayLLister.maxLightsRC.begin()
  	-- print vrayLLister.maxLightsRC.str.count
	
	vrayLLister.maxLightsRC.addText "fn clearCheckButtons = for i in vrayLLister.LightInspectorListRollout.controls do if classof i == checkButtonControl do if i.checked do i.checked = false\n"
	
	vrayLLister.count = 1
	vrayLLister.lbCount = 1
	vrayLLister.LightIndex = #()
	vrayLLister.UIControlList = #(#(),#())
	
	struct td (label, offset)
	struct titleTemplate (maxLights, lsLights, miLights, luminaires, sunLights, skyLights, mrSkyLights, mrSunLights, mrSkyPortalLights, vrayLights, vrayIESLights, vrayAmbientLights, vraySunSkyLights)
	-- Start Localization
	local titleTemplates = titleTemplate \
		vrayLights:#(td "On" 8, td "Name" 28, td "Multiplier" 102, td "Color" 160, td "Temperature" 188, td "Units" 264, td "Shadows" 362, td "Subdivs" 408, td "Bias" 466, td "Invisible" 522, td "Skylight" 566, td "Diff." 624, td "Spec." 648, td "Reflect." 676, td "Caust. subd." 714) \
		vrayIESLights:#(td "On" 8, td "Name" 28, td "Power" 102, td "Color" 160, td "Temperature" 188, td "Shadows" 262, td "Subdivs" 308, td "Bias" 366, td "Diff." 428, td "Spec." 452, td "Use shape" 482, td "Area spec." 536, td "Caust. subd." 590) \
		vrayAmbientLights:#(td "On" 8, td "Name" 28, td "Intensity" 102, td "Color" 160, td "Caust. subd." 188) \
		vraySunSkyLights:#(td "On" 8, td "Name" 28, td "Intens. Mult." 100, td "Size Mult." 166, td "Sh. Subdivs" 218, td "Sh. Bias" 280, td "Invisible" 332, td "Turbidity" 374, td "Ozone" 432, td "Ph. Emit Rad." 490, td "Sky Model "560, td "Horiz. Illum." 652, td "Caust. subd." 712) \
		maxLights:#(td "On" 8, td "Name" 28, td "Multiplier" 102, td "Color" 160, td "Shadows" 190, td "Map Size" 332, td "Bias" 390, td "Sm.Range" 443, td "Transp." 495, td "Int." 535, td "Qual." 570, td "Decay" 612, td "Start" 690, td "Caust. subd." 750) \
		lsLights:#(td "On" 8, td "Name" 28, td "Intensity(cd)" 102, td "Color" 160, td "Shadows" 190, td "Map Size" 332, td "Bias" 390, td "Sm.Range" 443, td "Transp." 495, td "Int." 535, td "Qual." 570, td "Length" 612, td "Width/Radius" 671) \
		miLights:#(td "On" 8, td "Name" 28, td "Multiplier" 102, td "Color" 160, td "Shadows" 190, td "Map Size" 332, td "Bias" 390, td "Sm.Range" 443, td "Transp." 495, td "Int." 535, td "Qual." 570, td "Decay" 612, td "Start" 690) \
		luminaires:#(td "Name" 28, td "Dimmer" 102, td "Color" 160) \
		sunLights:#(td "On" 8, td "Name" 28, td "Intensity(lux)" 102, td "Color" 160, td "Shadows" 190, td "Map Size" 332, td "Bias" 390, td "Sm.Range" 443, td "Transp." 495, td "Int." 535, td "Qual." 570) \
		skyLights:#(td "On" 8, td "Name" 28, td "Multiplier" 102, td "Color" 160) \
		mrSkyLights:#(td "On" 8, td "Name" 28, td "Multiplier" 102, td "Haze" 161, td "H Height" 218, td "H Blur" 277, td "Ground" 333, td "Night" 382, td "Redness" 420, td "Saturation" 480, td "UseAerialPersp" 540, td "AerialPersp" 620) \
		mrSunLights:#(td "On" 8, td "Name" 28, td "Multiplier" 102, td "Shadows" 159, td "Softness" 211, td "Samples" 258, td "Targeted" 304, td "Distance" 353, td "Inherit" 426, td "Haze" 463, td "H Height" 513, td "Redness" 561, td "Saturation" 609, td "Use Targ" 663, td "Radius" 712) \
		mrSkyPortalLights:#(td "On" 8, td "Name" 28, td "Multiplier" 102, td "Color" 160, td "Shadows" 190, td "Extend" 240, td "Samples" 280, td "Length" 335, td "Width" 408, td "Flip Flux" 478, td "Visible" 525, td "Transparency" 560, td "Source" 640)
		-- End Localization
	
	fn WriteTitle labels:undefined =
	(
		local lbName
		fn lbName = 
		(
			if vrayLLister.lbCount == undefined do vrayLLister.lbCount = 1
			vrayLLister.lbCount += 1
			("LB" + vrayLLister.lbCount as string) as name
		)
		
		if (labels != undefined) do (
			for i = 1 to labels.count do (
				vrayLLister.maxLightsRC.addControl #label (lbname()) labels[i].label paramStr:(" align:#left offset:[" + labels[i].offset as string + "," + ((if (i == 1) then -3 else -18) + vrayLLister.yOffset + vrayLLister.LineOffset) as string + "]")
			)
		)
	)
	
	fn CreateControls hasMultiplier:false hasColor:false hasShadow:false hasDecay:false hasSize:false isLuminaire:false isMRSky:false isMRSun:false isMRSkyPortal:false isVRayLight:false isVRayIESLight:false isVRayAmbientLight:false isVRaySun:false hasCausticsSubdivs:false =
	(
		local lightClassName = ((classof vrayLLister.LightIndex[vrayLLister.count][1]) as string) as name
		
		-- Selection Checkbutton
		local isLightSelected = false
		
		for i in vrayLLister.LightIndex[vrayLLister.count] where (not isLightSelected) do isLightSelected = i.isSelected
		
		vrayLLister.UIControlList[1][vrayLLister.count] = vrayLLister.LightIndex[vrayLLister.count][1]
		vrayLLister.UIControlList[2][vrayLLister.Count] = #()
		
		vrayLLister.maxLightsRC.addControl #checkbutton (("LightSel" + vrayLLister.count as string) as name) "" \
			paramStr:("checked:" + (isLightSelected as string) + " offset:[-5,"+ (-2+ vrayLLister.yOffset + vrayLLister.LineOffset) as string + "] align:#left" +\
					" width:10 height:20 ")
		vrayLLister.maxLightsRC.addHandler (("LightSel" + vrayLLister.count as string) as name) #'changed state' filter:on \
			codeStr: \
			(
			"clearCheckButtons();if state then (max modify mode;select vrayLLister.LightIndex[" + vrayLLister.count as string + "];LightSel" + (vrayLLister.count as string) + ".checked = true); else max select none"
			)
		
		append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightSel" + vrayLLister.count as string) as name)
		
		-- On/Off
		if isLuminaire == false do
		(
			local onProp = case lightClassName of (
				#VRayIES:				#enabled
				#VRayAmbientLight:	#enabled
				#VRaySun:				#enabled
				default:					#on
			)
			vrayLLister.maxLightsRC.addControl #checkbox (("LightOn" + vrayLLister.count as string) as name) "" \
				paramStr:("checked:" + ((vrayLLister.GetlightProp vrayLLister.LightIndex[vrayLLister.count][1] onProp) as string) + " offset:[8,"+ (-22+ vrayLLister.yOffset) as string + "] width:18")
			vrayLLister.maxLightsRC.addHandler (("LightOn" + vrayLLister.count as string) as name) #'changed state' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #" + onProp +" state")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightOn" + vrayLLister.count as string) as name)
		)
		
		-- Light Name
		local isUsingEdittextOffset = 0
		
		if vrayLLister.LightIndex[vrayLLister.count].count == 1 then
		(
			local wrappedName = wrapString vrayLLister.LightIndex[vrayLLister.count][1].name
			vrayLLister.maxLightsRC.addControl #edittext (("LightName" + vrayLLister.count as string) as name) "" \
				paramStr:(" text:" + wrappedName + " width:75 height:16 offset:[23,"+ (-21+ vrayLLister.yOffset) as string + "] height:21")
			vrayLLister.maxLightsRC.addHandler (("LightName" + vrayLLister.count as string) as name) #'entered txt' filter:on \
				codeStr:("vrayLLister.LightIndex[" + vrayLLister.count as string + "][1].name = txt")

			isUsingEdittextOffset = 4
		)
		else
		(
			theNames = for j in vrayLLister.LightIndex[vrayLLister.count] collect j.name
			sort theNames
			namelist = "#("
			for j in 1 to theNames.count do 
				(
				local wrappedName = wrapString theNames[j]
				append namelist wrappedName
				if j != theNames.count do append namelist ","
				)
			append namelist ")"
			vrayLLister.maxLightsRC.addControl #dropDownList (("LightName" + vrayLLister.count as string) as name) "" filter:on\
				paramStr:(" items:" + NameList + " width:75 offset:[27,"+ (-22+ vrayLLister.yOffset) as string + "] ")
		)
		
		append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightName" + vrayLLister.count as string) as name)
		
		-- Light Multiplier
		if hasMultiplier do (
			local multiplierProp = case lightClassName of (
				#Free_Area:			#intensity
				#Target_Area:			#intensity
				#Free_Linear:			#intensity
				#Target_Linear:		#intensity
				#Free_Point:			#intensity
				#Target_Point:		#intensity
				#Free_Sphere:		#intensity
				#Target_Sphere:		#intensity
				#Free_Disc:			#intensity
				#Target_Disc:			#intensity
				#Free_Cylinder:		#intensity
				#Target_Cylinder:	#intensity
				#Luminaire:				#dimmer
				#mr_sun:				#skymult
				#VRayIES:				#power
				#VRayAmbientLight:	#intensity
				#VRaySun:				#intensity_multiplier
				default:					#multiplier
			)
			local multiplierEn = case lightClassName of (
				#VRayLight:	(not vrayLLister.LightIndex[vrayLLister.count][1].skylightPortal)
				default:		true
			)
			local multiplierMin = case lightClassName of (
				#mr_sky:					0.0
				#mr_sun:					0.0
				#mr_sky_portal:		0.0
				#VRayLight:				-1000000000.0
				#VRayIES:				0.0
				#VRayAmbientLight:	0.0
				#VRaySun:				0.0
				default:					-1000000.0
			)
			local multiplierMax = case lightClassName of (
				#mr_sky:					15.0
				#mr_sun:					10.0
				#VRayLight:				1000000000.0
				#VRayIES:				1000000000.0
				#VRayAmbientLight:	1000000000.0
				#VRaySun:				1000000000.0
				default:					1000000.0
			)
			
			vrayLLister.maxLightsRC.addControl #spinner (("LightMult" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[" + multiplierMin as string + "," + multiplierMax as string + "," + \
				(vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] multiplierProp) as string + "] type:#float " + \
				"fieldwidth:45 align:#left offset:[100," + (isUsingEdittextOffset-24+vrayLLister.yOffset) as string + "] enabled:" + multiplierEn as string)
			vrayLLister.maxLightsRC.addHandler (("LightMult" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #"+ multiplierProp + " val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightMult" + vrayLLister.count as string) as name)
		)			
		
		-- Light Color
		if hasColor do (
			local colorProp = case lightClassName of (
				#Free_Light:			#rgbFilter
				#Target_Light:		#rgbFilter
				#Free_Area:			#rgbFilter
				#Target_Area:		#rgbFilter
				#Free_Linear:			#rgbFilter
				#Target_Linear:		#rgbFilter
				#Free_Point:			#rgbFilter
				#Target_Point:		#rgbFilter
				#Free_Sphere:		#rgbFilter
				#Target_Sphere:		#rgbFilter
				#Free_Disc:			#rgbFilter
				#Target_Disc:			#rgbFilter
				#Free_Cylinder:		#rgbFilter
				#Target_Cylinder:	#rgbFilter
				#Luminaire:			#FilterColor
				#mr_sky_portal:		#rgbFilter
				default:					#Color
			)
			local colorEn = case lightClassName of (
				#VRayLight:	 ((vrayLLister.LightIndex[vrayLLister.count][1].baseobject.color_mode == 0) and
										(not vrayLLister.LightIndex[vrayLLister.count][1].skylightPortal))
				#VRayIES:		(vrayLLister.LightIndex[vrayLLister.count][1].baseobject.color_mode == 0)
				default:			true
			)
			vrayLLister.maxLightsRC.addControl #colorpicker (("LightCol" + vrayLLister.count as string) as name) "" \
				paramStr:("color:" + (vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] colorProp) as string + \
				" offset:[158,"+ (-23+ vrayLLister.yOffset) as string + "] width:25 enabled:" + colorEn as string)
			vrayLLister.maxLightsRC.addHandler (("LightCol" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #" + colorProp + " val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightCol" + vrayLLister.count as string) as name)
		)
		
		if hasShadow do (
			-- Shadow On/Off
			
			vrayLLister.maxLightsRC.addControl #checkbox (("LightShdOn" + vrayLLister.count as string) as name) "" \
				paramStr:("checked:" + (vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1].baseObject #castshadows as string)+ \
				" offset:[190,"+ (-22+ vrayLLister.yOffset) as string + "] width:15")
			vrayLLister.maxLightsRC.addHandler (("LightShdOn" + vrayLLister.count as string) as name) #'changed state' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1].baseobject #castshadows state")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightShdOn" + vrayLLister.count as string) as name)
			
			-- Shadow Plugin
			local LLshadowClass = vrayLLister.fnShadowClass vrayLLister.LightIndex[vrayLLister.count][1]
			local LLshadowGen = (vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #shadowGenerator)
			
			vrayLLister.maxLightsRC.addControl #dropDownList (("LightShd" + vrayLLister.count as string) as name) "" filter:on\
				paramStr:(" items:" + vrayLLister.ShadowPluginsName as string + " width:110 offset:[210,"+ (-24+ vrayLLister.yOffset) as string + "]" + \
				"selection:(finditem vrayLLister.ShadowPlugins (vrayLLister.fnShadowClass vrayLLister.LightIndex[" + vrayLLister.count as string + "][1]))")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightShd" + vrayLLister.count as string) as name)
			
			-- Light Map Size
			local mapSizeTmp = \
				case LLshadowClass of (
					shadowMap:					LLshadowGen.mapSize
					mental_ray_shadow_map:	LLshadowGen.Map_Size
					VRayShadowMap:			LLshadowGen.resolution
					default:							512
				)
				
			local hasShadowMapSize = LLshadowClass == shadowMap or LLShadowClass == mental_ray_shadow_map or
													LLshadowClass == VRayShadowMap
			vrayLLister.maxLightsRC.addControl #spinner (("LightMapSiz" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[0,10000," + (mapSizeTmp as string) + "] type:#integer " + \
				"fieldwidth:45 align:#left offset:[330,"+ (-24+ vrayLLister.yOffset) as string + "] enabled:" \
				+ hasShadowMapSize as string)
			vrayLLister.maxLightsRC.addHandler (("LightMapSiz" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr: \
				(
				"local propname = case (vrayLLister.fnShadowClass vrayLLister.LightIndex[" + vrayLLister.count as string + "][1]) of\n" + \
				"(shadowMap:#mapSize; mental_ray_shadow_map:#Map_Size; VRayShadowMap:#resolution; default:0)\n" + \
				"if propname != 0 do vrayLLister.SetShdProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] propName val"
				)
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightMapSiz" + vrayLLister.count as string) as name)
			
			-- Light Bias
			local BiasTmp = \
				case LLshadowClass of (
					shadowMap:				LLShadowGen.mapBias
					raytraceShadow:			LLShadowGen.raytraceBias
					Area_Shadows:			LLShadowGen.ray_Bias
					Adv__Ray_Traced:		LLShadowGen.ray_Bias
					Blur_Adv__Ray_Traced:	LLShadowGen.ray_Bias
					VRayShadow:				LLShadowGen.bias
					VRayShadowMap:		LLShadowGen.bias
					default:						1.0
				)
			
			local hasShadowBias = LLShadowClass == shadowMap or LLShadowClass == raytraceShadow or
												LLShadowClass == Blur_Adv__Ray_Traced or LLShadowClass == Area_Shadows or
												LLShadowClass == Adv__Ray_Traced or LLShadowClass == VRayShadow or
												LLShadowClass == VRayShadowMap
			vrayLLister.maxLightsRC.addControl #spinner (("LightBias" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[0,10000," + (BiasTmp as string) + "] type:#float " + \
				"fieldwidth:45 align:#left offset:[388,"+ (-21+ vrayLLister.yOffset) as string + "] enabled:" \
				+ hasShadowBias as string)
			vrayLLister.maxLightsRC.addHandler (("LightBias" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr: \
				(
				"local propname = case (vrayLLister.fnShadowClass vrayLLister.LightIndex[" + vrayLLister.count as string + "][1]) of\n" + \
				"(shadowMap:#mapbias; raytraceShadow:#raytraceBias; Area_Shadows:#ray_bias; Adv__Ray_Traced:#ray_bias;" + \
					"Blur_Adv__Ray_Traced:#ray_bias; VRayShadow:#bias; VRayShadowMap:#bias; default:0)\n" + \
				"if propname != 0 do vrayLLister.SetShdProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] propName val"
				)
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightBias" + vrayLLister.count as string) as name)
			
			-- Light Sample Range
			local smpRangeTmp = 4.0
			local smpRangeStr = "#samplerange"   --fix the mr shadow sample problem here.
			if LLShadowClass == shadowMap  then	smpRangeTmp = LLShadowGen.samplerange
			else if LLShadowClass == mental_ray_Shadow_Map do (
				smpRangeTmp = LLShadowGen.Sample_Range
				smpRangeStr = "#Sample_Range"
			)
			vrayLLister.maxLightsRC.addControl #spinner (("LightSmpRange" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[0,50," + (smpRangeTmp as string) + "] type:#float " + \
				"fieldwidth:45 align:#left offset:[446,"+ (-21+ vrayLLister.yOffset) as string + "] enabled:" + (LLShadowClass == shadowMap or LLShadowClass == mental_ray_shadow_map) as string)
			vrayLLister.maxLightsRC.addHandler (("LightSmpRange" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.SetShdProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] "+smpRangeStr+" val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightSmpRange" + vrayLLister.count as string) as name)
			
			-- Transparency On/Off
			vrayLLister.maxLightsRC.addControl #checkbox (("LightTrans" + vrayLLister.count as string) as name) "" \
				paramStr:("checked:" + \
						((if LLShadowClass == Area_Shadows or LLShadowClass == Adv__Ray_Traced or LLShadowClass == Blur_Adv__Ray_Traced then \
						LLShadowGen.shadow_Transparent else false) as string) + \
						" offset:[508,"+ (-20+ vrayLLister.yOffset) as string + "] width:15 enabled:" + \
						((LLShadowClass == Area_Shadows or LLShadowClass == Adv__Ray_Traced or LLShadowClass == Blur_Adv__Ray_Traced) as string))
			vrayLLister.maxLightsRC.addHandler (("LightTrans" + vrayLLister.count as string) as name) #'changed state' filter:on \
				codeStr:("vrayLLister.setShdProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #shadow_Transparent state")
			
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightTrans" + vrayLLister.count as string) as name)
			
			-- Integrity
			vrayLLister.maxLightsRC.addControl #spinner (("LightInteg" + vrayLLister.count as string) as name) "" \
				paramStr:("type:#integer fieldwidth:30 align:#left range:[1,15," + \
						((if LLShadowClass == Area_Shadows or LLShadowClass == Blur_Adv__Ray_Traced or\
						LLShadowClass == Adv__Ray_Traced then \
						LLShadowGen.pass1 else 1) as string) + \
						"] offset:[521,"+ (-21+ vrayLLister.yOffset) as string + "] width:15 enabled:" + \
						((LLShadowClass == Area_Shadows or LLShadowClass == Blur_Adv__Ray_Traced or\
						LLShadowClass == Adv__Ray_Traced) as string))
			vrayLLister.maxLightsRC.addHandler (("LightInteg" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setShdProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #pass1 val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightInteg" + vrayLLister.count as string) as name)
			
			-- Quality
			vrayLLister.maxLightsRC.addControl #spinner (("LightQual" + vrayLLister.count as string) as name) "" \
				paramStr:("type:#integer fieldwidth:30 align:#left range:[1,15," + \
						((if LLShadowClass == Area_Shadows or LLShadowClass == Blur_Adv__Ray_Traced or \
						LLShadowClass == Adv__Ray_Traced then \
						LLShadowGen.pass2 else 2) as string) + \
						"] offset:[565,"+ (-21+ vrayLLister.yOffset) as string + "] width:15 enabled:" + \
						((LLShadowClass == Area_Shadows or LLShadowClass == Blur_Adv__Ray_Traced or \
						LLShadowClass == Adv__Ray_Traced) as string))
			vrayLLister.maxLightsRC.addHandler (("LightQual" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setShdProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #pass2 val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightQual" + vrayLLister.count as string) as name)
			
			-- Shadow Plugin dropdown handler
			vrayLLister.maxLightsRC.addHandler (("LightShd" + vrayLLister.count as string) as name) #'selected i' filter:on \
				codeStr:(\
					"vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #shadowGenerator (vrayLLister.ShadowPlugins[i]());" + \
					"local shdClass = vrayLLister.fnShadowClass vrayLLister.LightIndex[" + vrayLLister.count as string + "][1]\n" + \
					"LightMapSiz" + vrayLLister.count as string + ".enabled = LightSmpRange" + vrayLLister.count as string + ".enabled = " + \
						"(shdClass == shadowMap or shdClass == mental_ray_shadow_map or shdClass == VRayShadowMap)\n" + \
					"LightTrans" + vrayLLister.count as string + ".enabled = LightInteg" + vrayLLister.count as string + ".enabled = LightQual" + vrayLLister.count as string + ".enabled = " + \
						"shdClass == Adv__Ray_Traced or shdClass == Blur_Adv__Ray_Traced or shdClass == Area_Shadows\n" + \
					"LightBias" + vrayLLister.count as string + ".enabled = (shdClass == Area_Shadows or shdClass == shadowMap or " + \
						"shdClass == Blur_Adv__Ray_Traced or shdClass == raytraceShadow or shdClass ==  Adv__Ray_Traced or " + \
						"shdClass == VRayShadow or shdClass == VRayShadowMap)\n" + \
					"if (val = vrayLLister.getShdProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #mapSize) != undefined do LightMapSiz" + \
						vrayLLister.count as string + ".value = val\n" + \
					"if (val = vrayLLister.getShdProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #resolution) != undefined do LightMapSiz" + \
						vrayLLister.count as string + ".value = val\n" + \
					"if (val = vrayLLister.getShdProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #sampleRange) != undefined do LightSmpRange" + \
						vrayLLister.count as string + ".value = val\n" + \
					"if (val = vrayLLister.getShdProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #pass1) != undefined do LightInteg" + \
						vrayLLister.count as string + ".value = val\n" + \
					"if (val = vrayLLister.getShdProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #pass2) != undefined do LightQual" + \
						vrayLLister.count as string + ".value = val\n" + \
					"if (val = vrayLLister.getShdProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #mapBias) != undefined do LightBias" + \
						vrayLLister.count as string + ".value = val\n" + \
					"if (val = vrayLLister.getShdProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #ray_Bias) != undefined do LightBias" + \
						vrayLLister.count as string + ".value = val\n" + \
					"if (val = vrayLLister.getShdProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #raytraceBias) != undefined do LightBias" + \
						vrayLLister.count as string + ".value = val\n" + \
					"if (val = vrayLLister.getShdProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #bias) != undefined do LightBias" + \
						vrayLLister.count as string + ".value = val\n" + \
					"if (val = vrayLLister.getShdProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #shadow_Transparent) != undefined do LightTrans" + \
						vrayLLister.count as string + ".checked = val\n" + \
					"vrayLLister.enableRefreshBtn vrayLLister.LightIndex[" + vrayLLister.count as string + "][1]"
					)
		) -- end has Shadow
		
		if hasDecay do
		(
			-- Decay selection
			vrayLLister.maxLightsRC.addControl #dropDownList (("LightDecay" + vrayLLister.count as string) as name) "" filter:on\
				paramStr:(" items:" + vrayLLister.decayStrings as string + " width:80 offset:[612,"+ (-24+ vrayLLister.yOffset) as string + "]" + \
				"selection:(vrayLLister.getLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #attenDecay)")
			vrayLLister.maxLightsRC.addHandler (("LightDecay" + vrayLLister.count as string) as name) #'selected i' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #attenDecay i")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightDecay" + vrayLLister.count as string) as name)
			
			-- Decay Start
			vrayLLister.maxLightsRC.addControl #spinner (("LightDecStart" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[0,10000," + ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #decayRadius) as string) + "] type:#worldunits " + \
				"fieldwidth:45 align:#left offset:[690,"+ (-24+ vrayLLister.yOffset) as string + "]")
			vrayLLister.maxLightsRC.addHandler (("LightDecStart" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #decayRadius val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightDecStart" + vrayLLister.count as string) as name)
		) -- end hasDecay
		
		if hasSize do
		(
			local lightType = vrayLLister.LightIndex[vrayLLister.count][1].type
			
			-- Light Length
			local hasLength = lightType == #Free_Line or lightType == #Target_Line or 
										lightType == #Free_Rectangle or lightType == #Target_Rectangle or 
										lightType == #Free_Cylinder or lightType == #Target_Cylinder or
										lightType == #Free_Area or lightType == #Target_Area or
										lightType == #Free_Linear or lightType == #Target_Linear
			
			local lengthTmp = case lightType of (
				#Free_Line:			vrayLLister.LightIndex[vrayLLister.count][1].length
				#Target_Line:			vrayLLister.LightIndex[vrayLLister.count][1].length
				#Free_Rectangle:		vrayLLister.LightIndex[vrayLLister.count][1].length
				#Target_Rectangle:	vrayLLister.LightIndex[vrayLLister.count][1].length
				#Free_Cylinder:		vrayLLister.LightIndex[vrayLLister.count][1].length
				#Target_Cylinder:	vrayLLister.LightIndex[vrayLLister.count][1].length
				#Free_Area:			vrayLLister.LightIndex[vrayLLister.count][1].light_length
				#Target_Area:			vrayLLister.LightIndex[vrayLLister.count][1].light_length
				#Free_Linear:			vrayLLister.LightIndex[vrayLLister.count][1].light_length
				#Target_Linear:		vrayLLister.LightIndex[vrayLLister.count][1].light_length
				default:					48
			)
			local lengthStr = case lightType of (
				#Free_Line:			"length"
				#Target_Line:			"length"
				#Free_Rectangle:		"length"
				#Target_Rectangle:	"length"
				#Free_Cylinder:		"length"
				#Target_Cylinder:	"length"
				#Free_Linear:			"light_length"
				#Target_Area:			"light_length"
				#Free_Area:			"light_length"
				#Target_Linear:		"light_length"
				default:					"length"
			)
			
			vrayLLister.maxLightsRC.addControl #spinner (("LSLightLength" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[0,100000," + (lengthTmp as string) + "] type:#worldunits " + \
				"fieldwidth:45 align:#left offset:[610,"+ (-21+ vrayLLister.yOffset) as string + "] enabled:" \
				+ (hasLength as string))
			vrayLLister.maxLightsRC.addHandler (("LSLightLength" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.LightIndex[" + vrayLLister.count as string + "][1]." + lengthStr + " = val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LSLightLength" + vrayLLister.count as string) as name)
			
			-- Light Width / Radius
			local hasWidth = lightType == #Free_Rectangle or lightType == #Target_Rectangle or
										lightType == #Free_Area or lightType == #Target_Area or
										lightType == #Target_Point or lightType == #VRayLight_Plane
			
			local widthTmp = case lightType of (
				#Free_Rectangle:		vrayLLister.LightIndex[vrayLLister.count][1].width
				#Target_Rectangle:	vrayLLister.LightIndex[vrayLLister.count][1].width
				#Free_Area:			vrayLLister.LightIndex[vrayLLister.count][1].light_width
				#Target_Area:			vrayLLister.LightIndex[vrayLLister.count][1].light_width
				#VRayLight_Plane:	vrayLLister.LightIndex[vrayLLister.count][1].size1
				default:					24
			)
			
			local widthStr = case lightType of (
				#Free_Rectangle:		"width"
				#Target_Rectangle:	"width"
				#Free_Area:			"light_width"
				#Target_Area:			"light_width"
				#VRayLight_Plane:	"size1"
				default:					"width"
			)
			
			local hasRadius = lightType == #Free_Cylinder or lightType == #Target_Cylinder or 
										lightType == #Free_Disc or lightType == #Target_Disc or 
										lightType == #Free_Sphere or lightType == #Target_Sphere
			
			local radiusTmp = case lightType of (
				#Free_Cylinder:		vrayLLister.LightIndex[vrayLLister.count][1].radius
				#Target_Cylinder:	vrayLLister.LightIndex[vrayLLister.count][1].radius
				#Free_Disc:			vrayLLister.LightIndex[vrayLLister.count][1].radius
				#Target_Disc:			vrayLLister.LightIndex[vrayLLister.count][1].radius
				#Free_Sphere:		vrayLLister.LightIndex[vrayLLister.count][1].radius
				#Target_Sphere:		vrayLLister.LightIndex[vrayLLister.count][1].radius
				default:					5.5
			)
			
			local radiusStr = case lightType of (
				#Free_Cylinder:		"radius"
				#Target_Cylinder:	"radius"
				#Free_Disc:			"radius"
				#Target_Disc:			"radius"
				#Free_Sphere:		"radius"
				#Target_Sphere:		"radius"
				#VRayLight:			"size0"
				default:					"radius"
			)
			
			if (hasWidth) then (
				vrayLLister.maxLightsRC.addControl #spinner (("LSLightWidth" + vrayLLister.count as string) as name) "" \
					paramStr:("range:[0,100000," + (widthTmp as string) + "] type:#worldunits " + \
					"fieldwidth:45 align:#left offset:[669,"+ (-21+ vrayLLister.yOffset) as string + "] enabled:" \
					+ (hasWidth as string))
				vrayLLister.maxLightsRC.addHandler (("LSLightWidth" + vrayLLister.count as string) as name) #'changed val' filter:on \
					codeStr:("vrayLLister.LightIndex[" + vrayLLister.count as string + "][1]." + widthStr + " = val")
			)
			else (
				vrayLLister.maxLightsRC.addControl #spinner (("LSLightWidth" + vrayLLister.count as string) as name) "" \
					paramStr:("range:[0,100000," + (radiusTmp as string) + "] type:#worldunits " + \
					"fieldwidth:45 align:#left offset:[669,"+ (-21+ vrayLLister.yOffset) as string + "] enabled:" \
					+ (hasRadius as string))
				
				if (hasRadius) do (
					vrayLLister.maxLightsRC.addHandler (("LSLightWidth" + vrayLLister.count as string) as name) #'changed val' filter:on \
						codeStr:("vrayLLister.LightIndex[" + vrayLLister.count as string + "][1]." + radiusStr + " = val")
				)
			)
			
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LSLightWidth" + vrayLLister.count as string) as name)
		)
		
		if isMRSky do
		(
			-- Haze
			vrayLLister.maxLightsRC.addControl #spinner (("LightHaze" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[0,15," + ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #haze) as string) + "] type:#float " + \
				"fieldwidth:45 align:#left offset:[158,"+ (-21+ vrayLLister.yOffset) as string + "]")
			vrayLLister.maxLightsRC.addHandler (("LightHaze" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #haze val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightHaze" + vrayLLister.count as string) as name)

			-- HorizonHeight
			vrayLLister.maxLightsRC.addControl #spinner (("LightHHeight" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[-10,10," + ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #HorizonHeight) as string) + "] type:#float " + \
				"fieldwidth:45 align:#left offset:[216,"+ (-21+ vrayLLister.yOffset) as string + "]")
			vrayLLister.maxLightsRC.addHandler (("LightHHeight" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #HorizonHeight val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightHHeight" + vrayLLister.count as string) as name)

			-- HorizonBlur
			vrayLLister.maxLightsRC.addControl #spinner (("LightHBlur" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[0,10," + ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #HorizonBlur) as string) + "] type:#float " + \
				"fieldwidth:45 align:#left offset:[274,"+ (-21+ vrayLLister.yOffset) as string + "]")
			vrayLLister.maxLightsRC.addHandler (("LightHBlur" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #HorizonBlur val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightHBlur" + vrayLLister.count as string) as name)

			-- GroundColor
			vrayLLister.maxLightsRC.addControl #colorpicker (("LightGroundCol" + vrayLLister.count as string) as name) "" \
				paramStr:("color:" + (vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #GroundColor) as string + \
				" offset:[335,"+ (-23+ vrayLLister.yOffset) as string + "] width:25")
			vrayLLister.maxLightsRC.addHandler (("LightGroundCol" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #GroundColor val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightGroundCol" + vrayLLister.count as string) as name)
				
			-- NightColor
			vrayLLister.maxLightsRC.addControl #colorpicker (("LightNightCol" + vrayLLister.count as string) as name) "" \
				paramStr:("color:" + (vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #NightColor) as string + \
				" offset:[380,"+ (-25+ vrayLLister.yOffset) as string + "] width:25")
			vrayLLister.maxLightsRC.addHandler (("LightNightCol" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #NightColor val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightNightCol" + vrayLLister.count as string) as name)
				
			-- Redness
			vrayLLister.maxLightsRC.addControl #spinner (("LightRedness" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[-1,1," + ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #Redness) as string) + "] type:#float " + \
				"fieldwidth:45 align:#left offset:[419,"+ (-23+ vrayLLister.yOffset) as string + "]")
			vrayLLister.maxLightsRC.addHandler (("LightRedness" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #Redness val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightRedness" + vrayLLister.count as string) as name)

			-- Saturation
			vrayLLister.maxLightsRC.addControl #spinner (("LightSaturation" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[0,2," + ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #Saturation) as string) + "] type:#float " + \
				"fieldwidth:45 align:#left offset:[477,"+ (-21+ vrayLLister.yOffset) as string + "]")
			vrayLLister.maxLightsRC.addHandler (("LightSaturation" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #Saturation val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightSaturation" + vrayLLister.count as string) as name)

			-- UseAerialPerspective
			vrayLLister.maxLightsRC.addControl #checkbox (("LightUseAerPersp" + vrayLLister.count as string) as name) "" \
				paramStr:("checked:" + (vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #UseAerialPerspective as string)+ \
				" offset:[570,"+ (-21+ vrayLLister.yOffset) as string + "] width:15")
			vrayLLister.maxLightsRC.addHandler (("LightUseAerPersp" + vrayLLister.count as string) as name) #'changed state' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #UseAerialPerspective state")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightUseAerPersp" + vrayLLister.count as string) as name)

			-- AerialPerspective
			vrayLLister.maxLightsRC.addControl #spinner (("LightAerialPersp" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[0,1e8," + ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #AerialPerspective) as string) + "] type:#worldunits " + \
				"fieldwidth:60 align:#left offset:[618,"+ (-21+ vrayLLister.yOffset) as string + "]")
			vrayLLister.maxLightsRC.addHandler (("LightAerialPersp" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #AerialPerspective val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightAerialPersp" + vrayLLister.count as string) as name)
		)
		
		if isMRSun do
		(
			-- Shadow On/Off
			vrayLLister.maxLightsRC.addControl #checkbox (("LightShdOn" + vrayLLister.count as string) as name) "" \
				paramStr:("checked:" + (vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1].baseObject #castshadows as string)+ \
				" offset:[175,"+ (-22+ vrayLLister.yOffset) as string + "] width:15")
			vrayLLister.maxLightsRC.addHandler (("LightShdOn" + vrayLLister.count as string) as name) #'changed state' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1].baseobject #castshadows state")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightShdOn" + vrayLLister.count as string) as name)

			-- shadowSoftness
			vrayLLister.maxLightsRC.addControl #spinner (("LightShdSoft" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[0,50," + ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #shadowSoftness) as string) + "] type:#float " + \
				"fieldwidth:35 align:#left offset:[210,"+ (-20+ vrayLLister.yOffset) as string + "]")
			vrayLLister.maxLightsRC.addHandler (("LightShdSoft" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #shadowSoftness val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightShdSoft" + vrayLLister.count as string) as name)

			-- shadowSamples
			vrayLLister.maxLightsRC.addControl #spinner (("LightShdSamples" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[0,1000," + ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #shadowSamples) as string) + "] type:#integer " + \
				"fieldwidth:35 align:#left offset:[259,"+ (-20+ vrayLLister.yOffset) as string + "]")
			vrayLLister.maxLightsRC.addHandler (("LightShdSamples" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #shadowSamples val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightShdSamples" + vrayLLister.count as string) as name)

			-- hasTarget
			vrayLLister.maxLightsRC.addControl #checkbox (("LightHasTarg" + vrayLLister.count as string) as name) "" \
				paramStr:("checked:" + (vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #hasTarget as string)+ \
				" offset:[320,"+ (-21+ vrayLLister.yOffset) as string + "] width:15")
			vrayLLister.maxLightsRC.addHandler (("LightHasTarg" + vrayLLister.count as string) as name) #'changed state' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #hasTarget state")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightHasTarg" + vrayLLister.count as string) as name)

			-- targetDistance
			vrayLLister.maxLightsRC.addControl #spinner (("LightTargDist" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[0,1e8," + ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1].baseobject #targetDistance) as string) + "] type:#worldunits " + \
				"fieldwidth:60 align:#left offset:[352,"+ (-20+ vrayLLister.yOffset) as string + "]")
			vrayLLister.maxLightsRC.addHandler (("LightTargDist" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1].baseobject #targetDistance val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightTargDist" + vrayLLister.count as string) as name)

			-- inherit
			vrayLLister.maxLightsRC.addControl #checkbox (("LightInherit" + vrayLLister.count as string) as name) "" \
				paramStr:("checked:" + (vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #inherit as string)+ \
				" offset:[435,"+ (-21+ vrayLLister.yOffset) as string + "] width:15")
			vrayLLister.maxLightsRC.addHandler (("LightInherit" + vrayLLister.count as string) as name) #'changed state' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #inherit state")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightInherit" + vrayLLister.count as string) as name)

			-- haze
			vrayLLister.maxLightsRC.addControl #spinner (("LightHaze" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[0,15," + ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #haze) as string) + "] type:#float " + \
				"fieldwidth:35 align:#left offset:[463,"+ (-20+ vrayLLister.yOffset) as string + "]")
			vrayLLister.maxLightsRC.addHandler (("LightHaze" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #haze val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightHaze" + vrayLLister.count as string) as name)

			-- horizonheight
			vrayLLister.maxLightsRC.addControl #spinner (("LightHHeight" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[-10,10," + ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #horizonheight) as string) + "] type:#float " + \
				"fieldwidth:35 align:#left offset:[513,"+ (-21+ vrayLLister.yOffset) as string + "]")
			vrayLLister.maxLightsRC.addHandler (("LightHHeight" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #horizonheight val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightHHeight" + vrayLLister.count as string) as name)

			-- redblueshift
			vrayLLister.maxLightsRC.addControl #spinner (("LightRedness" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[-1,1," + ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #redblueshift) as string) + "] type:#float " + \
				"fieldwidth:35 align:#left offset:[563,"+ (-21+ vrayLLister.yOffset) as string + "]")
			vrayLLister.maxLightsRC.addHandler (("LightRedness" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #redblueshift val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightRedness" + vrayLLister.count as string) as name)

			-- saturation
			vrayLLister.maxLightsRC.addControl #spinner (("LightSaturation" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[0,2," + ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #saturation) as string) + "] type:#float " + \
				"fieldwidth:35 align:#left offset:[613,"+ (-21+ vrayLLister.yOffset) as string + "]")
			vrayLLister.maxLightsRC.addHandler (("LightSaturation" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #saturation val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightSaturation" + vrayLLister.count as string) as name)

			-- usephotontarget
			vrayLLister.maxLightsRC.addControl #checkbox (("LightUsePTarg" + vrayLLister.count as string) as name) "" \
				paramStr:("checked:" + (vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #usephotontarget as string)+ \
				" offset:[678,"+ (-21+ vrayLLister.yOffset) as string + "] width:15")
			vrayLLister.maxLightsRC.addHandler (("LightUsePTarg" + vrayLLister.count as string) as name) #'changed state' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #usephotontarget state")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightUsePTarg" + vrayLLister.count as string) as name)

			-- photontarget
			vrayLLister.maxLightsRC.addControl #spinner (("LightPhotonTarg" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[0,1e8," + ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #photontarget) as string) + "] type:#worldunits " + \
				"fieldwidth:60 align:#left offset:[700,"+ (-21+ vrayLLister.yOffset) as string + "]")
			vrayLLister.maxLightsRC.addHandler (("LightPhotonTarg" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #photontarget val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightPhotonTarg" + vrayLLister.count as string) as name)
		)
		
		if isMRSkyPortal do
		(
			-- Shadow On/Off
			vrayLLister.maxLightsRC.addControl #checkbox (("LightShdOn" + vrayLLister.count as string) as name) "" \
				paramStr:("checked:" + (vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1].baseObject #castshadows as string)+ \
				" offset:[210,"+ (-22+ vrayLLister.yOffset) as string + "] width:15")
			vrayLLister.maxLightsRC.addHandler (("LightShdOn" + vrayLLister.count as string) as name) #'changed state' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1].baseobject #castshadows state")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightShdOn" + vrayLLister.count as string) as name)

			-- extend_shadows
			vrayLLister.maxLightsRC.addControl #checkbox (("LightExtShad" + vrayLLister.count as string) as name) "" \
				paramStr:("checked:" + (vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #extend_shadows as string)+ \
				" offset:[250,"+ (-21+ vrayLLister.yOffset) as string + "] width:15")
			vrayLLister.maxLightsRC.addHandler (("LightExtShad" + vrayLLister.count as string) as name) #'changed state' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #extend_shadows state")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightExtShad" + vrayLLister.count as string) as name)

			-- shadowSamples
			vrayLLister.maxLightsRC.addControl #dropDownList (("LightShdSamples" + vrayLLister.count as string) as name) "" filter:on\
				paramStr:(" items:" + vrayLLister.MRSkyPortal_ShadowSamples as string + " width:52 offset:[278,"+ (-23+ vrayLLister.yOffset) as string + "]" + \
				"selection:" + (((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #shadowSamples) +1) as string))
			vrayLLister.maxLightsRC.addHandler (("LightShdSamples" + vrayLLister.count as string) as name) #'selected i' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #shadowSamples (i-1)")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightShdSamples" + vrayLLister.count as string) as name)

			-- length
			vrayLLister.maxLightsRC.addControl #spinner (("LightLength" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[0,1e8," + ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #length) as string) + "] type:#worldunits " + \
				"fieldwidth:60 align:#left offset:[331,"+ (-24+ vrayLLister.yOffset) as string + "]")
			vrayLLister.maxLightsRC.addHandler (("LightLength" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #length val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightLength" + vrayLLister.count as string) as name)

			-- light_width
			vrayLLister.maxLightsRC.addControl #spinner (("LightWidth" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[0,1e8," + ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #light_width) as string) + "] type:#worldunits " + \
				"fieldwidth:60 align:#left offset:[406,"+ (-21+ vrayLLister.yOffset) as string + "]")
			vrayLLister.maxLightsRC.addHandler (("LightWidth" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #light_width val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightWidth" + vrayLLister.count as string) as name)

				-- reversed
			vrayLLister.maxLightsRC.addControl #checkbox (("LightFlipFlux" + vrayLLister.count as string) as name) "" \
				paramStr:("checked:" + (vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #reversed as string)+ \
				" offset:[490,"+ (-21+ vrayLLister.yOffset) as string + "] width:15")
			vrayLLister.maxLightsRC.addHandler (("LightFlipFlux" + vrayLLister.count as string) as name) #'changed state' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #reversed state")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightFlipFlux" + vrayLLister.count as string) as name)

				-- Area_Visible
			vrayLLister.maxLightsRC.addControl #checkbox (("LightAreaVisible" + vrayLLister.count as string) as name) "" \
				paramStr:("checked:" + (vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #Area_Visible as string)+ \
				" offset:[535,"+ (-21+ vrayLLister.yOffset) as string + "] width:15")
			vrayLLister.maxLightsRC.addHandler (("LightAreaVisible" + vrayLLister.count as string) as name) #'changed state' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #Area_Visible state")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightAreaVisible" + vrayLLister.count as string) as name)

			-- transparency
			vrayLLister.maxLightsRC.addControl #colorpicker (("LightTransparency" + vrayLLister.count as string) as name) "" \
				paramStr:("color:" + (vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #transparency) as string + \
				" offset:[580,"+ (-23+ vrayLLister.yOffset) as string + "] width:25")
			vrayLLister.maxLightsRC.addHandler (("LightTransparency" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #transparency val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightTransparency" + vrayLLister.count as string) as name)
				
			-- mode
			vrayLLister.maxLightsRC.addControl #dropDownList (("LightSourceMode" + vrayLLister.count as string) as name) "" filter:on\
				paramStr:(" items:" + vrayLLister.MRSkyPortal_Modes as string + " width:70 offset:[640,"+ (-24+ vrayLLister.yOffset) as string + "]" + \
				"selection:" + (((mod ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #mode) + 1) 3) +1 ) as string))
			vrayLLister.maxLightsRC.addHandler (("LightSourceMode" + vrayLLister.count as string) as name) #'selected i' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #mode (mod (i+1) 3)")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightSourceMode" + vrayLLister.count as string) as name)
		)
		
		if isVRayLight do (
			-- Temperature/Color switch
			local colorEn = (not vrayLLister.LightIndex[vrayLLister.count][1].skylightPortal)
			vrayLLister.maxLightsRC.addControl #checkbox (("TemperatureEn" + vrayLLister.count as string) as name) "" \
				paramStr:("checked:" + (((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1].baseObject #color_mode) == 1) as string) + \
				" offset:[188,"+ (-22+ vrayLLister.yOffset) as string + "] width:15 enabled:" + colorEn as string)
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("TemperatureEn" + vrayLLister.count as string) as name)
			
			-- Color Temperature
			vrayLLister.maxLightsRC.addControl #spinner (("Temperature" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[0,30000.0," + ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #color_temperature) as string) + "] type:#float " + \
				"fieldwidth:45 align:#left offset:[202,"+ (-21+ vrayLLister.yOffset) as string + "]" + \
				" enabled:" + ((vrayLLister.LightIndex[vrayLLister.count][1].baseobject.color_mode == 1) and colorEn) as string)
			vrayLLister.maxLightsRC.addHandler (("Temperature" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #color_temperature val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("Temperature" + vrayLLister.count as string) as name)
			vrayLLister.maxLightsRC.addHandler (("TemperatureEn" + vrayLLister.count as string) as name) #'changed state' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1].baseobject #color_mode (if state then 1 else 0) \n" + \
								"Temperature" + vrayLLister.count as string + ".enabled = state \n" + \
								"LightCol" + vrayLLister.count as string + ".enabled = not state \n" + \
								"LightCol" + vrayLLister.count as string + ".color = vrayLLister.getLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #color")
			
			-- Power Units
			local powerUnitsEn = (not vrayLLister.LightIndex[vrayLLister.count][1].skylightPortal)
			vrayLLister.maxLightsRC.addControl #dropDownList (("PowerUnits" + vrayLLister.count as string) as name) "" filter:on\
				paramStr:(" items:#(\"Default (image)\", \"Luminous power (lm)\", \"Luminance (lm/m?/sr)\", \"Radiant power (W)\", \"Radiance (W/m?/sr)\")" + \
								" width:100 offset:[262,"+ (-24+ vrayLLister.yOffset) as string + "] selection:" + \
								(((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #normalizeColor)+1) as string) + \
								" enabled:" + powerUnitsEn as string)
			vrayLLister.maxLightsRC.addHandler (("PowerUnits" + vrayLLister.count as string) as name) #'selected i' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #normalizeColor (i-1) \n" + \
								"LightMult" + vrayLLister.count as string + ".value = vrayLLister.getLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #multiplier")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("PowerUnits" + vrayLLister.count as string) as name)
			
			-- Shadow On/Off
			local shadowsEn = (not vrayLLister.LightIndex[vrayLLister.count][1].skylightPortal)
			
			vrayLLister.maxLightsRC.addControl #checkbox (("LightShdOn" + vrayLLister.count as string) as name) "" \
				paramStr:("checked:" + (vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1].baseObject #castShadows as string)+ \
				" offset:[376,"+ (-23+ vrayLLister.yOffset) as string + "] width:15 enabled:" + shadowsEn as string)
			vrayLLister.maxLightsRC.addHandler (("LightShdOn" + vrayLLister.count as string) as name) #'changed state' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1].baseobject #castShadows state")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightShdOn" + vrayLLister.count as string) as name)
			
			--Subdivs
			vrayLLister.maxLightsRC.addControl #spinner (("Subdivs" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[1,1000," + ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #subdivs) as string) + "] type:#integer " + \
				"fieldwidth:45 align:#left offset:[406,"+ (-21+ vrayLLister.yOffset) as string + "]")
			vrayLLister.maxLightsRC.addHandler (("Subdivs" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #subdivs val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("Subdivs" + vrayLLister.count as string) as name)
			
			--Shadow Bias
			vrayLLister.maxLightsRC.addControl #spinner (("ShadowBias" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[-1000000000.0,1000000000.0," + ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #shadowBias) as string) + "] type:#worldunits " + \
				"fieldwidth:45 align:#left offset:[464,"+ (-21+ vrayLLister.yOffset) as string + "]")
			vrayLLister.maxLightsRC.addHandler (("ShadowBias" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #shadowBias val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("ShadowBias" + vrayLLister.count as string) as name)
			
			-- Invisible
			local invisibleEn = (not vrayLLister.LightIndex[vrayLLister.count][1].skylightPortal)
			local invisibleTmp = (vrayLLister.LightIndex[vrayLLister.count][1].invisible)
			vrayLLister.maxLightsRC.addControl #checkbox (("InvisibleOn" + vrayLLister.count as string) as name) "" \
				paramStr:("checked:" + invisibleTmp as string + " offset:[532,"+ (-20+ vrayLLister.yOffset) as string + "] width:15" + \
				" enabled:" + invisibleEn as string)
			vrayLLister.maxLightsRC.addHandler (("InvisibleOn" + vrayLLister.count as string) as name) #'changed state' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1].baseobject #invisible state")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("InvisibleOn" + vrayLLister.count as string) as name)
			
			-- Skylight mode
			skylightTmp = if (vrayLLister.LightIndex[vrayLLister.count][1].skylightPortal) then (
									if (vrayLLister.LightIndex[vrayLLister.count][1].simplePortal) then (3)
									else (2))
								else (1)
			
			vrayLLister.maxLightsRC.addControl #dropDownList (("SkylightMode" + vrayLLister.count as string) as name) "" filter:on\
				paramStr:(" items:#(\"None\", \"Normal\", \"Simple\") width:60 offset:[564,"+ (-24+ vrayLLister.yOffset) as string + "]" + \
				"selection:" + (skylightTmp as string))
			vrayLLister.maxLightsRC.addHandler (("SkylightMode" + vrayLLister.count as string) as name) #'selected i' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #skylightPortal (i == 2 or i == 3) \n" + \
								"vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #simplePortal (i == 3) \n" + \
								"LightMult" + vrayLLister.count as string + ".enabled = (i == 1) \n" + \
								"LightCol" + vrayLLister.count as string + ".enabled = ((i == 1) and (not TemperatureEn" + vrayLLister.count as string +".checked)) \n" + \
								"TemperatureEn" + vrayLLister.count as string + ".enabled = (i == 1) \n" + \
								"Temperature" + vrayLLister.count as string + ".enabled = ((i == 1) and (TemperatureEn" + vrayLLister.count as string +".checked)) \n" + \
								"PowerUnits" + vrayLLister.count as string + ".enabled = (i == 1) \n" + \
								"LightShdOn" + vrayLLister.count as string + ".enabled = (i == 1) \n" + \
								"InvisibleOn" + vrayLLister.count as string + ".enabled = (i == 1)")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("SkylightMode" + vrayLLister.count as string) as name)
			
			-- Affect Diffuse
			vrayLLister.maxLightsRC.addControl #checkbox (("AffectDiffOn" + vrayLLister.count as string) as name) "" \
				paramStr:("checked:" + (vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1].baseObject #affect_diffuse as string) + \
				" offset:[628,"+ (-23+ vrayLLister.yOffset) as string + "] width:15")
			vrayLLister.maxLightsRC.addHandler (("AffectDiffOn" + vrayLLister.count as string) as name) #'changed state' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1].baseobject #affect_diffuse state")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("AffectDiffOn" + vrayLLister.count as string) as name)
			
			-- Affect Specular
			vrayLLister.maxLightsRC.addControl #checkbox (("AffectSpecOn" + vrayLLister.count as string) as name) "" \
				paramStr:("checked:" + (vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1].baseObject #affect_specular as string) + \
				" offset:[656,"+ (-20+ vrayLLister.yOffset) as string + "] width:15")
			vrayLLister.maxLightsRC.addHandler (("AffectSpecOn" + vrayLLister.count as string) as name) #'changed state' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1].baseobject #affect_specular state")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("AffectSpecOn" + vrayLLister.count as string) as name)
			
			-- Affect Reflections
			local affectReflectTmp = (vrayLLister.LightIndex[vrayLLister.count][1].affect_reflections)
			vrayLLister.maxLightsRC.addControl #checkbox (("AffectReflectOn" + vrayLLister.count as string) as name) "" \
				paramStr:("checked:" + affectReflectTmp as string + " offset:[684,"+ (-20+ vrayLLister.yOffset) as string + "] width:15")
			vrayLLister.maxLightsRC.addHandler (("AffectReflectOn" + vrayLLister.count as string) as name) #'changed state' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1].baseobject #affect_reflections state")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("AffectReflectOn" + vrayLLister.count as string) as name)
		)
		
		if isVRayIESLight do (
			-- Temperature/Color switch
			vrayLLister.maxLightsRC.addControl #checkbox (("TemperatureEn" + vrayLLister.count as string) as name) "" \
				paramStr:("checked:" + (((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1].baseObject #color_mode) == 1) as string) + \
				" offset:[188,"+ (-22+ vrayLLister.yOffset) as string + "] width:15")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("TemperatureEn" + vrayLLister.count as string) as name)
			
			-- Color Temperature
			vrayLLister.maxLightsRC.addControl #spinner (("Temperature" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[0,30000.0," + ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #color_temperature) as string) + "] type:#float " + \
				"fieldwidth:45 align:#left offset:[202,"+ (-21+ vrayLLister.yOffset) as string + "]" + \
				" enabled:" + (vrayLLister.LightIndex[vrayLLister.count][1].baseobject.color_mode == 1) as string)
			vrayLLister.maxLightsRC.addHandler (("Temperature" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #color_temperature val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("Temperature" + vrayLLister.count as string) as name)
			vrayLLister.maxLightsRC.addHandler (("TemperatureEn" + vrayLLister.count as string) as name) #'changed state' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1].baseobject #color_mode (if state then 1 else 0) \n" + \
								"Temperature" + vrayLLister.count as string + ".enabled = state \n" + \
								"LightCol" + vrayLLister.count as string + ".enabled = not state \n" + \
								"LightCol" + vrayLLister.count as string + ".color = vrayLLister.getLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #color")
			
			-- Shadow On/Off
			vrayLLister.maxLightsRC.addControl #checkbox (("LightShdOn" + vrayLLister.count as string) as name) "" \
				paramStr:("checked:" + (vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1].baseObject #cast_shadows as string)+ \
				" offset:[276,"+ (-20+ vrayLLister.yOffset) as string + "] width:15")
			vrayLLister.maxLightsRC.addHandler (("LightShdOn" + vrayLLister.count as string) as name) #'changed state' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1].baseobject #cast_shadows state")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("LightShdOn" + vrayLLister.count as string) as name)
			
			--Subdivs
			local subdivsEn = ((vrayLLister.LightIndex[vrayLLister.count][1].use_light_shape)!=0)
			vrayLLister.maxLightsRC.addControl #spinner (("Subdivs" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[1,1000," + ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #shape_subdivs) as string) + "] type:#integer " + \
				"fieldwidth:45 align:#left offset:[306,"+ (-21+ vrayLLister.yOffset) as string + "] enabled:" + subdivsEn as string)
			vrayLLister.maxLightsRC.addHandler (("Subdivs" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #shape_subdivs val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("Subdivs" + vrayLLister.count as string) as name)
			
			--Shadow Bias
			vrayLLister.maxLightsRC.addControl #spinner (("ShadowBias" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[-1000000000.0,1000000000.0," + ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #shadow_bias) as string) + "] type:#worldunits " + \
				"fieldwidth:45 align:#left offset:[364,"+ (-21+ vrayLLister.yOffset) as string + "]")
			vrayLLister.maxLightsRC.addHandler (("ShadowBias" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #shadow_bias val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("ShadowBias" + vrayLLister.count as string) as name)
			
			-- Affect Diffuse
			vrayLLister.maxLightsRC.addControl #checkbox (("AffectDiffOn" + vrayLLister.count as string) as name) "" \
				paramStr:("checked:" + (vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1].baseObject #affect_diffuse as string) + \
				" offset:[432,"+ (-20+ vrayLLister.yOffset) as string + "] width:15")
			vrayLLister.maxLightsRC.addHandler (("AffectDiffOn" + vrayLLister.count as string) as name) #'changed state' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1].baseobject #affect_diffuse state")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("AffectDiffOn" + vrayLLister.count as string) as name)
			
			-- Affect Specular
			vrayLLister.maxLightsRC.addControl #checkbox (("AffectSpecOn" + vrayLLister.count as string) as name) "" \
				paramStr:("checked:" + (vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1].baseObject #affect_specular as string) + \
				" offset:[460,"+ (-20+ vrayLLister.yOffset) as string + "] width:15")
			vrayLLister.maxLightsRC.addHandler (("AffectSpecOn" + vrayLLister.count as string) as name) #'changed state' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1].baseobject #affect_specular state")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("AffectSpecOn" + vrayLLister.count as string) as name)
			
			-- Use Light Shape
			local useLShapeTmp = (vrayLLister.LightIndex[vrayLLister.count][1].use_light_shape)
			vrayLLister.maxLightsRC.addControl #dropDownList (("UseLShape" + vrayLLister.count as string) as name) "" filter:on\
				paramStr:(" items:#(\"No\", \"Shadows only\", \"Illumination and shadows\")" + \
								" width:50 offset:[482,"+ (-24+ vrayLLister.yOffset) as string + "] selection:" + \
								(((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #use_light_shape)+1) as string))
			vrayLLister.maxLightsRC.addHandler (("UseLShape" + vrayLLister.count as string) as name) #'selected i' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #use_light_shape (i-1) \n" + \
								"Subdivs" + vrayLLister.count as string + ".enabled = " + "vrayLLister.getLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #use_light_shape!=0")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("UseLShape" + vrayLLister.count as string) as name)
			
			-- Area Speculars
			local areaSpecularsTmp = (vrayLLister.LightIndex[vrayLLister.count][1].area_speculars)
			vrayLLister.maxLightsRC.addControl #checkbox (("AreaSpecularsOn" + vrayLLister.count as string) as name) "" \
				paramStr:("checked:" + areaSpecularsTmp as string + " offset:[554,"+ (-23+ vrayLLister.yOffset) as string + "] width:15")
			vrayLLister.maxLightsRC.addHandler (("AreaSpecularsOn" + vrayLLister.count as string) as name) #'changed state' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1].baseobject #area_speculars state")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("AreaSpecularsOn" + vrayLLister.count as string) as name)
		)
		
		if isVRayAmbientLight do (
		)
		
		if isVRaySun do (
			--Size Multiplier
			vrayLLister.maxLightsRC.addControl #spinner (("SizeMultiplier" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[0.0,1000000000.0," + ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #size_multiplier) as string) + "] type:#worldunits " + \
				"fieldwidth:45 align:#left offset:[158,"+ (-21+ vrayLLister.yOffset) as string + "]")
			vrayLLister.maxLightsRC.addHandler (("SizeMultiplier" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #size_multiplier val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("SizeMultiplier" + vrayLLister.count as string) as name)
			
			--Shadow Subdivs
			vrayLLister.maxLightsRC.addControl #spinner (("Subdivs" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[1,1000," + ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #shadow_subdivs) as string) + "] type:#integer " + \
				"fieldwidth:45 align:#left offset:[216,"+ (-21+ vrayLLister.yOffset) as string + "]")
			vrayLLister.maxLightsRC.addHandler (("Subdivs" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #shadow_subdivs val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("Subdivs" + vrayLLister.count as string) as name)
			
			--Shadow Bias
			vrayLLister.maxLightsRC.addControl #spinner (("ShadowBias" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[-1000000000.0,1000000000.0," + ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #shadow_bias) as string) + "] type:#worldunits " + \
				"fieldwidth:45 align:#left offset:[274,"+ (-21+ vrayLLister.yOffset) as string + "]")
			vrayLLister.maxLightsRC.addHandler (("ShadowBias" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #shadow_bias val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("ShadowBias" + vrayLLister.count as string) as name)
			
			-- Invisible
			vrayLLister.maxLightsRC.addControl #checkbox (("InvisibleOn" + vrayLLister.count as string) as name) "" \
				paramStr:("checked:" + (vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1].baseObject #invisible as string) + \
								" offset:[342,"+ (-20+ vrayLLister.yOffset) as string + "] width:15")
			vrayLLister.maxLightsRC.addHandler (("InvisibleOn" + vrayLLister.count as string) as name) #'changed state' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1].baseobject #invisible state")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("InvisibleOn" + vrayLLister.count as string) as name)
			
			--Turbidity
			vrayLLister.maxLightsRC.addControl #spinner (("Turbidity" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[2.0,1000000000.0," + ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #turbidity) as string) + "] type:#float " + \
				"fieldwidth:45 align:#left offset:[372,"+ (-21+ vrayLLister.yOffset) as string + "]")
			vrayLLister.maxLightsRC.addHandler (("Turbidity" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #turbidity val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("Turbidity" + vrayLLister.count as string) as name)
			
			--Ozone
			vrayLLister.maxLightsRC.addControl #spinner (("Ozone" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[0.0,1.0," + ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #ozone) as string) + "] type:#float " + \
				"fieldwidth:45 align:#left offset:[430,"+ (-21+ vrayLLister.yOffset) as string + "]")
			vrayLLister.maxLightsRC.addHandler (("Ozone" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #ozone val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("Ozone" + vrayLLister.count as string) as name)
			
			--Photon Emit Radius
			vrayLLister.maxLightsRC.addControl #spinner (("PhotonEmitRadius" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[0.0,1000000000.0," + ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #photon_emit_radius) as string) + "] type:#worldunits " + \
				"fieldwidth:45 align:#left offset:[488,"+ (-21+ vrayLLister.yOffset) as string + "]")
			vrayLLister.maxLightsRC.addHandler (("PhotonEmitRadius" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #photon_emit_radius val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("PhotonEmitRadius" + vrayLLister.count as string) as name)
			
			--Sky Model
			vrayLLister.maxLightsRC.addControl #dropDownList (("SkyModel" + vrayLLister.count as string) as name) "" filter:on\
				paramStr:(" items:#(\"Preetham et al.\", \"CIE Clear\", \"CIE Overcast\") width:100 offset:[548,"+ (-24+ vrayLLister.yOffset) as string + "]" + \
								" selection:" + (((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #sky_model) + 1) as string))
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("SkyModel" + vrayLLister.count as string) as name)
			
			--Indirect Horizont Illumination
			vrayLLister.maxLightsRC.addControl #spinner (("HorizIllumination" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[0.0,50000.0," + ((vrayLLister.getLightProp vrayLLister.LightIndex[vrayLLister.count][1] #indirect_horiz_illum) as string) + "] type:#float " + \
				"fieldwidth:45 align:#left offset:[650,"+ (-24+ vrayLLister.yOffset) as string + "] enabled:" + (vrayLLister.LightIndex[vrayLLister.count][1].sky_model > 0) as string)
			vrayLLister.maxLightsRC.addHandler (("HorizIllumination" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #indirect_horiz_illum val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("HorizIllumination" + vrayLLister.count as string) as name)
			vrayLLister.maxLightsRC.addHandler (("SkyModel" + vrayLLister.count as string) as name) #'selected i' filter:on \
				codeStr:("vrayLLister.setLightProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #sky_model (i - 1) \n" + \
								"horizIllumination" + vrayLLister.count as string + ".enabled = (i > 1)")
		)
		
		--Caustics subdivs
		if (hasCausticsSubdivs) then (
			local causticSubdivsTmp=getUserProp vrayLLister.LightIndex[vrayLLister.count][1] #VRay_Caustics_Subdivs
			local causticSubdivsX=case lightClassName of (
				#VRayLight:			712
				#VRayIES:				588
				#VRayAmbientLight:	186
				#VRaySun:				710
				default:					748
			)
			local causticSubdivsY=case lightClassName of (
				#VRayLight:			-21
				#VRayIES:				-21
				#VRayAmbientLight:	-23
				#VRaySun:				-21
				default:					-21
			)
			if (causticSubdivsTmp==undefined) do (causticSubdivsTmp=1500)
			vrayLLister.maxLightsRC.addControl #spinner (("CausticSubdivs" + vrayLLister.count as string) as name) "" \
				paramStr:("range:[1,2000000000," + causticSubdivsTmp as string + "] type:#integer " + \
				"fieldwidth:45 align:#left offset:[" + (causticSubdivsX as String) + ","+ (causticSubdivsY + vrayLLister.yOffset) as string + "]")
			vrayLLister.maxLightsRC.addHandler (("CausticSubdivs" + vrayLLister.count as string) as name) #'changed val' filter:on \
				codeStr:("setUserProp vrayLLister.LightIndex[" + vrayLLister.count as string + "][1] #VRay_Caustics_Subdivs val")
			append vrayLLister.UIControlList[2][vrayLLister.Count] (("CausticSubdivs" + vrayLLister.count as string) as name)
		)
		
		if heapFree < 1000000 do heapsize += 1000000 -- AB Jun 20, 2002
	) -- end CreateControls

	local CanAddControls = true
	local LightCountLimit = 150 -- this sets the maximum number of lights displayed

	if vrayLLister.VRayLightsList.count > 0 and CanAddControls do
	(
		-- Start Localization
		
		vrayLLister.maxLightsRC.addControl #label #VRayLightTitle "V-Ray Lights" paramStr:" align:#left"
		
		WriteTitle labels:titleTemplates.vrayLights
		
		-- End Localization
		for x in 1 to vrayLLister.VRayLightsList.count where (CanAddControls = vrayLLister.count < LightCountLimit) do
		(
			append vrayLLister.LightIndex vrayLLister.VRayLightsList[x]
			createControls hasMultiplier:true hasColor:true isVRayLight:true hasCausticsSubdivs:true
			vrayLLister.count += 1
			vrayLLister.LightInspectorSetup.pbar.value = vrayLLister.count*100/vrayLLister.totalLightCount
		) -- end For i in VRay Lights
	)
	
	if vrayLLister.VRayIESLightsList.count > 0 and CanAddControls do
	(
		-- Start Localization
		
		vrayLLister.maxLightsRC.addControl #label #VRayIESLightTitle "V-Ray IES Lights" paramStr:" align:#left"
		
		WriteTitle labels:titleTemplates.vrayIESLights
		
		-- End Localization
		for x in 1 to vrayLLister.VRayIESLightsList.count where (CanAddControls = vrayLLister.count < LightCountLimit) do
		(
			append vrayLLister.LightIndex vrayLLister.VRayIESLightsList[x]
			createControls hasMultiplier:true hasColor:true isVRayIESLight:true hasCausticsSubdivs:true
			vrayLLister.count += 1
			vrayLLister.LightInspectorSetup.pbar.value = vrayLLister.count*100/vrayLLister.totalLightCount
		) -- end For i in VRay Lights
	)
	
	if vrayLLister.VRayAmbientLightsList.count > 0 and CanAddControls do
	(
		-- Start Localization
		
		vrayLLister.maxLightsRC.addControl #label #VRayAmbientLightTitle "V-Ray Ambient Lights" paramStr:" align:#left"
		
		WriteTitle labels:titleTemplates.vrayAmbientLights
		
		-- End Localization
		for x in 1 to vrayLLister.VRayAmbientLightsList.count where (CanAddControls = vrayLLister.count < LightCountLimit) do
		(
			append vrayLLister.LightIndex vrayLLister.VRayAmbientLightsList[x]
			createControls hasMultiplier:true hasColor:true isVRayAmbientLight:true hasCausticsSubdivs:true
			vrayLLister.count += 1
			vrayLLister.LightInspectorSetup.pbar.value = vrayLLister.count*100/vrayLLister.totalLightCount
		) -- end For i in VRay Lights
	)
	
	if vrayLLister.VRaySunSkyLightsList.count > 0 and CanAddControls do
	(
		-- Start Localization
		
		vrayLLister.maxLightsRC.addControl #label #VRaySunSkyLightTitle "V-Ray SunSky Lights" paramStr:" align:#left"
		
		WriteTitle labels:titleTemplates.vraySunSkyLights
		
		-- End Localization
		
		for x in 1 to vrayLLister.VRaySunSkyLightsList.count where (CanAddControls = vrayLLister.count < LightCountLimit) do
		(
			append vrayLLister.LightIndex vrayLLister.VRaySunSkyLightsList[x]
			createControls hasMultiplier:true isVRaySun:true hasCausticsSubdivs:true
			vrayLLister.count += 1
			vrayLLister.LightInspectorSetup.pbar.value = vrayLLister.count*100/vrayLLister.totalLightCount
		) -- end For i in VRay Lights
	)
	
	if vrayLLister.maxLightsList.count > 0 do
	(
		-- Start Localization
		
		vrayLLister.maxLightsRC.addControl #label #title "Standard Lights" paramStr:" align:#left"
		
		WriteTitle labels:titleTemplates.maxLights
		
		-- End Localization
		
		for x in 1 to vrayLLister.maxLightsList.count where (CanAddControls = vrayLLister.count < LightCountLimit) do
		(
		
		append vrayLLister.LightIndex vrayLLister.maxLightsList[x]
		createControls hasMultiplier:true hasColor:true hasShadow:true hasDecay:true hasCausticsSubdivs:true
		vrayLLister.count += 1
		vrayLLister.LightInspectorSetup.pbar.value = vrayLLister.count*100/vrayLLister.totalLightCount
		
		) -- end For i in MAXLights
	) -- end MAXLights
	
	if vrayLLister.LSLightsList.count > 0 and CanAddControls do -- AB: Jun 20, 2002
	(
		-- Start Localization
		
		vrayLLister.maxLightsRC.addControl #label #LStitle "Photometric Lights" paramStr:" align:#left"
		
		WriteTitle labels:titleTemplates.lsLights
		
		-- End Localization
		
		for x in 1 to vrayLLister.LSLightsList.count where (CanAddControls = vrayLLister.count < LightCountLimit) do
		(
		append vrayLLister.LightIndex vrayLLister.LSLightsList[x]
		createControls hasMultiplier:true hasColor:true hasShadow:true hasSize:true
		vrayLLister.count += 1
		vrayLLister.LightInspectorSetup.pbar.value = vrayLLister.count*100/vrayLLister.totalLightCount
		) -- end For i in LS Lights
	) -- end if LS Lights

	if vrayLLister.miLightsList.count > 0 and CanAddControls do -- AB: Jun 20, 2002
	(
		-- Start Localization
		
		vrayLLister.maxLightsRC.addControl #label #miLightstitle "mental ray Area Lights" paramStr:" align:#left"
		
		WriteTitle labels:titleTemplates.miLights
		
		-- End Localization
		
		for x in 1 to vrayLLister.miLightsList.count  where (CanAddControls = vrayLLister.count < LightCountLimit) do
		(
		append vrayLLister.LightIndex vrayLLister.miLightsList[x]
		createControls hasMultiplier:true hasColor:true hasShadow:true hasDecay:true
		vrayLLister.count += 1
		vrayLLister.LightInspectorSetup.pbar.value = vrayLLister.count*100/vrayLLister.totalLightCount
		) -- end For i in miLightsList
	) -- end miLightsList

	if vrayLLister.LuminairesList.count > 0 and CanAddControls do -- AB: Jun 20, 2002
	(
		-- Start Localization
		
		vrayLLister.maxLightsRC.addControl #label #Luminairetitle "Luminaires" paramStr:" align:#left"
		
		WriteTitle labels:titleTemplates.luminaires
		
		-- End Localization
		
		for x in 1 to vrayLLister.LuminairesList.count  where (CanAddControls = vrayLLister.count < LightCountLimit) do
		(
		append vrayLLister.LightIndex vrayLLister.LuminairesList[x]
		createControls hasMultiplier:true hasColor:true isLuminaire:true
		vrayLLister.count += 1
		vrayLLister.LightInspectorSetup.pbar.value = vrayLLister.count*100/vrayLLister.totalLightCount
		) -- end For i in LS Lights
	) -- end Luminaires

	if vrayLLister.SunLightsList.count > 0 and CanAddControls do
	(
		-- Start Localization
		
		vrayLLister.maxLightsRC.addControl #label #Suntitle "Sun Lights" paramStr:" align:#left"
		
		WriteTitle labels:titleTemplates.sunLights
		
		-- End Localization
		
		for x in 1 to vrayLLister.SunLightsList.count where (CanAddControls = vrayLLister.count < LightCountLimit) do
		(
		append vrayLLister.LightIndex vrayLLister.SunLightsList[x]
		createControls hasMultiplier:true hasColor:true hasShadow:true
		vrayLLister.count += 1
		vrayLLister.LightInspectorSetup.pbar.value = vrayLLister.count*100/vrayLLister.totalLightCount
		) -- end For i in Sun Lights
	)


	if vrayLLister.SkyLightsList.count > 0 and CanAddControls do
	(
		-- Start Localization
		
		vrayLLister.maxLightsRC.addControl #label #Skytitle "Sky Lights" paramStr:" align:#left"
		
		WriteTitle labels:titleTemplates.skyLights
		
		-- End Localization
		
		for x in 1 to vrayLLister.SkyLightsList.count where (CanAddControls = vrayLLister.count < LightCountLimit) do
		(
		append vrayLLister.LightIndex vrayLLister.SkyLightsList[x]
		createControls hasMultiplier:true hasColor:true
		vrayLLister.count += 1
		vrayLLister.LightInspectorSetup.pbar.value = vrayLLister.count*100/vrayLLister.totalLightCount
		) -- end For i in Sky Lights
	)
	
	if vrayLLister.mrSkyLightsList.count > 0 and CanAddControls do
	(
		-- Start Localization
		
		vrayLLister.maxLightsRC.addControl #label #mrSkytitle "mr Sky Lights" paramStr:" align:#left"
		
		WriteTitle labels:titleTemplates.mrSkyLights
		
		-- End Localization
		
		for x in 1 to vrayLLister.mrSkyLightsList.count where (CanAddControls = vrayLLister.count < LightCountLimit) do
		(
		append vrayLLister.LightIndex vrayLLister.mrSkyLightsList[x]
		createControls hasMultiplier:true isMRSky:true
		vrayLLister.count += 1
		vrayLLister.LightInspectorSetup.pbar.value = vrayLLister.count*100/vrayLLister.totalLightCount
		) -- end For i in mr Sky Lights
	)
	
	if vrayLLister.mrSunLightsList.count > 0 and CanAddControls do
	(
		-- Start Localization
		
		vrayLLister.maxLightsRC.addControl #label #mrSuntitle "mr Sun Lights" paramStr:" align:#left"
		
		WriteTitle labels:titleTemplates.mrSunLights
		
		-- End Localization
		
		for x in 1 to vrayLLister.mrSunLightsList.count where (CanAddControls = vrayLLister.count < LightCountLimit) do
		(
		append vrayLLister.LightIndex vrayLLister.mrSunLightsList[x]
		createControls hasMultiplier:true isMRSun:true
		vrayLLister.count += 1
		vrayLLister.LightInspectorSetup.pbar.value = vrayLLister.count*100/vrayLLister.totalLightCount
		) -- end For i in mr Sun Lights
	)
	
	if vrayLLister.mrSkyPortalLightsList.count > 0 and CanAddControls do
	(
		-- Start Localization
		
		vrayLLister.maxLightsRC.addControl #label #mrSkyPortaltitle "mr Sky Portal Lights" paramStr:" align:#left"
		
		WriteTitle labels:titleTemplates.mrSkyPortalLights
		
		-- End Localization
		
		for x in 1 to vrayLLister.mrSkyPortalLightsList.count where (CanAddControls = vrayLLister.count < LightCountLimit) do
		(
		append vrayLLister.LightIndex vrayLLister.mrSkyPortalLightsList[x]
		createControls hasMultiplier:true hasColor:true isMRSkyPortal:true
		vrayLLister.count += 1
		vrayLLister.LightInspectorSetup.pbar.value = vrayLLister.count*100/vrayLLister.totalLightCount
		) -- end For i in mr_Sky_Portal Lights
	)
	
	-- Callback Handlers
	
	vrayLLister.maxLightsRC.addHandler "maxLightsRollout" #'open' filter:off \
		codeStr:("vrayLLister.DeleteCallback = when vrayLLister.UIControlList[1] deleted obj do" + \
		"\n(\nlocal foundMe = findItem vrayLLister.UIControlList[1] obj\n" + \
		"if foundMe > 0 do\n(\n" + \
		"vrayLLister.disableUIElements vrayLLister.UIControlList[2][foundMe]\n)\n)")

	vrayLLister.maxLightsRC.addHandler "maxLightsRollout" #'close' filter:off \
		codeStr:"DeleteChangeHandler vrayLLister.DeleteCallback"
		
	-- Removing the Refresh/ProgressBar
	
	vrayLLister.LightInspectorSetup.pbar.value = 0
	vrayLLister.LightInspectorSetup.pbar.visible = false
	
	-- AB: Jun 20, 2002
	-- Add a new control that tells users to use the selection mode if they had too many lights in the list
	
	if not CanAddControls and vrayLLister.maxLightsRC.str != "" do 
		vrayLLister.maxLightsRC.addControl #label #lbLimitControls "The maximum number of Lights has been reached, please select fewer lights and use the Selected Lights option" \
			paramStr:" align:#center offset:[0,10]"
	
	if vrayLLister.maxLightsRC.str != "" then vrayLLister.maxLightsRC.end() else undefined
)

vrayLLister.CreateLightRollout = CreateLightRollout

vrayLLister.GlobalLightParameters =
(local GlobalLightParameters
rollout GlobalLightParameters "General Settings"
(
	
	-- Start Localization
	
	radioButtons rbtoggle labels:#("Selected Lights","All Lights")
	
	local lblOffset = -18 + (if vrayLListeryOffset == undefined then 0 else vrayLListerYOffset)
	
	label lb01 "On" align:#left offset:[-6,-3]
	label lb03 "Multiplier"  align:#left offset:[12,lblOffset]
	label lb03a "Multiplier (%)" align:#left offset:[81,lblOffset] visible:(ProductAppID == #vizR)
	label lb04 "Color"  align:#left offset:[67,lblOffset]
	label lb05 "Shadows"  align:#left offset:[96,lblOffset]
	label lb06 "Map Size"  align:#left offset:[229,lblOffset] visible:(ProductAppID != #VIZR)
	label lb07 "Bias"  align:#left offset:[286,lblOffset] visible:(ProductAppID != #VIZR)
	label lb08 "Sm.Range"  align:#left offset:[337,lblOffset] visible:(ProductAppID != #VIZR)
	label lb09 "Trans."  align:#left offset:[390,lblOffset] visible:(ProductAppID != #VIZR)
	label lb10 "Int."  align:#left offset:[424,lblOffset] visible:(ProductAppID != #VIZR)
	label lb11 "Qual."  align:#left offset:[461,lblOffset] visible:(ProductAppID != #VIZR)
	label lb12 "Decay"  align:#left offset:[505,lblOffset] visible:(ProductAppID != #VIZR)
	label lb13 "Start"  align:#left offset:[586,lblOffset] visible:(ProductAppID != #VIZR)
	label lb14 "Length"  align:#left offset:[643,lblOffset] visible:(ProductAppID != #VIZR)
	label lb15 "Width/Radius"  align:#left offset:[699,lblOffset] visible:(ProductAppID != #VIZR)
	-- End Localization

	checkBox lightOn "" width:15 checked:true offset:[-4,0]
	spinner lightInten "" fieldWidth:45 type:#float range:[-10000,10000,1500] align:#left offset:[10,-20+ vrayLListeryOffset] visible:(ProductAppID == #vizR)
	checkBox lightMultOn "" width:15 checked:false offset:[81,-20+ vrayLListeryOffset] visible:(ProductAppID == #vizR)
	spinner lightMult "" fieldWidth:45 type:#float range:[-10000,10000,1.0] align:#left offset:[10,-20+ vrayLListeryOffset]
	colorPicker lightCol "" width:25 color:white offset:[66,-23+ vrayLListeryOffset]
	checkBox shadowOn "" width:15 checked:true offset:[96,-22+ vrayLListeryOffset]
	dropDownList shadowType width:115 items:vrayLLister.ShadowPluginsName offset:[113,-23+ vrayLListeryOffset] visible:(ProductAppID != #vizR)
	spinner ShadowMapSize "" fieldWidth:45 type:#integer range:[0,10000,512] align:#left offset:[227,-24+ vrayLListeryOffset] visible:(ProductAppID != #VIZR)
	spinner ShadowBias "" fieldWidth:45 type:#float range:[0,10000,0.5] align:#left offset:[284,-21+ vrayLListeryOffset] visible:(ProductAppID != #VIZR)
	spinner ShadowSmpRange "" fieldWidth:45 type:#float range:[0,50,4.0] align:#left offset:[341,-21+ vrayLListeryOffset] visible:(ProductAppID != #VIZR)
	checkBox shadowTrans "" width:15 offset:[401,-20+ vrayLListeryOffset] visible:(ProductAppID != #VIZR)
	spinner ShadowInteg "" fieldWidth:30 type:#integer range:[0,15,1] align:#left offset:[415,-21+ vrayLListeryOffset] visible:(ProductAppID != #VIZR)
	spinner ShadowQual 	"" fieldWidth:30 type:#Integer range:[0,15,2] align:#left offset:[459,-21+ vrayLListeryOffset] visible:(ProductAppID != #VIZR)
	dropDownList lightDecay width:80 items:vrayLLister.decayStrings offset:[504,-23+ vrayLListeryOffset] visible:(ProductAppID != #VIZR)
	spinner lightDecaySt "" fieldWidth:45 type:#float range:[0,10000,40] align:#left offset:[584,-24+ vrayLListeryOffset] visible:(ProductAppID != #VIZR)
	spinner lightLength "" fieldWidth:45 type:#float range:[0,10000,40] align:#left offset:[641,-21+ vrayLListeryOffset] visible:(ProductAppID != #VIZR)
	spinner lightWidth "" fieldWidth:45 type:#float range:[0,10000,40] align:#left offset:[697,-21+ vrayLListeryOffset] visible:(ProductAppID != #VIZR)

	group ""
	(
	
	-- Start Localization
	
	colorpicker gTint "Global Tint:" color:lightTintColor visible:(ProductAppID != #VIZR) offset:[180,0]
	spinner gLevel "Global Level:" range:[0,10000,lightLevel]  fieldWidth:45 align:#left offset:[290,-22+ vrayLListeryOffset] visible:(ProductAppID != #VIZR)
	colorPicker cpAmbient "Ambient Color" color:ambientColor offset:[420,-24+ vrayLListeryOffset] visible:(ProductAppID != #VIZR)
	
	-- End Localization
	
	)
	
	on GlobalLightParameters open do
	(
		if ProductAppID == #vizR do
		(
			lightmult.range = [0,1000000.0,100.0]
			lb03.text = "Intensity (cd)"
			lb04.pos = lb04.pos + [88,0]
			lb05.pos = lb05.pos + [87,0]
			lightmult.pos = lightMult.pos + [87,0]
			lightCol.pos = lightCol.pos + [88,0]
			shadowOn.pos = shadowOn.pos + [88,0]
		)
		dialogUp = true
	)
	
	on GlobalLightParameters close do
	(
		dialogUp = false
		updateToolbarButtons()
	)
	
	on gtint changed val do lightTintColor = val
	on glevel changed val do lightLevel = val
	on cpAmbient changed val do ambientColor = val
	
	fn setCollectionProperty prop val CreateUndo:true =
	(
		if createUndo then
		(
			undo "VRayLightLister" on 
			(
				local myCollection = if rbToggle.state == 1 then Selection else Lights
				for i in myCollection do 
				(
					setLightProp i.baseobject prop val
					setShdProp i.baseObject prop val
				)
			)
		)
		else
		(
			local myCollection = if rbToggle.state == 1 then Selection else Lights
			for i in myCollection do
			(
				setLightProp i.baseobject prop val
				setShdProp i.baseObject prop val
			)
		)
	)
	
	on lightOn changed state do setCollectionProperty #enabled state
	on lightCol changed val do 
	(
		setCollectionProperty #color val CreateUndo:false
		setCollectionProperty #filter_Color val CreateUndo:false
		setCollectionProperty #FilterColor val CreateUndo:false
	)
	on shadowOn changed state do setCollectionProperty #castShadows state
	on shadowTrans changed state do setCollectionProperty #shadow_transparent state
	on shadowInteg changed val do setCollectionProperty #pass1 val CreateUndo:false
	on shadowQual changed val do setCollectionProperty #pass2 val CreateUndo:false
	on lightWidth changed val do 
	(
		setCollectionProperty #light_Width val CreateUndo:false
		setCollectionProperty #light_Radius val CreateUndo:false
	)
	on lightLength changed val do setCollectionProperty #length val CreateUndo:false
	on lightMult changed val do 
	(
		setCollectionProperty #multiplier val CreateUndo:false
		setCollectionProperty #intensity val CreateUndo:false
		setCollectionProperty #dimmer val CreateUndo:false
		setCollectionProperty #power val CreateUndo:false
		setCollectionProperty #intensity_multiplier val CreateUndo:false
	)
	on lightMultOn changed state do setCollectionProperty #useMultiplier state
	on lightInten changed val do setCollectionProperty #intensity val CreateUndo:false
	on ShadowMapSize changed val do (
		setCollectionProperty #mapSize val CreateUndo:false
		setCollectionProperty #resolution val CreateUndo:false
	)
	on ShadowSmpRange changed val do setCollectionProperty #sampleRange val CreateUndo:false
	on lightDecaySt changed val do setCollectionProperty #decayRadius val CreateUndo:false
	on lightDecay selected d do setCollectionProperty #attenDecay d
	on shadowBias changed val do
	(
		setCollectionProperty #mapBias val CreateUndo:false
		setCollectionProperty #ray_Bias val CreateUndo:false
		setCollectionProperty #raytraceBias val CreateUndo:false
		setCollectionProperty #bias val CreateUndo:false
		setCollectionProperty #shadowBias val CreateUndo:false
		setCollectionProperty #shadow_bias val CreateUndo:false
	)
	
	on shadowType selected j do
	(
		local myCollection = if rbToggle.state == 1 then Selection else Lights
		for i in myCollection do setLightProp i.baseobject #shadowGenerator (vrayLLister.ShadowPlugins[j]())
	)

) -- end Rollout
) -- end structDef
local lblSelector = #("General Settings","All Lights","Selected Lights","Selection Set:") -- localize

vrayLLister.LightInspectorSetup =
(local LightInspectorSetup
rollout LightInspectorSetup "Configuration" -- Localize
(
	radiobuttons rolloutSelector labels:lblSelector across:2 align:#center offset:[150,0]
	dropdownlist setSelector width:100 align:#center offset:[-28,-2]
	checkbutton btnReload "Refresh" align:#right offset:[0,-24] height:16 highlightColor:(color ((colorman.getcolor #activecommand).x *255) ((colorman.getcolor #activecommand).y *255)((colorman.getcolor #activecommand).z *255)) checked:false -- Localize
	progressBar pbar width:134 pos:(btnReload.pos - [80,-1])
	
	local setChanged = false
	
	fn setSelectorUpdate selected:undefined = (
		local setNames = #()
		for i = 1 to selectionSets.count do (
			append setNames selectionSets[i].name
		)
		sort setNames
		setSelector.items = setNames
		
		if (selected != undefined) do (
			local lastIndex = findItem setSelector.items selected
			if (lastIndex == 0) then (lastIndex = 1)
			setSelector.selection = lastIndex
		)
	)
	
	on rolloutSelector changed state do
	(
		rolloutSelector.state = state
		case rolloutSelector.state of
		(
			1:	(
				try(RemoveRollout vrayLLister.GlobalLightParameters vrayLLister.LightInspectorFloater) catch()
				try(RemoveRollout vrayLLister.LightInspectorListRollout vrayLLister.LightInspectorFloater) catch()
				addRollout vrayLLister.GlobalLightParameters vrayLLister.LightInspectorFloater
				btnReload.visible = false
			)
			2:	(
				btnReload.visible = false
				try(RemoveRollout vrayLLister.GlobalLightParameters vrayLLister.LightInspectorFloater) catch()
				try(RemoveRollout vrayLLister.LightInspectorListRollout vrayLLister.LightInspectorFloater) catch()
				vrayLLister.LightInspectorListRollout = vrayLLister.CreateLightRollout (Lights as array + helpers as array)
				if vrayLLister.LightInspectorListRollout != undefined do
					addRollout vrayLLister.LightInspectorListRollout vrayLLister.LightInspectorFloater
				vrayLLister.maxLightsRC = undefined
				gc light:true
				btnReload.visible = true
			)
			3:	(
				btnReload.visible = false
				try(RemoveRollout vrayLLister.GlobalLightParameters vrayLLister.LightInspectorFloater) catch()
				try(RemoveRollout vrayLLister.LightInspectorListRollout vrayLLister.LightInspectorFloater) catch()
				vrayLLister.LightInspectorListRollout = vrayLLister.CreateLightRollout Selection
				if vrayLLister.LightInspectorListRollout != undefined do
					addRollout vrayLLister.LightInspectorListRollout vrayLLister.LightInspectorFloater
				vrayLLister.maxLightsRC = undefined
				gc light:true
				btnReload.visible = true
			)
			4: (
				btnReload.visible = false
				try(RemoveRollout vrayLLister.GlobalLightParameters vrayLLister.LightInspectorFloater) catch()
				try(RemoveRollout vrayLLister.LightInspectorListRollout vrayLLister.LightInspectorFloater) catch()
				if (setSelector.selection != 0) do (
					vrayLLister.LightInspectorListRollout = vrayLLister.CreateLightRollout (selectionSets[setSelector.selected])
					if vrayLLister.LightInspectorListRollout != undefined do
						addRollout vrayLLister.LightInspectorListRollout vrayLLister.LightInspectorFloater
				)
				vrayLLister.maxLightsRC = undefined
				gc light:true
				btnReload.visible = true
			)
		)
	)
	
	on btnReload changed state do
	(
		if (selectionSets.count > 0) do (
			local lastSetName = if (setSelector.selection> 0) then (setSelector.items[setSelector.selection]) else (undefined)
			setSelectorUpdate selected:lastSetName
		)
		
		rolloutSelector.changed rolloutSelector.state
		btnReload.checked = false
	)
	
	on setSelector selected i do (
		setChanged = true
		if (rolloutSelector.state == 4) do (
			rolloutSelector.changed rolloutSelector.state
		)
	)
	
	on LightInspectorSetup close do
	(
		callBacks.RemoveScripts id:#vrayLListerRollout
		setIniSetting "$plugCfg/vrayLLister.cfg" "General" "DialogPos" (vrayLLister.LightInspectorFloater.Pos as string) -- do not localize
		setIniSetting "$plugCfg/vrayLLister.cfg" "General" "DialogSize" (vrayLLister.LightInspectorFloater.Size as string) -- do not localize
		setIniSetting "$plugCfg/vrayLLister.cfg" "General" "LastState" (rolloutSelector.state as string) -- do not localize
		if (setChanged) do setIniSetting "$plugCfg/vrayLLister.cfg" "General" "LastSet" (setSelector.selected as string) -- do not localize
		
		dialogUp = false
		updateToolbarButtons()
	)
	
	on LightInspectorSetup open do
	(
		if (selectionSets.count > 0) do (
			local lastSetName = (getIniSetting "$plugCfg/vrayLLister.cfg" "General" "LastSet") as string
			setSelectorUpdate selected:lastSetName
		)
		
		pbar.visible = false
		local lastState = (getIniSetting "$plugCfg/vrayLLister.cfg" "General" "LastState") as integer  -- do not localize
		if lastState == 0 do lastState = 2
		if lastState < 5 do
			rolloutSelector.changed lastState
		
		-- Callbacks to remove Floater
		callBacks.AddScript #systemPreReset "CloseRolloutFloater vrayLLister.LightInspectorFloater" id:#vrayLListerRollout  -- do not localize
		callBacks.AddScript #systemPreNew "CloseRolloutFloater vrayLLister.LightInspectorFloater" id:#vrayLListerRollout -- do not localize
		callBacks.AddScript #filePreOpen "CloseRolloutFloater vrayLLister.LightInspectorFloater" id:#vrayLListerRollout -- do not localize
		
		dialogUp = true
		updateToolbarButtons()
	)
	
) -- end Rollout
) -- end StructDef

on execute do
	(

	-- Loading rollout size and position, if available
	
	local dialogPos, dialogSize
	
	dialogPos = execute (getIniSetting "$plugCfg/vrayLLister.cfg" "General" "DialogPos") -- Do not localize
	dialogSize = execute (getIniSetting "$plugCfg/vrayLLister.cfg" "General" "DialogSize") -- Do not localize
	
	if classof DialogPos != Point2 do dialogPos = [200,300]
	if classof DialogSize != Point2 do dialogSize = [840,300]
	
	dialogSize.x = 840
	
	try(closeRolloutFloater vrayLLister.LightInspectorFloater) catch()
	vrayLLister.LightInspectorFloater = newRolloutFloater "V-Ray Light Lister" dialogSize.x dialogSize.y dialogPos.x dialogPos.y
	
	addRollout vrayLLister.LightInspectorSetup vrayLLister.LightInspectorFloater
	dialogUp = true
	)

on closeDialogs do
	(
		try(closeRolloutFloater vrayLLister.LightInspectorFloater) catch( print "Error in LightLister" )	
		dialogUp = false	
	)
on isChecked return
	(
		dialogUp
	)
)
