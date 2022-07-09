EngineerAIBehaviours = {};

function EngineerAIBehaviours.handleMovement(self)

--	local moving = self.controller:IsState(Controller.MOVE_LEFT) or self.controller:IsState(Controller.MOVE_RIGHT);
	
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
		if self.StrideFrame then
			--	Grass
			if checkPix == 128 then
				self.environmentSounds.Grass:Play(self.Pos)

			--		Vegetation
			elseif checkPix == 130 then
				self.environmentSounds.Grass2:Play(self.Pos)

			--		Bedrock			Cave Ceiling	   Concrete
			elseif checkPix == 13 or checkPix == 15 or checkPix == 177 then
				self.environmentSounds.Concrete:Play(self.Pos);

			--	Wet Concrete		   Metal			 Mega Metal		  Mangled Metal
			elseif checkPix == 164 or checkPix == 178 or checkPix == 179 or checkPix == 180 then
				self.environmentSounds.Concrete2:Play(self.Pos);

			--	   Dense Earth		Dense Red Earth
			elseif checkPix == 11 or checkPix == 16 then
				self.environmentSounds.Ground:Play(self.Pos);

			--		Stone
			elseif checkPix == 12 then
				self.environmentSounds.Stones:Play(self.Pos);

			--		Earth			Cave Floor
			elseif checkPix == 10 or checkPix == 14 then
				self.environmentSounds.Dirt:Play(self.Pos)

			--	  	Sand			 Topsoil
			elseif checkPix == 8 or checkPix == 9 then
				self.environmentSounds.Sand:Play(self.Pos)

			--		 Snow	
			elseif checkPix == 6 then
				self.environmentSounds.Snow:Play(self.Pos)
			end
		else

			--	Grass			  Vegetation
			if checkPix == 128 or checkPix == 130 then
				if self.controller:IsState(Controller.BODY_JUMPSTART) == true and self.controller:IsState(Controller.BODY_CROUCH) == false and self.jumpTimer:IsPastSimMS(self.jumpDelay) and not self.isJumping then
					if self.feetContact[1] == true or self.feetContact[2] == true then
						self.isJumping = true
						self.jumpTimer:Reset()
						self.jumpStop:Reset()
					end
				elseif self.isJumping or self.wasInAir then
					if (self.feetContact[1] == true or self.feetContact[2] == true) and self.jumpStop:IsPastSimMS(100) then
						self.isJumping = false
						self.wasInAir = false;
						if self.Vel.Y > 0 and self.moveSoundTimer:IsPastSimMS(500) then
							self.environmentSounds.landGrass:Play(self.Pos);
							self.moveSoundTimer:Reset();
						end
					end
				end
			--		Bedrock			Cave Ceiling	   Concrete
			elseif checkPix == 13 or checkPix == 15 or checkPix == 177 then
				if self.controller:IsState(Controller.BODY_JUMPSTART) == true and self.controller:IsState(Controller.BODY_CROUCH) == false and self.jumpTimer:IsPastSimMS(self.jumpDelay) and not self.isJumping then
					if self.feetContact[1] == true or self.feetContact[2] == true then
						self.isJumping = true
						self.jumpTimer:Reset()
						self.jumpStop:Reset()
					end
				elseif self.isJumping or self.wasInAir then
					if (self.feetContact[1] == true or self.feetContact[2] == true) and self.jumpStop:IsPastSimMS(100) then
						self.isJumping = false
						self.wasInAir = false;
						if self.Vel.Y > 0 and self.moveSoundTimer:IsPastSimMS(500) then
							self.environmentSounds.landConcrete:Play(self.Pos);
							self.moveSoundTimer:Reset();
						end
					end
				end
			--		Wet Concrete		Metal			 Mega Metal		  Mangled Metal
			elseif checkPix == 164 or checkPix == 178 or checkPix == 179 or checkPix == 180 then
				if self.controller:IsState(Controller.BODY_JUMPSTART) == true and self.controller:IsState(Controller.BODY_CROUCH) == false and self.jumpTimer:IsPastSimMS(self.jumpDelay) and not self.isJumping then
					if self.feetContact[1] == true or self.feetContact[2] == true then
						self.isJumping = true
						self.jumpTimer:Reset()
						self.jumpStop:Reset()
					end
				elseif self.isJumping or self.wasInAir then
					if (self.feetContact[1] == true or self.feetContact[2] == true) and self.jumpStop:IsPastSimMS(100) then
						self.isJumping = false
						self.wasInAir = false;
						if self.Vel.Y > 0 and self.moveSoundTimer:IsPastSimMS(500) then
							self.environmentSounds.landConcrete2:Play(self.Pos);
							self.moveSoundTimer:Reset();
						end
					end
				end
			--	   Dense Earth		Dense Red Earth
			elseif checkPix == 11 or checkPix == 16 then
					if self.controller:IsState(Controller.BODY_JUMPSTART) == true and self.controller:IsState(Controller.BODY_CROUCH) == false and self.jumpTimer:IsPastSimMS(self.jumpDelay) and not self.isJumping then
						if self.feetContact[1] == true or self.feetContact[2] == true then
							self.isJumping = true
							self.jumpTimer:Reset()
							self.jumpStop:Reset()
						end
					elseif self.isJumping or self.wasInAir then
						if (self.feetContact[1] == true or self.feetContact[2] == true) and self.jumpStop:IsPastSimMS(100) then
							self.isJumping = false
							self.wasInAir = false;
							if self.Vel.Y > 0 and self.moveSoundTimer:IsPastSimMS(500) then
								self.environmentSounds.landGround:Play(self.Pos);
								self.moveSoundTimer:Reset();
							end
						end
					end

			--		Stone
			elseif checkPix == 12 then
					if self.controller:IsState(Controller.BODY_JUMPSTART) == true and self.controller:IsState(Controller.BODY_CROUCH) == false and self.jumpTimer:IsPastSimMS(self.jumpDelay) and not self.isJumping then
						if self.feetContact[1] == true or self.feetContact[2] == true then
							self.isJumping = true
							self.jumpTimer:Reset()
							self.jumpStop:Reset()
						end
					elseif self.isJumping or self.wasInAir then
						if (self.feetContact[1] == true or self.feetContact[2] == true) and self.jumpStop:IsPastSimMS(100) then
							self.isJumping = false
							self.wasInAir = false;
							if self.Vel.Y > 0 and self.moveSoundTimer:IsPastSimMS(500) then
								self.environmentSounds.landStones:Play(self.Pos);
								self.moveSoundTimer:Reset();
							end
						end
					end
			--		Earth			Cave Floor
			elseif checkPix == 10 or checkPix == 14 then
				if self.controller:IsState(Controller.BODY_JUMPSTART) == true and self.controller:IsState(Controller.BODY_CROUCH) == false and self.jumpTimer:IsPastSimMS(self.jumpDelay) and not self.isJumping then
					if self.feetContact[1] == true or self.feetContact[2] == true then
						self.isJumping = true
						self.jumpTimer:Reset()
						self.jumpStop:Reset()
					end
				elseif self.isJumping or self.wasInAir then
					if (self.feetContact[1] == true or self.feetContact[2] == true) and self.jumpStop:IsPastSimMS(100) then
						self.isJumping = false
						self.wasInAir = false;
						if self.Vel.Y > 0 and self.moveSoundTimer:IsPastSimMS(500) then
							self.environmentSounds.landDirt:Play(self.Pos);
							self.moveSoundTimer:Reset();
						end
					end
				end
			--		Sand			 Topsoil
			elseif checkPix == 8 or checkPix == 9 then
				if self.controller:IsState(Controller.BODY_JUMPSTART) == true and self.controller:IsState(Controller.BODY_CROUCH) == false and self.jumpTimer:IsPastSimMS(self.jumpDelay) and not self.isJumping then
					if self.feetContact[1] == true or self.feetContact[2] == true then
						self.isJumping = true
						self.jumpTimer:Reset()
						self.jumpStop:Reset()
					end
				elseif self.isJumping or self.wasInAir then
					if (self.feetContact[1] == true or self.feetContact[2] == true) and self.jumpStop:IsPastSimMS(100) then
						self.isJumping = false
						self.wasInAir = false;
						if self.Vel.Y > 0 and self.moveSoundTimer:IsPastSimMS(500) then
							self.environmentSounds.landSand:Play(self.Pos);
							self.moveSoundTimer:Reset();
						end
					end
				end
			--		Snow		
			elseif checkPix == 6 then
				if self.controller:IsState(Controller.BODY_JUMPSTART) == true and self.controller:IsState(Controller.BODY_CROUCH) == false and self.jumpTimer:IsPastSimMS(self.jumpDelay) and not self.isJumping then
					if self.feetContact[1] == true or self.feetContact[2] == true then
						self.isJumping = true
						self.jumpTimer:Reset()
						self.jumpStop:Reset()
					end
				elseif self.isJumping or self.wasInAir then
					if (self.feetContact[1] == true or self.feetContact[2] == true) and self.jumpStop:IsPastSimMS(100) then
						self.isJumping = false
						self.wasInAir = false;
						if self.Vel.Y > 0 and self.moveSoundTimer:IsPastSimMS(500) then
							self.environmentSounds.landSnow:Play(self.Pos);
							self.moveSoundTimer:Reset();
						end
					end
				end
			end
		end

			if checkPix ~= 0 then
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

--	self.wasMoving = moving;
end