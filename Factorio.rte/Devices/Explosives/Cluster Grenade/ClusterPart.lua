function Create(self)
	--Some will pass through objects and cause havoc
	self.HitsMOs = math.random() < 0.5;
end
function Update(self)
	if self.GibImpulseLimit ~= 1 and (self.TravelImpulse.Magnitude > 1 or self.Age > 100) then
		--Bounce on the very first hit, and explode on the next
		--why are comments written with -- instead of // lmao???? this is genuinely retarded we're losing prawnis crabs
		self.GibImpulseLimit = 1;
		self.HitsMOs = self.HitsMOs or math.random() < 0.5;
		self:DisableScript("Factorio.rte/Devices/Explosives/Cluster Grenade/ClusterPart.lua");
	end
end