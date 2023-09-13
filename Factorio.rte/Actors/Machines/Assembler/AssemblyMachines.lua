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
	PrimitiveMan:DrawBoxFillPrimitive(self.CurrentScreen, topleftPos, bottomRightPos, 13)
	]]
end

function Update(self)
	local ctrl = self:GetController()
	InteractiveMenu.Assembly.Update(self, self)
	self.CurrentScreen = self.Activity:ScreenOfPlayer(ctrl.Player)
	local ClosestActor = MovableMan:GetClosestActor(self.Pos, 25, Vector(), self)
	if ClosestActor then
		if self.DBox:IsWithinBox(ClosestActor.Pos) then
			self.HitsMOs = false
			self.GetsHitByMOs = false
		end
	else
		self.HitsMOs = true
		self.GetsHitByMOs = true
	end
end

function Destroy(self)
	InteractiveMenu.Destroy(self, "FAMouse")
end