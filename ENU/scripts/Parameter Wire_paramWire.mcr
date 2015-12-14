macroScript paramWire
	category:"Parameter Wire"
	internalcategory:"Parameter Wire"
	buttonText:"Wire Parameters"
	tooltip:"Start Parameter Wiring"
	Icon:#("MAXScript", 1)
(
	on isEnabled return selection.count == 1
	on execute do (paramWire.start())
	
	on altExecute type do
		paramWire.OpenEditor()
)