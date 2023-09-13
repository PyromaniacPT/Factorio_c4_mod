package.path = package.path .. ";Mods/Factorio.rte?.lua";
require("Actors/Shared/Menu/AssemblyMenu")

function Create(self)
	InteractiveMenu.Assembly.Create(self)
end

function Update(self)
	local ctrl = self:GetController()
	InteractiveMenu.Assembly.Update(self, self)
	self.CurrentScreen = self.Activity:ScreenOfPlayer(ctrl.Player)
end

function Destroy(self)
	InteractiveMenu.Destroy(self, "FAMouse")
end