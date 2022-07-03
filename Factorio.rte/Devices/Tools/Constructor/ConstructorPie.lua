function BuildDrone1(actor)
	local gun = ToAHuman(actor).EquippedItem;
	if gun then
		ToMOSRotating(gun):SetStringValue("ConstructorMode", "Defender");
	end
end

function BuildDrone2(actor)
	local gun = ToAHuman(actor).EquippedItem;
	if gun then
		ToMOSRotating(gun):SetStringValue("ConstructorMode", "Destroyer");
	end
end

function FactorioBuyMenu(actor)
	local gun = ToAHuman(actor).EquippedItem;
	if gun then
		ToMOSRotating(gun):SetStringValue("MenuTwo", "Buy");
	end
end

function FactorioBuyMenuReturn(actor)
	local gun = ToAHuman(actor).EquippedItem;
	if gun then
		ToMOSRotating(gun):SetStringValue("MenuTwo", "Back");
	end
end

function ConstructorDigMode(actor)
	local gun = ToAHuman(actor).EquippedItem;
	if gun then
		ToMOSRotating(gun):SetStringValue("ConstructorMode", "Dig");
	end
end