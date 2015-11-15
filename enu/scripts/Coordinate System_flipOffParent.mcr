macroScript flipOffParent
	category: "Coordinate System"
	toolTip: "Flip Off Parent"
	Icon: #("Maintoolbar", 31)
(
	on Execute do with undo off(
		local system	= getRefCoordSys();
		local centre	= getCoordCenter();

		if(system != #hybrid or centre != #local) then(
			setRefCoordSys #hybrid
			setCoordCenter #local
		)
		else(
			setRefCoordSys #parent
			setCoordCenter #system
		)
	)
)