function FactorioBuyMenu(pieMenuOwner, pieMenu, pieSlice)
	local gun = pieMenuOwner.EquippedItem
	if gun then
		ToMOSRotating(gun):SetNumberValue("ActiveMenu", 1)
	end
end