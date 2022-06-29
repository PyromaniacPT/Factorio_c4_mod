function Create(self)
	self.fireTimer = Timer()
	
	self.burst = false
	
	self.roundsLoaded = 0
	self.reloadTimer = Timer()
	
	self.angle = 0
	
	self.parent = nil;
end

function Update(self)
	
	
	if self.parent == nil then
		mo = self:GetRootParent()
		if mo and IsActor(mo) then
			self.parent = ToActor(mo);
		end

	elseif IsActor(self.parent) then
		
		if self.parent:NumberValueExists("AttackAngle") then
			local min_value = -math.pi;
			local max_value = math.pi;
			local value = self.parent:GetNumberValue("AttackAngle") - self.angle;
			local result;
			
			local range = max_value - min_value;
			if range <= 0 then
				result = min_value;
			else
				local ret = (value - min_value) % range;
				if ret < 0 then ret = ret + range end
				result = ret + min_value;
			end
			
			self.angle = (self.angle + result * TimerMan.DeltaTimeSecs * 3)
			self.RotAngle = self.angle
			if self.HFlipped then
				self.RotAngle = self.RotAngle + math.pi
			end
		end
		
		if self.parent:GetNumberValue("Attacking") == 1 then
			if self.reloadTimer:IsPastSimMS(300) then
				self.roundsLoaded = math.min(self.roundsLoaded + 1, 3)
				self.reloadTimer:Reset()
			end
			if self.roundsLoaded > 0 and self.fireTimer:IsPastSimMS(300) then
				local burstpos = self.Pos + Vector(6 * self.FlipFactor, 0):RadRotate(self.RotAngle)
				
				local burst = CreateAEmitter("Defender Turret Shot");
				burst.Pos = burstpos;
				burst.Team = self.Team
				burst.RotAngle = self.RotAngle
				burst.HFlipped = self.HFlipped
				MovableMan:AddParticle(burst);
				
				self.roundsLoaded = self.roundsLoaded - 1
				
				self.fireTimer:Reset()
			end
		end
	end
end