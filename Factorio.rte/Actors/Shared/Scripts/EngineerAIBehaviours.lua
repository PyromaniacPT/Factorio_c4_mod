EngineerAIBehaviours = {};

function EngineerAIBehaviours.handleMovement(self)
	
	local crouching = self.controller:IsState(Controller.BODY_CROUCH)
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

			if checkPix == 128 or checkPix == 130 then
				if (moving) then
					if (self.moveSoundWalkTimer:IsPastSimMS(450)) then -- Lower is less delay / Faster is more delay
						self.environmentSounds.Grass:Play(self.Pos)
						self.moveSoundWalkTimer:Reset();
					end
				end

			elseif checkPix == 13 or checkPix == 15 or checkPix == 177 then
				if (moving) then
					if (self.moveSoundWalkTimer:IsPastSimMS(450)) then
						self.environmentSounds.Concrete:Play(self.Pos)
						self.moveSoundWalkTimer:Reset();
					end
				end

			elseif checkPix == 12 or checkPix == 16 or checkPix == 164 or checkPix == 178 or checkPix == 179 or checkPix == 180 then
				if (moving) then
					if (self.moveSoundWalkTimer:IsPastSimMS(450)) then
						self.environmentSounds.Concrete2:Play(self.Pos)
						self.moveSoundWalkTimer:Reset();
					end
				end

			elseif checkPix == 10 or checkPix == 11 or checkPix == 14 then
				if (moving) then
					if (self.moveSoundWalkTimer:IsPastSimMS(450)) then
						self.environmentSounds.Dirt:Play(self.Pos)
						self.moveSoundWalkTimer:Reset();
					end
				end

			elseif checkPix == 6 or checkPix == 8 or checkPix == 9 then
				if (moving) then
					if (self.moveSoundWalkTimer:IsPastSimMS(450)) then
						self.environmentSounds.Sand:Play(self.Pos)
						self.moveSoundWalkTimer:Reset();
					end
				end
			end
			--if materialID.PresetName == self.Concrete then
			--	self.environmentSounds.Concrete:Play(self.Pos);
			--	
			--	elseif materialID.PresetName == self.Dirt then
			--	self.environmentSounds.Dirt:Play(self.Pos);
			--	
			--	elseif materialID.PresetName == self.Sand then
			--	self.environmentSounds.Sand:Play(self.Pos);
	
			--end		
			--PrimitiveMan:DrawLinePrimitive(pixelPos, pixelPos, 13)
			if self.footPixel ~= 0 then
				mat = SceneMan:GetMaterialFromID(checkPix)
			--	PrimitiveMan:DrawLinePrimitive(pixelPos, pixelPos, 162);
			--else
			--	PrimitiveMan:DrawLinePrimitive(pixelPos, pixelPos, 13);
			end
			
			local movement = (self.controller:IsState(Controller.MOVE_LEFT) == true or self.controller:IsState(Controller.MOVE_RIGHT) == true or self.Vel.Magnitude > 3)
			if mat ~= nil then
				--PrimitiveMan:DrawTextPrimitive(footPos, mat.PresetName, true, 0);
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
	self.wasMoving = moving;
end