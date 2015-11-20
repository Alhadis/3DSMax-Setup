macroScript usePivot
	category:"Coordinate System"
	toolTip:"Use Pivot Point Centre"
	Icon:#("Maintoolbar", 31)
(
	on Execute do with undo off
	setCoordCenter #local
)