function Create(self)

	self.secret = 0.01

	if not self:NumberValueExists("Equipped") then
		local headgear;
		if self.PresetName == "Engineer Light" then
			if math.random(0.00, 150.00) < self.secret then
				headgear = CreateAttachable("Normal Looking Hat", "Factorio.rte");
				self.Head:AddAttachable(headgear);
			else
				self.hats = {"Engineer Light Helmet", "Engineer Light Mask"};
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