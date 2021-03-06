function Create(self)

	self.secret = 0.01;
	self.hats = {"Engineer Light Helmet", "Engineer Light Mask"};

	self.maskLoop = CreateSoundContainer("Breathing Effect", "Factorio.rte");
	self.heartLoop = CreateSoundContainer("Heart Effect", "Factorio.rte");

	if not self:NumberValueExists("Equipped") then
		local headgear;
		if self.PresetName == "Engineer Light" then
			if math.random(0.00, 150.00) < self.secret then
				headgear = CreateAttachable("Normal Looking Hat", "Factorio.rte");
				self.Head:AddAttachable(headgear);
			else
				headgear = CreateAttachable(self.hats[math.random(#self.hats)]);
				self.Head:AddAttachable(headgear);
			end
		elseif self.PresetName == "Engineer Heavy" then
			if math.random(0.00, 150.00) < self.secret then
				headgear = CreateAttachable("Normal Looking Hat", "Factorio.rte");
				self.Head:AddAttachable(headgear);
			else
				headgear = CreateAttachable("Engineer Heavy Helmet", "Factorio.rte");
				self.Head:AddAttachable(headgear);
			end
		end
	end
	self:SetNumberValue("Equipped", 1);
end

function Update(self)
	if self:IsPlayerControlled() then
		for i = 1, MovableMan:GetMOIDCount()-1 do
			local part = MovableMan:GetMOFromID(i)
			if part.RootID == self.RootID and part.PresetName == "Engineer Light Mask" then
				if not self.maskLoop:IsBeingPlayed() then
					self.maskLoop:Play(self.Pos);
				end
				self.maskLoop.Pos = self.Pos;
				if self.Health < 25 then
					if not self.heartLoop:IsBeingPlayed() then
						self.heartLoop:Play(self.Pos);
					end
					self.heartLoop.Pos = self.Pos;
					self.maskLoop:Stop();
				else
					self.heartLoop:Stop();
				end
		 	end
		end
	else
		self.maskLoop:Stop();

		self.heartLoop:Stop();
	end
end

function Destroy(self)

	self.maskLoop:Stop(-1);

	self.heartLoop:Stop(-1);
end