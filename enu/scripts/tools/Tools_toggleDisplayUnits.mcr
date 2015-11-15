MacroScript toggleDisplayUnits
	category: "Tools"
	buttonText: "Display Units Toggle"
	tooltip: "Toggle Metric/Generic Display Units"
(
	on Execute do with undo off(
		local prefSys		= #Metric; -- Metric System FTFW
		local display		= if(units.displayType == prefSys) then #Generic else prefSys;
		units.DisplayType	= display;
	)
)