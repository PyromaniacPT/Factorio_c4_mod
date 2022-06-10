function Create(self)
	self.startSound = CreateSoundContainer("Flamethrower Fire Sound Start", "Factorio.rte");
	self.endSound = CreateSoundContainer("Flamethrower Fire Sound End", "Factorio.rte");
end
function Update(self)
	if self:IsActivated() and self.RoundInMagCount ~= 0 then
		if not self.triggerPulled then
			self.startSound:Play(self.MuzzlePos);
		end
		self.triggerPulled = true;
	else
		if self.triggerPulled then
			self.endSound:Play(self.MuzzlePos);
		end
		self.triggerPulled = false;
	end
end