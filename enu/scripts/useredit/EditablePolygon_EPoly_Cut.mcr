MacroScript EPoly_Cut
enabledIn:#("max", "viz") --pfb: 2003.12.12 added product switch
ButtonText:"Cut"
Category:"Editable Polygon Object" 
internalCategory:"Editable Polygon Object" 
Tooltip:"Cut (Poly)" 
-- Needs Icon
(
	on isEnabled do	(Filters.Is_EPolySpecifyLevel #{5..6})
	on isVisible do	(Filters.Is_EPolySpecifyLevel #{5..6})
	on isChecked do	(
		try(
			local A = Filters.GetModOrObj()
			(Filters.Is_This_EditPolyMod A) and (A.GetCommandMode()==#Cut)
		)
		catch( false )
	)


	on execute do(
		try(
			if SubObjectLevel == undefined then max modify mode
			local A	=	Filters.GetModOrObj();
			if(Filters.Is_This_EditPolyMod A)
				then	(A.ToggleCommandMode #Cut)
				else	(A.toggleCommandMode #CutVertex)
		)
		catch(MessageBox "Operation Failed" Title:"Poly Editing")
	)
)