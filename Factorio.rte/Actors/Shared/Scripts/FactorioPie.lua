-- Engineer Tool

function FactorioEngineerMenu(pieMenuOwner, pieMenu, pieSlice)
	local gun = pieMenuOwner.EquippedItem
	if gun then
		ToMOSRotating(gun):SetNumberValue("ActiveEngineerMenu", 1)
	end
end

-- Machines

function FactorioAssemblyMenu(pieMenuOwner, pieMenu, pieSlice)
	local gun = pieMenuOwner.EquippedItem
	if gun then
		ToMOSRotating(gun):SetNumberValue("ActiveAssemblyMenu", 1)
	end
end

-- Drones

function PatrolAIMode(self)
	self:SetNumberValue("AIMode", 0)
end

function FollowAIMode(self)
	self:SetNumberValue("AIMode", 1)
end

function SentryAIMode(self)
	self:SetNumberValue("AIMode", 2)
end