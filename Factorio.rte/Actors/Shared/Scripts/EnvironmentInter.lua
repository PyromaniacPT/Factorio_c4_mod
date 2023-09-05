function Create(self)
	local BASE_PATH = "Factorio.rte/Engineer "
	self.Terrain = {
		Concrete = CreateSoundContainer(BASE_PATH .. "Step Concrete", "Factorio.rte");
		Concrete2 = CreateSoundContainer(BASE_PATH .. "Step Concrete 2", "Factorio.rte");
		Stones = CreateSoundContainer(BASE_PATH .. "Step Stones", "Factorio.rte");
		Ground = CreateSoundContainer(BASE_PATH .. "Step Dense", "Factorio.rte");
		Dirt = CreateSoundContainer(BASE_PATH .. "Step Dirt", "Factorio.rte");
		Sand = CreateSoundContainer(BASE_PATH .. "Step Sand", "Factorio.rte");
		Snow = CreateSoundContainer(BASE_PATH .. "Step Snow", "Factorio.rte");
		Grass = CreateSoundContainer(BASE_PATH .. "Step Grass", "Factorio.rte");
		Grass2 = CreateSoundContainer(BASE_PATH .. "Step Grass 2", "Factorio.rte")};

	self.wasInAir = false
	self.moveSoundTimer = Timer()
	self.moveSoundWalkTimer = Timer()
	--    self.wasMoving = false;
	self.feetContact = { false, false }
	self.StepTimer = { Timer(), Timer() }
	self.footstepTime = 100 -- 2 Timers to avoid noise
	self.isJumping = false
	self.jumpTimer = Timer()
	self.jumpDelay = 500
	self.jumpStop = Timer()

	self.SFX = {
		[128] = self.Terrain.Grass, -- Grass
		[130] = self.Terrain.Grass2, -- Vegetation
		[13] = self.Terrain.Stones, -- Bedrock
		[15] = self.Terrain.Concrete, -- Cave Ceiling
		[177] = self.Terrain.Concrete, -- Concrete
		[164] = self.Terrain.Concrete2, -- Wet Concrete
		[178] = self.Terrain.Ground, -- Metal
		[179] = self.Terrain.Ground, -- Mega Metal
		[180] = self.Terrain.Ground, -- Mangled Metal
		[11] = self.Terrain.Ground, -- Dense Earth
		[16] = self.Terrain.Ground, -- Dense Red Earth
		[12] = self.Terrain.Stones, -- Stone
		[10] = self.Terrain.Dirt, -- Earth
		[14] = self.Terrain.Stones, -- Cave Floor
		[8] = self.Terrain.Sand, -- Sand
		[9] = self.Terrain.Sand, -- Topsoil
		[6] = self.Terrain.Snow, -- Snow
		[19] = self.Terrain.Snow, -- Dense Snow
	}
	self.Volume = 0.32
end

function Update(self)
	self.controller = self:GetController()
	if not self:IsDead() then
		OnLand(self)
	else
		OnLand(self)
	end
end

function FootStepTerrain(self, footPos)
	local pixelPos = footPos + Vector(0, 4)
	local terraCheck = SceneMan:GetTerrMatter(pixelPos.X, pixelPos.Y)
	local Environment = self.SFX[terraCheck]
	if Environment then
		Environment:Play(self.Pos)
		Environment.Volume = self.Volume
	end
end

function LandOnTerrain(self, footPos)
	local pixelPos = footPos + Vector(0, 4)
	local terraCheck = SceneMan:GetTerrMatter(pixelPos.X, pixelPos.Y)
	local Environment = self.SFX[terraCheck]
	if Environment then
		if
			self.controller:IsState(Controller.BODY_JUMPSTART) == true
			and self.controller:IsState(Controller.BODY_CROUCH) == false
			and self.jumpTimer:IsPastSimMS(self.jumpDelay)
			and not self.isJumping
		then
			if self.feetContact[1] == true or self.feetContact[2] == true then
				self.isJumping = true
				self.jumpTimer:Reset()
				self.jumpStop:Reset()
			end
		elseif self.isJumping or self.wasInAir then
			if (self.feetContact[1] == true or self.feetContact[2] == true) and self.jumpStop:IsPastSimMS(100) then
				self.isJumping = false
				self.wasInAir = false
				if self.Vel.Y > 0 and self.moveSoundTimer:IsPastSimMS(500) then
					Environment:Play(self.Pos)
					Environment.Volume = self.Volume + 0.25
					self.moveSoundTimer:Reset()
				end
			end
		end
	end
	return terraCheck
end

function OnStride(self)
	local feet = { self.FGFoot, self.BGFoot }
	for i = 1, #feet do
		local foot = feet[i]
		if foot then
			local footPos = foot.Pos
			FootStepTerrain(self, footPos)
		end
	end
end

function OnLand(self)
	local feet = { self.FGFoot, self.BGFoot }
	for i = 1, #feet do
		local foot = feet[i]
		if foot then
			local footPos = foot.Pos
			local mat = nil
			local terraCheck = LandOnTerrain(self, footPos)
			if terraCheck ~= 0 then
				mat = SceneMan:GetMaterialFromID(terraCheck)
			end
			local movement = (
					self.controller:IsState(Controller.MOVE_LEFT) == true
					or self.controller:IsState(Controller.MOVE_RIGHT) == true
					or self.Vel.Magnitude > 3
				)
			if mat ~= nil then
				if self.feetContact[i] == false then
					self.feetContact[i] = true
					if self.StepTimer[i]:IsPastSimMS(self.footstepTime) and movement then
						self.StepTimer[i]:Reset()
					end
				end
			else
				if self.feetContact[i] == true then
					self.feetContact[i] = false
					if self.StepTimer[i]:IsPastSimMS(self.footstepTime) and movement then
						self.StepTimer[i]:Reset()
					end
				end
			end
			if self.Vel.Y > 10 then
				self.wasInAir = true
			else
				self.wasInAir = false
			end
		end
	end
end