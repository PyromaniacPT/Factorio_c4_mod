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

        Stones = CreateSoundContainer("Engineer Step Stones", "Factorio.rte");
        landStones = CreateSoundContainer("Engineer Land Stones", "Factorio.rte");

        Ground = CreateSoundContainer("Engineer Step Dense", "Factorio.rte");
        landGround = CreateSoundContainer("Engineer Land Dense", "Factorio.rte");

        Dirt = CreateSoundContainer("Engineer Step Dirt", "Factorio.rte");
        landDirt = CreateSoundContainer("Engineer Land Dirt", "Factorio.rte");

        Sand = CreateSoundContainer("Engineer Step Sand", "Factorio.rte");
        landSand = CreateSoundContainer("Engineer Land Sand", "Factorio.rte");

        Snow = CreateSoundContainer("Engineer Step Snow", "Factorio.rte");
        landSnow = CreateSoundContainer("Engineer Land Snow", "Factorio.rte");

        Grass = CreateSoundContainer("Engineer Step Grass", "Factorio.rte");
        landGrass = CreateSoundContainer("Engineer Land Grass", "Factorio.rte");
        Grass2 = CreateSoundContainer("Engineer Step Grass 2", "Factorio.rte")};

    self.wasInAir = false;

    self.moveSoundTimer = Timer();
    self.moveSoundWalkTimer = Timer();
--    self.wasMoving = false;

    self.feetContact = {false, false}
    self.feetTimers = {Timer(), Timer()}
    self.footstepTime = 100 -- 2 Timers to avoid noise

    self.isJumping = false
    self.jumpTimer = Timer();
    self.jumpDelay = 500;
    self.jumpStop = Timer();

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