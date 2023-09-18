package.path = package.path .. ";Mods/Factorio.rte?.lua";
require("Actors/Shared/Menu/AssemblyMenu")

function Create(self)
	InteractiveMenu.Assembly.Create(self)

	local Pos = self.Pos + self.SpriteOffset - Vector(3, 0)
	local Width = self:GetSpriteWidth() + 7
	local Height = self:GetSpriteHeight() + 4

	self.DBox = Box(Pos, Width, Height)

	--Debug
	--[[
	local topleftPos = DBox.Corner
	local bottomRightPos = topleftPos + Vector(DBox.Width - 4.5, DBox.Height - 4.5)
	PrimitiveMan:DrawBoxFillPrimitive(InteractiveMenu.GetScreen(self), topleftPos, bottomRightPos, 13)
	]]
	self.InsertItemTimer = Timer()
	self.InsertItemDelay = 1000
	self:SetNumberValue("AssemblyMaterial", 0)
end

function Update(self)
	local ctrl = self:GetController()
	InteractiveMenu.Assembly.Update(self, self)
	local ClosestActor = MovableMan:GetClosestActor(self.Pos, 30, Vector(), self)
	if ClosestActor then
		if self.DBox:IsWithinBox(ClosestActor.Pos) then
			self.HitsMOs = false
			self.GetsHitByMOs = false
		end
	else
		self.HitsMOs = true
		self.GetsHitByMOs = true
	end
	--I'm not stealing I'm only Borrowing -Void Wanderers code

	for item in MovableMan.Items do
		if item.PresetName ~= "Engineer's Tool" then

			local DeviceType
			if IsHDFirearm(item) then
				DeviceType = ToHDFirearm
			elseif IsTDExplosive(item) then
				DeviceType = ToTDExplosive
			elseif IsThrownDevice(item) then
				DeviceType = ToThrownDevice
			elseif IsHeldDevice(item) then 
				DeviceType = ToHeldDevice
			end
			local weapon = DeviceType(item)

			local activated = false
			activated = weapon:IsActivated()

			if self.DBox:IsWithinBox(item.Pos) and not activated then
				if not weapon:NumberValueExists("AssemblyInsertTimeLeft") then
					weapon:SetNumberValue("AssemblyInsertTimeLeft", 3)
				end
				if self.InsertItemTimer:IsPastSimMS(self.InsertItemDelay) then
					weapon:SetNumberValue("AssemblyInsertTimeLeft", weapon:GetNumberValue("AssemblyInsertTimeLeft") - 1)
					if weapon:GetNumberValue("AssemblyInsertTimeLeft") == -1 then
						item.ToDelete = true
						weapon:SetNumberValue("AssemblyInsertTimeLeft", 3)
						self:SetNumberValue("AssemblyMaterial", self:GetNumberValue("AssemblyMaterial") + item.Mass)
					end
					self.InsertItemTimer:Reset()
				end
				if not item.ToDelete then
					PrimitiveMan:DrawTextPrimitive(InteractiveMenu.Player(), item.Pos + Vector(-25, -40), tostring("Store in ".. weapon:GetNumberValue("AssemblyInsertTimeLeft")), false, 0)
				end
			else
				if weapon:NumberValueExists("AssemblyInsertTimeLeft") then
					weapon:RemoveNumberValue("AssemblyInsertTimeLeft")
				end
			end
		end
	end
end

function Destroy(self)
	InteractiveMenu.Destroy(self, "FAMouse")
	self.DBox = nil
end