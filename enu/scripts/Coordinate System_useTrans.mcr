macroScript useTrans
	category:"Coordinate System"
	toolTip:"Use Transform Coordinate Centre"
	Icon:#("Maintoolbar", 35)
(
	on Execute do with undo off
	setCoordCenter #system
)