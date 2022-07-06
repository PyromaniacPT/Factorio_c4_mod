EngineerAIBehaviours = {};

function EngineerAIBehaviours.handleMovement(self)

	local moving = self.controller:IsState(Controller.MOVE_LEFT) or self.controller:IsState(Controller.MOVE_RIGHT);
	
	--NOTE: you could also put in things like your falling scream here easily with very little overhead
	
	-- Leg Collision Detection system
    --local i = 0
    for i = 1, 2 do
        --local foot = self.feet[i]
		local foot = nil
        --local leg = self.legs[i]
		if i == 1 then
			foot = self.FGFoot 
		else
			foot = self.BGFoot 
		end
        --if foot ~= nil and leg ~= nil and leg.ID ~= rte.NoMOID then
		if foot ~= nil then
            local footPos = foot.Pos
	
			local mat = nil
			local pixelPos = footPos + Vector(0, 4)
			local checkPix = SceneMan:GetTerrMatter(pixelPos.X, pixelPos.Y);
--			   Grass
			if checkPix == 128 then
				if (moving) then
					if (self.moveSoundWalkTimer:IsPastSimMS(455)) then -- Lower is less delay / Faster is more delay
						self.environmentSounds.Grass:Play(self.Pos)
						self.moveSoundWalkTimer:Reset();
					end
				elseif self.wasInAir then
					if (self.feetContact[1] == true or self.feetContact[2] == true) and self.fakejumpstop:IsPastSimMS(100) then
						self.wasInAir = false;
						if self.Vel.Y > 0 and self.moveSoundTimer:IsPastSimMS(500) then
							self.environmentSounds.landGrass:Play(self.Pos);
							self.moveSoundTimer:Reset();
						end
					end
				end
--				   Vegetation
			elseif checkPix == 130 then
				if (moving) then
					if (self.moveSoundWalkTimer:IsPastSimMS(455)) then
						self.environmentSounds.Grass2:Play(self.Pos)
						self.moveSoundWalkTimer:Reset();
					end
				elseif self.wasInAir then
					if (self.feetContact[1] == true or self.feetContact[2] == true) and self.fakejumpstop:IsPastSimMS(100) then
						self.wasInAir = false;
						if self.Vel.Y > 0 and self.moveSoundTimer:IsPastSimMS(500) then
							self.environmentSounds.landGrass:Play(self.Pos);
							self.moveSoundTimer:Reset();
						end
					end
				end
--				   Bedrock			Cave Ceiling	   Concrete
			elseif checkPix == 13 or checkPix == 15 or checkPix == 177 then
				if (moving) then
					if (self.moveSoundWalkTimer:IsPastSimMS(455)) then
						self.environmentSounds.Concrete:Play(self.Pos)
						self.moveSoundWalkTimer:Reset();
					end
				elseif self.wasInAir then
					if (self.feetContact[1] == true or self.feetContact[2] == true) and self.fakejumpstop:IsPastSimMS(100) then
						self.wasInAir = false;
						if self.Vel.Y > 0 and self.moveSoundTimer:IsPastSimMS(500) then
							self.environmentSounds.landConcrete:Play(self.Pos);
							self.moveSoundTimer:Reset();
						end
					end
				end
--				   Stone			Dense Red Earth	   Wet Concrete		   Metal			 Mega Metal		  Mangled Metal
			elseif checkPix == 12 or checkPix == 16 or checkPix == 164 or checkPix == 178 or checkPix == 179 or checkPix == 180 then
				if (moving) then
					if (self.moveSoundWalkTimer:IsPastSimMS(455)) then
						self.environmentSounds.Concrete2:Play(self.Pos)
						self.moveSoundWalkTimer:Reset();
					end
				elseif self.wasInAir then
					if (self.feetContact[1] == true or self.feetContact[2] == true) and self.fakejumpstop:IsPastSimMS(100) then
						self.wasInAir = false;
						if self.Vel.Y > 0 and self.moveSoundTimer:IsPastSimMS(500) then
							self.environmentSounds.landConcrete2:Play(self.Pos);
							self.moveSoundTimer:Reset();
						end
					end
				end
--				   	Earth			Dense Earth		  Cave Floor
			elseif checkPix == 10 or checkPix == 11 or checkPix == 14 then
				if (moving) then
					if (self.moveSoundWalkTimer:IsPastSimMS(455)) then
						self.environmentSounds.Dirt:Play(self.Pos)
						self.moveSoundWalkTimer:Reset();
					end
				elseif self.wasInAir then
					if (self.feetContact[1] == true or self.feetContact[2] == true) and self.fakejumpstop:IsPastSimMS(100) then
						self.wasInAir = false;
						if self.Vel.Y > 0 and self.moveSoundTimer:IsPastSimMS(500) then
							self.environmentSounds.landDirt:Play(self.Pos);
							self.moveSoundTimer:Reset();
						end
					end
				end
--				   	Snow			  Sand			 Topsoil
			elseif checkPix == 6 or checkPix == 8 or checkPix == 9 then
				if (moving) then
					if (self.moveSoundWalkTimer:IsPastSimMS(455)) then
						self.environmentSounds.Sand:Play(self.Pos)
						self.moveSoundWalkTimer:Reset();
					end
				elseif self.wasInAir then
					if (self.feetContact[1] == true or self.feetContact[2] == true) and self.fakejumpstop:IsPastSimMS(100) then
						self.wasInAir = false;
						if self.Vel.Y > 0 and self.moveSoundTimer:IsPastSimMS(500) then
							self.environmentSounds.landSand:Play(self.Pos);
							self.moveSoundTimer:Reset();
						end
					end
				end
			end

			if self.footPixel ~= 0 then
				mat = SceneMan:GetMaterialFromID(checkPix)
			end
			
			local movement = (self.controller:IsState(Controller.MOVE_LEFT) == true or self.controller:IsState(Controller.MOVE_RIGHT) == true or self.Vel.Magnitude > 3)
			if mat ~= nil then
				if self.feetContact[i] == false then
					self.feetContact[i] = true
					if self.feetTimers[i]:IsPastSimMS(self.footstepTime) and movement then																	
						self.feetTimers[i]:Reset()
					end
				end
			else
				if self.feetContact[i] == true then
					self.feetContact[i] = false
					if self.feetTimers[i]:IsPastSimMS(self.footstepTime) and movement then
						self.feetTimers[i]:Reset()
					end
				end
			end
		end
	end

	if self.Vel.Y > 10 then
		self.wasInAir = true;
	else
		self.wasInAir = false;
	end

	self.wasMoving = moving;
end