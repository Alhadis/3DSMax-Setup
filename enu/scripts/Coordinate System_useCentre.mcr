macroScript useCentre
	category:"Coordinate System"
	toolTip:"Use Selection Centre"
	Icon:#("Maintoolbar", 33)
(
	on Execute do with undo off
	setCoordCenter #selection
)