function Create(self)

	self.secret = 0.01;
	self.hats = {"Engineer Light Helmet", "Engineer Light Mask"};

	self.MaskLoop = CreateSoundContainer("Breathing Effect", "Factorio.rte");

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
				if not self.MaskLoop:IsBeingPlayed() then
					self.MaskLoop:Play(self.Pos);
				end
				self.MaskLoop.Pos = self.Pos;
		 	end
		end
	else
		self.MaskLoop:Stop();
	end
end

function Destroy(self)

	self.MaskLoop:Stop(-1);

end