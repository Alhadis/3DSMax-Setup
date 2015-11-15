macroScript SelectInstances
	category:"Tools"
	buttonText:"Select All Instances"
	tooltip:"Select All Instances"
(
	on Execute do(

		if($ != undefined) then(
			selectList = #()
			for obj in selection do(
				instanceMgr.getInstances obj &list
				join selectList list
			)
			select (for obj in selectList where (obj.isHidden == false and obj.isFrozen == false) collect obj)
		)

	)
)