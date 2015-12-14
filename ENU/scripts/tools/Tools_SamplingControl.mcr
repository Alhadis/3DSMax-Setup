MacroScript SamplingControl
	category: "Tools"
	buttonText: "VRay Sampling Control"
	tooltip: "VRay Sampling Control"
(
	global sliderName	= "SampleSlider";
	
	-- Creates and returns a new sliderManipulator to be used as the Sampling Control
	function createSamplingControl = (
		return	sliderManipulator	\
					name:		sliderName			\
					sldName:	"Light Samples"		\
					xPos:		0.093				\
					yPos:		0.97				\
					width:		160.0				\
					snapVal:	1					\
					minVal:		1					\
					value:		8
	)

	-- Returns the VRayLight Sampling Control
	function getSampleSlider = (
		for node in $* do(
			if(node.name == sliderName) then
				return node;
		)
		return undefined;
	)


	-- Returns TRUE if node is a VRay Light
	function isVRayLight node = (
		local type	= classOf node;
		return(
				type == VRayLight	or
				type == VRayIES		or
				type == VRaySun
				)
	)
	
	
	-- Returns an array composed of each of the VRay Lights found in the scene
	function getVRayLights = (
		local output	= #();
		
		for node in $* do(
			if(isVRayLight(node)) then
				output	= append output node
		)
		return output;
	)


	-- Connects the Subdivisions property for each Vray light to sampling control
	function attachLinks slider lights = (
		for node in lights do(
			paramWire.connect slider.baseObject[#value] node.baseObject[#subdivs] "value"
		)
	)
	
	
	
	-- Main Initialiser Function
	on Execute do(
	
		local lights	= getVRayLights();
		local slider	= getSampleSlider();

		if(lights.count > 0) then(
		
			if(slider == undefined) then
				slider	= createSamplingControl();
			
			attachLinks slider lights
		)
		else
			displayTempPrompt "ERROR: No Vray lights found in scene!" 2000;
	)
	
	
	
)