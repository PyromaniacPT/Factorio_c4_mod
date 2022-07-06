dofile("Base.rte/Constants.lua")
require("AI/NativeHumanAI")
package.path = package.path .. ";Factorio.rte/?.lua";
require("Actors/Shared/Scripts/EngineerAIBehaviours")

function Create(self)
	self.AI = NativeHumanAI:Create(self)

	self.environmentSounds = {
        Concrete = CreateSoundContainer("Engineer Step Concrete", "Factorio.rte");
        landConcrete = CreateSoundContainer("Engineer Land Concrete", "Factorio.rte");
        Concrete2 = CreateSoundContainer("Engineer Step Concrete 2", "Factorio.rte");
        landConcrete2 = CreateSoundContainer("Engineer Land Concrete 2", "Factorio.rte");

        Dirt = CreateSoundContainer("Engineer Step Dirt", "Factorio.rte");
        landDirt = CreateSoundContainer("Engineer Land Dirt", "Factorio.rte");

        Sand = CreateSoundContainer("Engineer Step Sand", "Factorio.rte");
        landSand = CreateSoundContainer("Engineer Land Sand", "Factorio.rte");

        Grass = CreateSoundContainer("Engineer Step Grass", "Factorio.rte");
        landGrass = CreateSoundContainer("Engineer Land Grass", "Factorio.rte");
        Grass2 = CreateSoundContainer("Engineer Step Grass 2", "Factorio.rte")};

    self.feetContact = {false, false}
    self.feetTimers = {Timer(), Timer()}
    self.moveSoundTimer = Timer();
    self.moveSoundWalkTimer = Timer();
    self.fakejumpstop = Timer();
    self.wasInAir = false;
    self.wasMoving = false;
    self.footstepTime = 100 -- 2 Timers to avoid noise

end

function Update(self)

	self.controller = self:GetController();
	
	-- Start modded code--
	
	if (self:IsDead() ~= true) then
		
		EngineerAIBehaviours.handleMovement(self);

	else

		EngineerAIBehaviours.handleMovement(self);
		
	end

end
-- End modded code --

function UpdateAI(self)
	self.AI:Update(self)
end