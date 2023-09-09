function FactorioEngineerMenu(pieMenuOwner, pieMenu, pieSlice)
	local gun = pieMenuOwner.EquippedItem
	if gun then
		ToMOSRotating(gun):SetNumberValue("ActiveEngineerMenu", 1)
	end
end

function FactorioAssemblyMenu(pieMenuOwner, pieMenu, pieSlice)
	local gun = pieMenuOwner.EquippedItem
	if gun then
		ToMOSRotating(gun):SetNumberValue("ActiveAssemblyMenu", 1)
	end
end