MacroScript Open
	category:	"Overrides"
	tooltip:	"Open"
	buttonText:	"Open"
	icon: #("Containers", 9);
(
	
	--	Returns TRUE if node is a closed grouphead.
	function isClosedGroupHead value = (
		isGroupHead(value) and not(isOpenGroupHead(value));
	)
	
	function isClosedGroupMember value = (
		isGroupMember(value) and not(isOpenGroupMember(value));
	)
	
	
	
	on Execute do(
		
		--	Selection set isn't empty
		if(selection.count > 0) then(
			
			local areGroups	= false;
			local notGroups	= false;
			for i in selection do(
				if(isClosedGroupHead i)
					then areGroups = true;
				else if(isClosedGroupMember(i) == false)
					then notGroups = true;
			)
			
			-- If only closed groups are found in the selection, prevent the usual File open dialog to open group(s) instead.
			if(areGroups == true and notGroups == false) then
				max group open;
			
			-- Otherwise, follow the eternal tradition of a software-standard "Open File"
			else max file open;
		)
		
		--	Nothing's selected; we default to the traditional File Open command
		else max file open;
		
	)
)