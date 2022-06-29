function Create(self)
	self.fuzeDelay = 4000; --fuseDelay*
	self.payload = CreateMOSRotating("Grenade Payload", "Factorio.rte");
end
function Update(self)
	if self.fuze then --self.fuse*
		if self.fuze:IsPastSimMS(self.fuzeDelay) then --self.fuseDelay*
			self.ToDelete = true;
		end
	elseif self:IsActivated() then
		self.fuze = Timer(); --self.fuse*
	end											-- i despise burgers so much pawnis bros this english is borderline unreadable
end
function Destroy(self)
	if self.fuze and self.payload then --self.fuse*
		self.payload.Pos = Vector(self.Pos.X, self.Pos.Y);
		MovableMan:AddParticle(self.payload);
		self.payload:GibThis();
	end
end