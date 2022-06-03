function OnPieMenu(item)
	if item and IsHDFirearm(item) and item.PresetName == "Rocket Launcher" then
		item = ToHDFirearm(item);
		if item.Magazine then
			--Remove corresponding pie slices if mode is already active
			if item.Magazine.PresetName == "Magazine Factorio Normal Rocket" then
				ToGameActivity(ActivityMan:GetActivity()):RemovePieMenuSlice("Normal Rocket Fire", "FNormalRocket");
			elseif item.Magazine.PresetName == "Magazine Factorio ExplosiveRocket" then
				ToGameActivity(ActivityMan:GetActivity()):RemovePieMenuSlice("Explosive Rocket", "FExplosiveRocket");
			end
		end
	end
end