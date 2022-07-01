function Create(self)
	self.fireTimer = Timer()
	self.range = math.sqrt(FrameMan.PlayerScreenWidth^1.8 + FrameMan.PlayerScreenHeight^1.8)/2;
	self.shotCounter = 0;	--TODO: Rename/describe this variable better
	self.strengthVariation = 5;
	self.activity = ActivityMan:GetActivity();
	
	self.burst = false
	
	self.roundsLoaded = 0
	self.reloadTimer = Timer()
	
	self.angle = 0
	
	self.parent = nil;
	self.penetrationStrength = 170;

	self.LaserSoundLoop = CreateSoundContainer("Factorio Laser Loop Robo", "Factorio.rte");
end

function Update(self)
	
	local range = self.range + math.random(8);
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
			if not self.LaserSoundLoop:IsBeingPlayed() then
				self.LaserSoundLoop:Play(self.Pos);
			end
			self.LaserSoundLoop.Pos = self.Pos;
			if self.reloadTimer:IsPastSimMS(10) then
				self.roundsLoaded = math.min(self.roundsLoaded + 1, 3)
				self.reloadTimer:Reset()
			end
			if self.roundsLoaded > 0 and self.fireTimer:IsPastSimMS(10) then

				local startPos = self.Pos + Vector(6 * self.FlipFactor, 0):RadRotate(self.RotAngle)
				local hitPos = Vector(startPos.X, startPos.Y);
				local gapPos = Vector(startPos.X, startPos.Y);
				local trace = Vector(range * self.FlipFactor, 0):RadRotate(self.RotAngle);
				--Use higher pixel skip first to find a rough estimate
				local skipPx = 4;
				local rayLength = SceneMan:CastObstacleRay(startPos, trace, hitPos, gapPos, mo.ID, self.Team, rte.airID, skipPx);

				if rayLength >= 0 then
					gapPos = gapPos - Vector(trace.X, trace.Y):SetMagnitude(skipPx);
					skipPx = 1;
					local shortRay = SceneMan:CastObstacleRay(gapPos, Vector(trace.X, trace.Y):SetMagnitude(rayLength + skipPx), hitPos, gapPos, mo.ID, self.Team, rte.airID, skipPx);
					gapPos = gapPos - Vector(trace.X, trace.Y):SetMagnitude(skipPx);
					local strengthFactor = math.max(1 - rayLength/self.range, math.random()) * (self.shotCounter + 1)/self.strengthVariation;

					local moID = SceneMan:GetMOIDPixel(hitPos.X, hitPos.Y);
					if moID ~= rte.NoMOID and moID ~= self.ID then
						local mo = ToMOSRotating(MovableMan:GetMOFromID(moID));
						if self.penetrationStrength * strengthFactor >= mo.Material.StructuralIntegrity then
							local moAngle = -mo.RotAngle * mo.FlipFactor;

							local woundName = mo:GetEntryWoundPresetName();
							if woundName ~= "" then
								local wound = CreateAEmitter(woundName);

								local dist = SceneMan:ShortestDistance(mo.Pos, hitPos, SceneMan.SceneWrapsX);
								local offset = Vector(dist.X * mo.FlipFactor, dist.Y):RadRotate(moAngle):SetMagnitude(dist.Magnitude - (wound.Radius - 1) * wound.Scale);
								local traceOffset = Vector(trace.X * mo.FlipFactor, trace.Y):RadRotate(moAngle);

								wound.InheritedRotAngleOffset = traceOffset.AbsRadAngle - (mo.HFlipped and 0 or math.pi);
								mo:AddWound(wound, Vector(offset.X, offset.Y), true);
							end
						end
					end
					local pix = CreateMOPixel("Destroyer Red Glow " .. math.floor(strengthFactor * 4 + 0.5), "Factorio.rte");
					pix.Pos = gapPos;
					pix.Sharpness = self.penetrationStrength/6;
					pix.Vel = Vector(trace.X, trace.Y):SetMagnitude(6);
					MovableMan:AddParticle(pix);
				end
				if rayLength ~= 0 then
					trace = SceneMan:ShortestDistance(startPos, gapPos, SceneMan.SceneWrapsX);
					for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
						local team = self.activity:GetTeamOfPlayer(player);
						local screen = self.activity:ScreenOfPlayer(player);
						if screen ~= -1 and not (SceneMan:IsUnseen(startPos.X, startPos.Y, team) or SceneMan:IsUnseen(hitPos.X, hitPos.Y, team)) then
							PrimitiveMan:DrawLinePrimitive(screen, startPos, startPos + trace, 10);
						end
					end
					local particleCount = trace.Magnitude * RangeRand(0.4, 0.8);
					for i = 0, particleCount do
						local pix = CreateMOPixel("Destroyer Red Glow " .. math.random(2));
						pix.Pos = startPos + trace * i/particleCount;
						pix.Vel = self.Vel;
						MovableMan:AddParticle(pix);
					end
				end
				self.shotCounter = (self.shotCounter + 1) % self.strengthVariation;
				self.roundsLoaded = self.roundsLoaded - 1

				self.fireTimer:Reset()
			end
		else
			if self.LaserSoundLoop:IsBeingPlayed() then
				self.LaserSoundLoop:Stop(-1);
			end
		end
	end
end

function Destroy(self)

	self.LaserSoundLoop:Stop(-1);

end