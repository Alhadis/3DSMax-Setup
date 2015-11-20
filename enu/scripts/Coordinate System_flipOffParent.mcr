MacroScript flipOffParent
	category: "Coordinate System"
	toolTip: "Flip Off Parent"
	Icon: #("Maintoolbar", 31);
(
	local something = #{1, 5, 10..200, 302};
	local nothing   = #(1, 2, 3);
	
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
