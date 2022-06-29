
function Create(self)

	self.hoverSpeed = 1.0;
	
	self.hoverPosTarget = Vector(self.Pos.X, self.Pos.Y);
	self.hoverVelocityTarget = 0;
	self.hoverVelocity = 0;
	self.hoverVelocitySpeed = 3;
	self.hoverDirectionTarget = 0;
	self.hoverDirection = 0;
	self.AlertCheck = false;
	self.hoverDirectionSpeed = 11.25;
	
	-- Sounds
	self.hoverLoop = CreateSoundContainer("Hover Loop Defender", "Factorio.rte");
	
	self.Accelerate = CreateSoundContainer("Accelerate Defender", "Factorio.rte");

	self.Death = CreateSoundContainer("Death Defender", "Factorio.rte");

	self.AlertSound = CreateSoundContainer("Factorio Warning", "Factorio.rte");
	
	self.scanLoop = CreateSoundContainer("Scan Loop Defender", "Factorio.rte");
	self.aggroScanLoop = CreateSoundContainer("Aggro Scan Loop Defender", "Factorio.rte");
	self.scanLockOn = CreateSoundContainer("Scan Lock On Defender", "Factorio.rte");
	self.scanLockOff = CreateSoundContainer("Scan Lock Off Defender", "Factorio.rte");
	
	self.dyingWarningLoop = CreateSoundContainer("Dying Warning Loop Defender", "Factorio.rte");
	
	self.scanTimer = Timer();
	self.LifeSpanTimer = Timer();
	self.LifeSpanTimer1 = Timer();
	self.LifeSpanTimer2 = Timer();
	self.scanDelay = 4000;
	
	self.Moving = false;
	
	self.moveTimer = Timer();
	-- Sounds
	
	-- Initialize AI
	self.AI = {}
	
	self.AI.master = nil -- follow this actor
	
	self.AI.passiveMode = 1 -- 0 patrol, 1 follow friendly, 2 stay still
	
	self.AI.passiveFollowOffset = Vector(0,0)
	--self.AI.passiveSentryPos = Vector(self.Pos.X, self.Pos.Y)
	
	
	self.AI.passiveUpdateTimer = Timer()
	self.AI.passiveUpdateDelayMin = 1000
	self.AI.passiveUpdateDelayMax = 3000
	self.AI.passiveUpdateDelay = math.random(self.AI.passiveUpdateDelayMin, self.AI.passiveUpdateDelayMax)
	
	self.AI.aggressive = false
	
	self.AI.aggressiveUpdateTimer = Timer()
	self.AI.aggressiveUpdateDelayMin = 100
	self.AI.aggressiveUpdateDelayMax = 300
	self.AI.aggressiveUpdateDelay = math.random(self.AI.aggressiveUpdateDelayMin, self.AI.aggressiveUpdateDelayMax)
	
	self.scan = ToGameActivity(ActivityMan:GetActivity()):GetFogOfWarEnabled()
	self.scanTimer = Timer();
	
	self.smokeTimer = Timer()
	self.smokeDelay = math.random(200,30)
	
	self.sawEnabled = false
	self.sawStartSound = true
	
	self.sawHitTimer = Timer()
	self.sawHitDelay = 300
	
	self.accsin = 0;
	self.GlobalAccScalar = 0.1;
	
	self.loopFrames = 12;
	self.Frame = 12;
end

function Update(self)
	if (self.Health < 1 or self.Status == Actor.DEAD or self.Status == Actor.DYING) then -- Death
		if not self.dead then
			if math.random(1,3) < 2 then
				self.dead = true
				self:GibThis();
				return
			else
				local emitter = CreateAEmitter("Smoke Trail Medium")
				emitter.Lifetime = 3000
				self:AddAttachable(emitter);
				
				self.GibImpulseLimit = 50;
				
				if math.random(1,2) < 2 then
					self.Vel = self.Vel + Vector(RangeRand(-1,1), RangeRand(-1,0)) * 5
				end
				
				self.aggroScanLoop:Stop(-1);
				self.scanLoop:Stop(-1);
				
				self.dyingWarningLoop:Play(self.Pos);
				
				self.dead = true
				self.GlobalAccScalar = 1.0;
			end
		else
			self.dyingWarningLoop.Pos = self.Pos;
			if self.hoverLoop.Pitch > 0 then
				self.hoverLoop.Pitch = self.hoverLoop.Pitch - 0.05;
			end
			if self.hoverLoop.Volume > 0 then
				self.hoverLoop.Volume = self.hoverLoop.Volume - 0.05;
			end
		end
		--self.ToSettle = true;
		return
	end
	
	self.dyingWarningLoop.Pos = self.Pos;

	if self.Health < 0 then
		self.Death:Play(self.Pos);
	end

	if self.LifeSpanTimer1:IsPastSimMS(25000) then
		if self:IsPlayerControlled() then
			self.Seconds = CreateAEmitter("25 Seconds")
			self.Seconds.Pos = self.Pos + Vector(0, -30)
			MovableMan:AddParticle(self.Seconds)
			self.Seconds.ToDelete = false
			if not self.AlertCheck then
				self.AlertSound:Play(self.Pos)
				self.AlertCheck = true;
			end
		else
			self.Seconds = CreateAEmitter("Null Emitter", "Base.rte")
			MovableMan:AddParticle(self.Seconds)
			self.Seconds.ToDelete = false
			if not self.AlertCheck then
				self.AlertSound:Play(self.Pos)
				self.AlertCheck = true;
			end
		end
	end

	if self.LifeSpanTimer1:IsPastSimMS(25500) then
		self.AlertSound:Stop()
		self.AlertCheck = false;
	end

	if self.LifeSpanTimer1:IsPastSimMS(28000) then
		self.AlertSound:Stop() -- Just incase :b
		if MovableMan:IsParticle(self.Seconds) then
			self.Seconds.ToDelete = true
		end
	end
-- We are done with 25 Seconds

	if self.LifeSpanTimer2:IsPastSimMS(35000) then
		self.LifeSpanTimer1:Reset()
		if self:IsPlayerControlled() then
			self.Seconds = CreateAEmitter("15 Seconds")
			self.Seconds.Pos = self.Pos + Vector(0, -30)
			MovableMan:AddParticle(self.Seconds)
			self.Seconds.ToDelete = false
			if not self.AlertCheck then
				self.AlertSound:Play(self.Pos)
				self.AlertCheck = true;
			end
		else
			self.Seconds = CreateAEmitter("Null Emitter", "Base.rte")
			MovableMan:AddParticle(self.Seconds)
			self.Seconds.ToDelete = false
			if not self.AlertCheck then
				self.AlertSound:Play(self.Pos)
				self.AlertCheck = true;
			end
		end
		if self.smokeTimer:IsPastSimMS(self.smokeDelay) then
			if RangeRand(1, 0) > (0.5) then
				local particle = CreateMOSParticle("Small Smoke Ball 1");
				particle.Pos = self.Pos + Vector(RangeRand(-self.Radius,self.Radius),RangeRand(-self.Radius,self.Radius)) * 0.25;
				particle.Vel = Vector(RangeRand(-1,1),RangeRand(-1,1));
				particle.Lifetime = particle.Lifetime * RangeRand(0.6, 1.6) * 2.0; -- Randomize lifetime
				MovableMan:AddParticle(particle);
			end
			
			self.smokeTimer:Reset()
			self.smokeDelay = math.random(200,30)
		end
	end

	if self.LifeSpanTimer2:IsPastSimMS(35500) then
		self.AlertSound:Stop(-1)
		self.AlertCheck = false;
	end

	if self.LifeSpanTimer2:IsPastSimMS(38000) then
		self.AlertSound:Stop() -- Just incase :b
		if MovableMan:IsParticle(self.Seconds) then
			self.Seconds.ToDelete = true
		end
	end

	if self.LifeSpanTimer:IsPastSimMS(45000) then
		self.MaxHealth = -100;
	end
	
	-- Damage
	self.hoverSpeed = 0.2 + math.min((self.Health / self.MaxHealth + 0.5) / 1.5, 1)
	
	if self.smokeTimer:IsPastSimMS(self.smokeDelay) then
		if RangeRand(1, 0) > (0.5 + (self.Health / self.MaxHealth)) then
			local particle = CreateMOSParticle("Small Smoke Ball 1");
			particle.Pos = self.Pos + Vector(RangeRand(-self.Radius,self.Radius),RangeRand(-self.Radius,self.Radius)) * 0.25;
			particle.Vel = Vector(RangeRand(-1,1),RangeRand(-1,1));
			particle.Lifetime = particle.Lifetime * RangeRand(0.6, 1.6) * 2.0; -- Randomize lifetime
			MovableMan:AddParticle(particle);
		end
		
		self.smokeTimer:Reset()
		self.smokeDelay = math.random(200,30)
	end
	
	-- Scan
	if self.scan and self.scanTimer:IsPastSimMS(60) then
		SceneMan:CastSeeRay(self.Team, self.Pos, Vector(300 * self.FlipFactor, 0):RadRotate(self.RotAngle + math.rad(RangeRand(-1, 1) * 45)), Vector(), 110, 4);
		self.scanTimer:Reset()
	end
	
	if self.aggroScan == true then
		if self.scanLockOnSound == true then
			self.scanLockOn:Play(self.Pos);
			self.scanLockOnSound = false;
			
			self.scanLoop:Stop(-1);
			
			self.scanLockOff:Stop(-1);
			
			self.Scan = true;
			
		end
		if not self.aggroScanLoop:IsBeingPlayed() then
			self.aggroScanLoop:Play(self.Pos);
		else
			self.aggroScanLoop.Pos = self.Pos;
		end
	else
		if self.aggroScanLoop:IsBeingPlayed() then
			self.aggroScanLoop:Stop(-1);
			
			self.scanTimer:Reset();
			
			self.scanLockOff:Play(self.Pos);
		end
		
		if self.Scan == true and not self.Scanning == true then
			self.Scan = false;
			self.Scanning = true;
			self.scanLoop:Stop(-1);
			self.scanTimer:Reset();
		end
		if self.Scanning == true then
			self.Scan = false;
			if not self.scanLoop:IsBeingPlayed() then
				self.scanLoop:Play(self.Pos);
				self.scanTimer:Reset();
			elseif self.scanLoop:IsBeingPlayed() then
			
				PrimitiveMan:DrawLinePrimitive(self.Pos + Vector(4*self.FlipFactor, -4):RadRotate(self.RotAngle), self.Pos + Vector(20*self.FlipFactor, 0):RadRotate(self.RotAngle):DegRotate(math.random(-45, 45)), 122);
				PrimitiveMan:DrawLinePrimitive(self.Pos + Vector(4*self.FlipFactor, -4):RadRotate(self.RotAngle), self.Pos + Vector(20*self.FlipFactor, 0):RadRotate(self.RotAngle):DegRotate(math.random(-45, 45)), 122);
				PrimitiveMan:DrawLinePrimitive(self.Pos + Vector(4*self.FlipFactor, -4):RadRotate(self.RotAngle), self.Pos + Vector(20*self.FlipFactor, 0):RadRotate(self.RotAngle):DegRotate(math.random(-45, 45)), 122);
				
				self.scanLoop.Pos = self.Pos;
				if self.scanTimer:IsPastSimMS(self.scanDelay) then
					--AudioMan:FadeOutSound(self.scanLoop, 250);
					self.scanLoop:FadeOut(250);
					self.Scanning = false;
				end
			end
		end
		
		self.scanLockOnSound = true;
		
	end
	
	if math.random() < 0.002 then
		self.Scan = true;
		self.scanDelay = math.random(2000, 6500);
	end	
	
	-- Controller
	
	-- Look for enemies
	if self.AI.aggressiveUpdateTimer:IsPastSimMS(self.AI.aggressiveUpdateDelay) then
		local target = MovableMan:GetClosestEnemyActor(self.Team, self.Pos, 450, Vector());
		if target and target.Status < Actor.INACTIVE then
			--Check that the target isn't obscured by terrain
			local aimTrace = SceneMan:ShortestDistance(self.Pos, target.Pos, SceneMan.SceneWrapsX);
			local terrCheck = SceneMan:CastStrengthRay(self.Pos, aimTrace, 30, Vector(), 5, 0, SceneMan.SceneWrapsX);
			if terrCheck == false then
				--self.hoverPosTarget = Vector(target.Pos.X, target.Pos.Y)
				self:SetNumberValue("AttackAngle", aimTrace.AbsRadAngle)
				
				self.AI.aggressive = true
				--self.master = nil
			else
				self.AI.aggressive = false
			end
		else
			self.AI.aggressive = false
		end
		
		self.AI.aggressiveUpdateTimer:Reset()
		self.AI.aggressiveUpdateDelay = math.random(self.AI.aggressiveUpdateDelayMin, self.AI.aggressiveUpdateDelayMax)
	end
	
	if self:IsPlayerControlled() then -- PLAYER
		local movementVector = Vector()
		local ctrl = self:GetController()
		
		local moving = false
		
		if ctrl:IsState(Controller.HOLD_UP) or ctrl:IsState(Controller.BODY_JUMP) then
			movementVector.Y = movementVector.Y - 1
			moving = true
		end
		
		if ctrl:IsState(Controller.HOLD_DOWN) or ctrl:IsState(Controller.BODY_CROUCH) then
			movementVector.Y = movementVector.Y + 1
			moving = true
		end
		if ctrl:IsState(Controller.HOLD_LEFT) then
			movementVector.X = movementVector.X - 1
			moving = true
		end
		if ctrl:IsState(Controller.HOLD_RIGHT) then
			movementVector.X = movementVector.X + 1
			moving = true
		end
		
		if ctrl:IsState(Controller.WEAPON_FIRE) then
			self:SetNumberValue("Attacking", 1)
		else
			self:SetNumberValue("Attacking", 0)
		end
		
		if moving then
			movementVector:SetMagnitude(self.Vel.Magnitude * 2.0 + 25)
			self.hoverPosTarget = Vector(self.Pos.X, self.Pos.Y) + movementVector;
		end
		
		self.Scan = false;
		self.aggroScan = false;
		self.master = nil
		
	else -- AI
		-- Update AI
		if self:NumberValueExists("AIMode") then
			self.AI.passiveMode = self:GetNumberValue("AIMode")
			self:RemoveNumberValue("AIMode")
			
			self.master = nil
			
			self:FlashWhite(100)
		end
		
		if self.AI.aggressive then
			self.aggroScan = true;
			
			self:SetNumberValue("Attacking", 1)
			
			if self.aggroScan == true then
				self.Frame = (self.Frame + 1) % self.loopFrames; -- SPEEN
			end
		else
			self.aggroScan = false;
			
			self:SetNumberValue("Attacking", 0)
			self.Frame = self.loopFrames; -- We stopped at whatever frame (Reselecting goes back to Frame 1)
		end
			
		if self.AI.passiveMode == 0 then
			if self.AI.passiveUpdateTimer:IsPastSimMS(self.AI.passiveUpdateDelay) then
				local patrolVector = Vector()
				local altitude = SceneMan:FindAltitude(self.Pos, 100, 3);
				
				local rangeX = 60
				local rangeY = 25
				if altitude > 70 then
					patrolVector = Vector(RangeRand(-1,1) * rangeX, RangeRand(0,1) * rangeY)
				elseif altitude < 25 then
					patrolVector = Vector(RangeRand(-1,1) * rangeX, RangeRand(-1,0) * rangeY)
				else
					patrolVector = Vector(RangeRand(-1,1) * rangeX, RangeRand(-1,1) * rangeY)
				end
				
				local terrCheck = SceneMan:CastStrengthRay(self.Pos, patrolVector, 30, Vector(), 6, 0, SceneMan.SceneWrapsX);
				if terrCheck == false then
					self.hoverPosTarget = self.Pos + patrolVector
				end
				
				self.AI.passiveUpdateTimer:Reset()
				self.AI.passiveUpdateDelay = math.random(self.AI.passiveUpdateDelayMin, self.AI.passiveUpdateDelayMax)
			end
		elseif self.AI.passiveMode == 1 then
			if self.master and self.master.ID ~= rte.NoMOID then -- Follow master
				
				if self.AI.passiveUpdateTimer:IsPastSimMS(self.AI.passiveUpdateDelay) then
					self.AI.passiveFollowOffset = Vector(RangeRand(-1,1), RangeRand(-0.6,0.3)) * 20.0
					
					self.AI.passiveUpdateTimer:Reset()
					self.AI.passiveUpdateDelay = math.random(self.AI.passiveUpdateDelayMin, self.AI.passiveUpdateDelayMax)
				end
				
				self.hoverPosTarget = self.master.Pos + Vector(0, - (self.master.Height * 0.25 + self.master.Radius * 1.5) / 2) + self.AI.passiveFollowOffset;
				
				if self.master.Status == Actor.DEAD or self.master.Status == Actor.DYING then
					self.master = nil
				end
			else
				self.master = nil
				if self.AI.passiveUpdateTimer:IsPastSimMS(self.AI.passiveUpdateDelay) then
					
					-- Find master
					local shortestDist;
					for actor in MovableMan.Actors do
						if actor.ID ~= self.ID and actor.Team == self.Team and IsAHuman(actor) then
							local dist = SceneMan:ShortestDistance(self.Pos, actor.Pos, SceneMan.SceneWrapsX);
							if not shortestDist or dist.Magnitude < shortestDist then
								local aimTrace = SceneMan:ShortestDistance(self.Pos, actor.Pos, SceneMan.SceneWrapsX);
								local terrCheck = SceneMan:CastStrengthRay(self.Pos, aimTrace, 30, Vector(), 6, 0, SceneMan.SceneWrapsX);
								if terrCheck == false then
									shortestDist = dist.Magnitude;
									self.master = actor;
								end
							end
						end
					end
					
					self.AI.passiveUpdateTimer:Reset()
					self.AI.passiveUpdateDelay = math.random(self.AI.passiveUpdateDelayMin, self.AI.passiveUpdateDelayMax)
				end
				
			end
		elseif self.AI.passiveMode == 2 then
			-- Do nothing
		end
	end

	
	-- Movement
	self.accsin = (self.accsin + TimerMan.DeltaTimeSecs * 2) % 2;
	self.GlobalAccScalar = math.sin(self.accsin * math.pi) * 0.2;
	
	--PrimitiveMan:DrawCirclePrimitive(self.hoverPosTarget, 6, 13);
	--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + Vector(self.hoverVelocityTarget, 0):RadRotate(self.hoverDirectionTarget), 122);
	--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + Vector(self.hoverVelocity, 0):RadRotate(self.hoverDirection), 5);
	
	-- Define howery
	local vec = SceneMan:ShortestDistance(Vector(self.Pos.X, self.Pos.Y),self.hoverPosTarget,SceneMan.SceneWrapsX)
	self.hoverDirectionTarget = vec.AbsRadAngle;
	self.hoverVelocityTarget = math.min(vec.Magnitude, 60) / 2;
	
	--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + vec, 116);
	--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + Vector(10,0):RadRotate(vec.AbsRadAngle), 149);
	
	self.hoverVelocity = (self.hoverVelocity + self.hoverVelocityTarget * TimerMan.DeltaTimeSecs * self.hoverVelocitySpeed * self.hoverSpeed) / (1 + TimerMan.DeltaTimeSecs * self.hoverVelocitySpeed * self.hoverSpeed)
	
	-- Frotate self.hoverDirection
	local min_value = -math.pi;
	local max_value = math.pi;
	local value = self.hoverDirectionTarget - self.hoverDirection;
	local result;
	
	local range = max_value - min_value;
	if range <= 0 then
		result = min_value;
	else
		local ret = (value - min_value) % range;
		if ret < 0 then ret = ret + range end
		result = ret + min_value;
	end
	
	self.hoverDirection = (self.hoverDirection + result * TimerMan.DeltaTimeSecs * self.hoverDirectionSpeed * self.hoverSpeed)
	--self.hoverDirection = self.hoverDirectionTarget
	
	result = 0
	
	-- Frotate self.RotAngle
	value = self.RotAngle;
	
	range = max_value - min_value;
	if range <= 0 then
		result = min_value;
	else
		ret = (value - min_value) % range;
		if ret < 0 then ret = ret + range end
		result = ret + min_value;
	end
	
	self.RotAngle = (self.RotAngle - result * TimerMan.DeltaTimeSecs * 15 * self.hoverSpeed)
	
	self.Vel = (self.Vel + Vector(self.hoverVelocity * 0.5, 0):RadRotate(self.hoverDirection) * TimerMan.DeltaTimeSecs * 7) / (1 + TimerMan.DeltaTimeSecs * 7);
	--self.Vel = Vector(self.hoverVelocity * 0.5, 0):RadRotate(self.hoverDirection)
	self.AngularVel = (self.AngularVel) / (1 + TimerMan.DeltaTimeSecs * 10 * self.hoverSpeed) - self.Vel.X * TimerMan.DeltaTimeSecs * 6 / self.hoverSpeed
	
	if math.abs(self.Vel.X) > 5 then
		self.HFlipped = (self.Vel.X) < 0
	end
	
	-- Sounds
	if self.Vel.Magnitude < 5 then
		if self.Moving == true then
			if self.moveTimer:IsPastSimMS(600) then

				self.Accelerate:Stop(-1);

				--self.Deccelerate:Play(self.Pos);
				self.moveTimer:Reset();
			end
			self.moveTimer:Reset();
			self.Moving = false;
		end
	else
		if self.Moving == false then
			if self.moveTimer:IsPastSimMS(600) then
				--if self.Deccelerate:IsBeingPlayed() then
				--	self.Deccelerate:Stop(-1);
				--end
				self.Accelerate:Play(self.Pos);
			end
			self.moveTimer:Reset();
			self.Moving = true;
		end	
		
	end

	
	--[[
	if self.Vel.Magnitude > 2 and not self.hoverLoop:IsBeingPlayed() then
		self.hoverLoop:Play(self.Pos);
	elseif self.Vel.Magnitude <= 2 then
		if self.hoverLoop:IsBeingPlayed() then
			self.hoverLoop:Stop(-1);
		end
	end]]
	if not self.hoverLoop:IsBeingPlayed() then
		self.hoverLoop:Play(self.Pos);
	end
	
	self.hoverLoop.Pos = self.Pos;
	self.Accelerate.Pos = self.Pos;
	
	if not self.dead then
		self.hoverLoop.Volume = (self.Vel.Magnitude / 20) + 0.5;
		self.hoverLoop.Pitch = (self.Vel.Magnitude / 20) + 1;
	end
	-- Sounds
end

function OnCollideWithTerrain(self, terrainID)
	if self.Status == Actor.DEAD or self.Status == Actor.DYING then return end
	
	-- Custom move out of terrain script, EXPERIMENTAL
	--PrimitiveMan:DrawCirclePrimitive(self.Pos, self.Radius, 13);
	local pos = self.Pos -- Hit Pos
	
	local maxi = 8
	for i = 1, maxi do
		local offset = Vector(self.Radius, 0):RadRotate(((math.pi * 2) / maxi) * i)
		local endPos = self.Pos + offset; -- This value is going to be overriden by function below, this is the end of the ray
		self.ray = SceneMan:CastObstacleRay(self.Pos + offset, offset * -1.0, Vector(0, 0), endPos, 0 , self.Team, 0, 1)
		if self.ray == 0 then
			--self.Pos = self.Pos - offset * 0.1;
			self.Pos = self.Pos - offset * 0.05;
			self.Vel = self.Vel * 0.5;
			
			if self.sawEnabled then
				self.Vel = self.Vel - offset * math.min(self.Vel.Magnitude + 5, 35) * 0.1
			end
		end
		
		pos = self.Pos + SceneMan:ShortestDistance(self.Pos,endPos, SceneMan.SceneWrapsX) * 0.5
		--PrimitiveMan:DrawLinePrimitive(self.Pos + offset, self.Pos - offset, 46);
		--PrimitiveMan:DrawLinePrimitive(self.Pos + offset, endPos, 116);
	end
end

function Destroy(self)

	self.hoverLoop:Stop(-1);
	
	self.Accelerate:Stop(-1);

	self.scanLoop:Stop(-1);

	self.aggroScanLoop:Stop(-1);
	
	self.dyingWarningLoop:Stop(-1)

	self.Death:Stop(-1)

	self.AlertSound:Stop(-1)

end