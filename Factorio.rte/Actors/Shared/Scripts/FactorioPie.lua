-- Engineer Tool

function FactorioEngineerMenu(pieMenuOwner, pieMenu, pieSlice)
	local gun = pieMenuOwner.EquippedItem
	if gun then
		ToMOSRotating(gun):SetNumberValue("EngineerMenu", 1)
	end
end

-- Machines

function FactorioAssemblyMenu(self)
	self:SetNumberValue("AssemblyMenu", 0)
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