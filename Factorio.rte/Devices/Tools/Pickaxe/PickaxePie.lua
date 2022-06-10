function FactorioCreateSandbag(actor)
	if actor and IsAHuman(actor) then
		actor = ToAHuman(actor);
		if actor:GetNumberValue("FactorioPickaxeResource") >= 10 then
			actor:RemoveNumberValue("FactorioPickaxeResource");
			actor:AddInventoryItem(CreateThrownDevice("Factorio.rte/Sandbag"));
			actor:EquipNamedDevice("Sandbag", true);
		else
			local errorSound = CreateSoundContainer("Error", "Base.rte");
			errorSound:Play(actor.Pos, actor:GetController().Player);
		end
	end
end