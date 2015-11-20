MacroScript Move
	enabledIn: #("max", "viz", "vizr")
	category: "Overrides"
	buttonText: "Move"
	toolTip: "Move"
	icon: #("Maintoolbar",21)
(
	on Execute do(
		try(
			if(not(viewport.isPerspView()) and viewport.getCamera() == undefined)
				then max tool xy
			max move
		)catch()
	)
	
	on altExecute type do(
		try(max move)catch()
		actionMan.executeAction 0 "40093";
	)
)