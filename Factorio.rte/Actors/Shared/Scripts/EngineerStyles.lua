function Create(self)

	self.secret = 0.01;
	self.hats = {"Engineer Light Helmet", "Engineer Light Mask"};

	self.maskLoop = CreateSoundContainer("Breathing Effect", "Factorio.rte");
	self.heartLoop = CreateSoundContainer("Heart Effect", "Factorio.rte");

	if not self:NumberValueExists("Equipped") then
		self.headgear = "";
		if self.PresetName == "Engineer Light" then
			if math.random(0.00, 150.00) < self.secret then
				self.headgear = CreateAttachable("Normal Looking Hat", "Factorio.rte");
				self.Head:AddAttachable(self.headgear);
			else
				self.headgear = CreateAttachable(self.hats[math.random(#self.hats)]);
				self.Head:AddAttachable(self.headgear);
			end
		elseif self.PresetName == "Engineer Heavy" then
			if math.random(0.00, 150.00) < self.secret then
				self.headgear = CreateAttachable("Normal Looking Hat", "Factorio.rte");
				self.Head:AddAttachable(self.headgear);
			else
				self.headgear = CreateAttachable("Engineer Heavy Helmet", "Factorio.rte");
				self.Head:AddAttachable(self.headgear);
			end
		end
	end
	self:SetNumberValue("Equipped", 1);
end

function Update(self)
	if self:IsPlayerControlled() then
		if self.headgear.PresetName == "Engineer Light Mask" then
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
	else
		self.maskLoop:Stop();

		self.heartLoop:Stop();
	end
end

function Destroy(self)

	self.maskLoop:Stop(-1);

	self.heartLoop:Stop(-1);
end