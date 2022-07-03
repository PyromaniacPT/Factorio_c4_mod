function OnPieMenu(item)
	if item and IsHDFirearm(item) and item.PresetName == "Engineer's Tool" then
		item = ToHDFirearm(item);
		if item:GetStringValue("MenuTwo") == "Buy" then
			ToGameActivity(ActivityMan:GetActivity()):RemovePieMenuSlice("Form Squad", "");
			ToGameActivity(ActivityMan:GetActivity()):RemovePieMenuSlice("Brain Hunt AI Mode", "");
			ToGameActivity(ActivityMan:GetActivity()):RemovePieMenuSlice("Patrol AI Mode", "");
			ToGameActivity(ActivityMan:GetActivity()):RemovePieMenuSlice("Go-To AI Mode", "");
			ToGameActivity(ActivityMan:GetActivity()):RemovePieMenuSlice("Sentry AI Mode", "");
			ToGameActivity(ActivityMan:GetActivity()):RemovePieMenuSlice("Construct Menu", "FactorioBuyMenu");
			ToGameActivity(ActivityMan:GetActivity()):AddPieMenuSlice("Destroyer | Price: 1000", "BuildDrone2", Slice.RIGHT, true);
			ToGameActivity(ActivityMan:GetActivity()):AddPieMenuSlice("Defender | Price: 500", "BuildDrone1", Slice.RIGHT, true);
--			ToGameActivity(ActivityMan:GetActivity()):AddPieMenuSlice("Dig Mode", "ConstructorDigMode", Slice.DOWN, true);
			ToGameActivity(ActivityMan:GetActivity()):AddPieMenuSlice("Go Back", "FactorioBuyMenuReturn", Slice.UP, true);
		elseif item:GetStringValue("MenuTwo") == "Back" then
--			item:SetStringValue("ConstructorMode", "Dig")
			ToGameActivity(ActivityMan:GetActivity()):RemovePieMenuSlice("Destroyer | Price: 1000", "BuildDrone2");
			ToGameActivity(ActivityMan:GetActivity()):RemovePieMenuSlice("Defender | Price: 500", "BuildDrone1");
--			ToGameActivity(ActivityMan:GetActivity()):RemovePieMenuSlice("Dig Mode", "ConstructorDigMode");
			ToGameActivity(ActivityMan:GetActivity()):RemovePieMenuSlice("Go Back", "FactorioBuyMenuReturn");
		end
	end
end

function ConstructorWrapPos(checkPos)
	if SceneMan.SceneWrapsX then
		if checkPos.X > SceneMan.SceneWidth then
			checkPos = Vector(checkPos.X - SceneMan.SceneWidth, checkPos.Y);
		elseif checkPos.X < 0 then
			checkPos = Vector(SceneMan.SceneWidth + checkPos.X, checkPos.Y);
		end
	end
	return checkPos;
end

function ConstructorTerrainRay(start, trace, skip)

	local length = trace.Magnitude;
	local angle = trace.AbsRadAngle;

	local density = math.ceil(length/skip);

	local roughLandPos = start + Vector(length, 0):RadRotate(angle);
	for i = 0, density do
		local invector = start + Vector(skip * i, 0):RadRotate(angle);
		local checkPos = ConstructorWrapPos(invector);
		if SceneMan:GetTerrMatter(checkPos.X, checkPos.Y) ~= rte.airID then
			roughLandPos = checkPos;
			break;
		end
	end

	local checkRoughLandPos = roughLandPos + Vector(skip * -1, 0):RadRotate(angle);
	for i = 0, skip do
		local invector = checkRoughLandPos + Vector(i, 0):RadRotate(angle);
		local checkPos = ConstructorWrapPos(invector);
		roughLandPos = checkPos;
		if SceneMan:GetTerrMatter(checkPos.X, checkPos.Y) ~= rte.airID then
			break;
		end
	end

	return roughLandPos;
end

function Create(self)

	self.fireTimer = Timer();
	self.Income = 10;	-- Basically it's like a speed modifier I think idk :b -- Used to be called self.buildCost
	self.fullMag = 64 * self.Income;
	self.maxResource = 12 * self.fullMag;
	self.startResource = 0;
	self.resource = self.startResource * self.fullMag;

	self.clearer = CreateMOSRotating("Engineer-Tool Terrain Clearer");

	self.digStrength = 200;	--The StructuralIntegrity limit of harvestable materials
	
	self.Spent = 0
	self.digLength = 50;
	self.digsPerSecond = 100;
	self.spreadRange = math.rad(self.ParticleSpreadRange);
	self.fireSound = CreateSoundContainer("Engineer Dig Tool", "Factorio.rte");

	self.operatedByAI = false;
end

function Update(self)
	
	local actor = self:GetRootParent();
	if actor and IsActor(actor) then

		actor = ToActor(actor);
		local ctrl = actor:GetController();
		local playerControlled = actor:IsPlayerControlled();
		local screen = ActivityMan:GetActivity():ScreenOfPlayer(ctrl.Player);

		if self.Magazine then
			self.Magazine.RoundCount = math.max(self.resource, 1);
			
			self.Magazine.Mass = 1 + 39 * (self.resource/self.maxResource);
			self.Magazine.Scale = 0.5 + (self.resource/self.maxResource) * 0;

			local parentWidth = ToMOSprite(actor):GetSpriteWidth();
			local parentHeight = ToMOSprite(actor):GetSpriteHeight();
			self.Magazine.Pos = actor.Pos + Vector(-(self.Magazine.Radius * 0.3 + parentWidth * 0.2 - 0.5) * self.FlipFactor, -(self.Magazine.Radius * 0.15 + parentHeight * 0.2)):RadRotate(actor.RotAngle);
			self.Magazine.RotAngle = actor.RotAngle;
		end
		
		if ctrl:IsState(Controller.PIE_MENU_ACTIVE) then
			PrimitiveMan:DrawTextPrimitive(screen, actor.AboveHUDPos + Vector(0, 26), "Mode: Dig", true, 1);
		end

		if playerControlled then
			self.operatedByAI = false;
		elseif actor.AIMode == Actor.AIMODE_GOLDDIG then
			if self:GetStringValue("ConstructorMode") == "Dig" then
				if ctrl:IsState(Controller.WEAPON_FIRE) and SceneMan:ShortestDistance(actor.Pos, ConstructorTerrainRay(actor.Pos, Vector(0, 50), 3), SceneMan.SceneWrapsX).Magnitude < 30 then
					self.operatedByAI = true;
					self.aiSkillRatio = 1.5 - ActivityMan:GetActivity():GetTeamAISkill(actor.Team)/100;
				end
			end
		end

		local mode = self:GetNumberValue("BuildMode");
		if mode == 0 then
			-- activation
			if self:GetStringValue("ConstructorMode") == "Defender" then
				local ItemPrices = {}
				ItemPrices[1] = 500;	-- Defender
				ItemPrices[2] = 1000;	-- Destroyer
				ItemPrices[3] = 1800;	-- Assembly
				ItemPrices[4] = 3000;	-- Some other Shit
				if self.resource >= ItemPrices[1] then
					self.Spent = 1
					self.resource = self.resource - 500
					print("We Just Spent 500 Dollars")
					actor:AddInventoryItem(CreateTDExplosive("Defender Capsule", "Factorio.rte"))
					if self.resource < ItemPrices[1] then
						print("We have less than 500 Dollars")
					end
				else
					self.Spent = 0
				end
			end
				if self:GetStringValue("ConstructorMode") == "Destroyer" then
					local ItemPrices = {}
					ItemPrices[1] = 500;	-- Defender
					ItemPrices[2] = 1000;	-- Destroyer
					ItemPrices[3] = 1800;	-- Assembly
					ItemPrices[4] = 3000;	-- Some other Shit
					if self.resource >= ItemPrices[2] then
						self.Spent = 1
						self.resource = self.resource - 1000
						print("We Just Spent 1000 Dollars")
						actor:AddInventoryItem(CreateTDExplosive("Destroyer Capsule", "Factorio.rte"))
						if self.resource < ItemPrices[2] then
							print("We have less than 1000 Dollars")
						end
					else
						self.Spent = 0
					end
				end
				if self.Spent == 1 then
					self:SetStringValue("ConstructorMode", "Dig");
					self.Spent = 0
				end

				-- Shitty Safety Mode
				if self.Spent == 0 and self:GetStringValue("ConstructorMode") == "Defender" or self:GetStringValue("ConstructorMode") == "Destroyer" then
					self:SetStringValue("ConstructorMode", "Dig");
				end
			if ctrl:IsState(Controller.WEAPON_FIRE) then
				local angle = actor:GetAimAngle(true);

				if self:GetStringValue("ConstructorMode") == "Dig" then

					local digAmount = (self.fireTimer.ElapsedSimTimeMS * 0.001) * self.digsPerSecond;
					self.fireTimer:Reset();

					for i = 1, digAmount do

						local digPos = ConstructorTerrainRay(self.MuzzlePos, Vector(self.digLength, 0):RadRotate(angle + RangeRand(-1, 1) * self.spreadRange), 1);

						if SceneMan:GetTerrMatter(digPos.X, digPos.Y) ~= rte.airID then

							local digWeight = 0;
							local found = false;

							for x = 1, 3 do
								for y = 1, 3 do
									local checkPos = ConstructorWrapPos(Vector(digPos.X - 2 + x, digPos.Y - 2 + y));
									local terrCheck = SceneMan:GetTerrMatter(checkPos.X, checkPos.Y);
									if terrCheck ~= rte.airID then
										if terrCheck == rte.goldID then
											self.clearer.Pos = Vector(checkPos.X, checkPos.Y);
											self.clearer:EraseFromTerrain();
											local collectFX = CreateMOPixel("Particle Engineer-Tool Gather Material Gold");
											collectFX.Pos = Vector(checkPos.X, checkPos.Y);
											collectFX.Sharpness = self.ID;
											collectFX.Vel.Y = -RangeRand(2, 3);
											MovableMan:AddParticle(collectFX);
										else
											local material = SceneMan:GetMaterialFromID(terrCheck);
											if material.StructuralIntegrity > 0 and material.StructuralIntegrity <= self.digStrength then
												if math.random() > material.StructuralIntegrity/(self.digStrength * 1.1) then
													self.clearer.Pos = Vector(checkPos.X, checkPos.Y);
													self.clearer:EraseFromTerrain();
													digWeight = digWeight + math.sqrt(material.StructuralIntegrity/self.digStrength);
												end
												if not self.fireSound:IsBeingPlayed() then
													self.fireSound:Play(self.Pos);
												end
												self.fireSound.Pos = self.Pos;
												found = true;
											end
										end
									end
								end
							end
							if digWeight > 0 then
								digWeight = digWeight/9;
								self.resource = math.min(self.resource + digWeight * self.Income, self.maxResource);
								
								local collectFX = CreateMOPixel("Particle Engineer-Tool Gather Material" .. (digWeight > 0.5 and " Big" or ""));
								collectFX.Pos = Vector(digPos.X, digPos.Y);
								collectFX.Sharpness = self.ID;
								collectFX.Vel.Y = 10/(collectFX.Mass + digWeight);
								collectFX.Lifetime = SceneMan:ShortestDistance(digPos, self.Pos, SceneMan.SceneWrapsX).Magnitude/(collectFX.Vel.Magnitude * rte.PxTravelledPerFrame) * TimerMan.DeltaTimeMS;

								MovableMan:AddParticle(collectFX);
							elseif not found then
								self:Deactivate();
								if self.fireSound:IsBeingPlayed() then
									self.fireSound:Stop(-1);
								end
							end
						else	-- deactivate if digging air
							self:Deactivate();
							if self.fireSound:IsBeingPlayed() then
								self.fireSound:Stop(-1);
							end
							break;
						end
					end
				end
			else
				if self.fireSound:IsBeingPlayed() then
					self.fireSound:Stop(-1);
				end
				self.fireTimer:Reset();
			end
		end
	end
end

function Destroy(self)

	self.fireSound:Stop(-1);

end









































-- DO YOU LIKE................... MEH CAR?
-- GAS! GAS! GAS!
--	MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
--	MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
--	MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
--	MMMMMMMMMMMMMMMMMMMMMMMMMMNK0KNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
--	MMMMMMMMMMMMMMMMMMMMMMMWXxlcllokKWMMWNK0XWMMWWWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
--	MMMMMMMMMMMMMMMMMMMMMMWO;'oKXkc;cdOOO0OkO0KOxxO0KXNNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
--	MMMMMMMMMMMMMMMMMMMWWWNd..:ol,'...,;o000OOxc;lkkkO00KXWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
--	MMMMMMMMMMMMMMMMMWKxlcoo;''....   'cxocoxo,..;oxdxxkOkOKNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
--	MMMMMMMMMMMMMMMMMNx'.',..',''......';;'';,..,cc::cldkkxdxKWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
--	MMMMMMMMMMMMMMMMMMK:.','.............''.'....,,,;:::loc::cOWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
--	MMMMMMMMMMMMMMMMMMWx,'''......,,,...'......,,...,:llllc,''c0WMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
--	MMMMMMMMMMMMMMMMMMWk;',.   ..';:lc;;:;;::,'',....';::;:;,,:kWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
--	MMMMMMMMMMMMMMMMMMXl,;'.   ......,:ccloc;,,;;,...',;;;lxxooxKWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
--	MMMMMMMMMMMMMMMWXOo;;;.........  ..'..,:;'.',co:'',;::dKKklcoONMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
--	MMMMMMMMMMMMWXOo;...'...''.',,,.''''. .,;,;:;:llc::;';xko:'.,c0WMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
--	MMMMMMMMMMWKo:,.,c;';'.... .cdo:''',...','':lll:;,,;:c;'......oXMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
--	MMMMMMMMMMXx;',;ld;:0Ol;,,,.;ol:lxl;....;odlc;;cc::;'..........:kNMMMWWMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
--	MMMMMMMWX0xodddxxo;oNMW0::l'.;loddxko;..'cxxoooc,.......',,......ckOxdx0WMMMMMMMMMMMMMMMMMMMMMMMMMMM
--	MMMMMWKkdodxkk0KK0kxO0Ol';:..;coooddooo:'..,::'. ......',;;,.........''cdk000KKKXNNWMMMMMMMMMMMMMMMM
--	MMMMW0o::codkO00OkOxocc,...  .;:;;cooolcl:. ....  ...''',;;;'.....  ..:;.',:dxxO00KXXNWMMMMMMMMMMMMM
--	MMMMWKl'...';ldxddxdl:,. .   .;,. .';cc:,'.......   ...',;;;,'.....   ......;;:xOkkOOO0XWMMMMMMMMMMM
--	MMMMMO;.... ..,ccloc;,'.     .,;,.. ..;;...,c;..........',''','.......    ....';lddodddx0WMMMMMMMMMM
--	MMMMM0:...  .  .;::,'....... .,::cc;'';;...'coc,............','.............  ..,;c:;clclOWMMMMMMMMM
--	MMMMMNd'....'.. .,,'..   .lc,..,:lollcc:....:ll:;,'........',,''......',,'''..  .,,..;;',oXMMMMMMMMM
--	MMMMMMXo'.........'..    .cllc:,,;::cll,....;clc:,'..... ..,,,,'...'''.........',clc,... ;KMMMMMMMMM
--	MMMMMMMNd'..........    .oK0xollc;;,,,'.....,;::;. ..''.....''''',;;,..........:dx0O;   .lXMMMMMMMMM
--	MMMMMMMW0o;.......'.  .'lOKK0kxdlllc;,'......'''..   ..'.....'',;,',;:c:,'''...:c::,. ..;xXWMMMMMMMM
--	MMMMMMMMWXOd:,...''.';cllldkKNWXOdolll:;'...'.....     ......',;,.':cc:::cl:,.,:c,...';clldkKWMMMMMM
--	MMMMMMMMMMMNKkolc::clllllllloONMWXkollllc:,''.....     .'..''.',;'.',:lol::;;::;,;;;cllllllloxKWMMMM
--	MMMMMMMMMMMMMMNKOxolllllllllldKMMWKxollllllc:;::lc:;.   ..'.'''',;;,;cc:::::;,'',:llllllllllllxXMMMM
--	MMMMMMMMMMMMMMMMMNXOkdollldk0XWMMMMWXOxollcccldkO000ko,.  .....;ldxxl:;;:;'''';:cllllooooooox0NWMMMM
--	MMMMMMMMMMMMMMMMMMMMWNXK0KNWMMMMMMMMMMNKd::;:cdkOOOkkxo;.......:dx0Oo;,'..,;:cllllloooooxOKXWMMMMMMM
--	MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMXo'....,coddddoc::'.  ...;cc:,...,:clllllllloxxollokXMMMMMMMM
--	MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMK:.......,:cllc;,,,..  ..';;,',;clllllllllllloolllld0WMMMMMMM
--	MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNo'.. .....'';:;,''';;:;'.',:cclllllllllllodxkOOkkOKNWMMMMMMM
--	MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMKc'.........''.....;llllc:cllllllllllllodkOKNWMMMMMMMMMMMMMM
--	MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMKl'........'.....'cdollllllllllllllodxOKXWMMMMMMMMMMMMMMMMM
--	MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMW0l,'......''..';oKNX0OOdollllllodxO0XNMMMMMMMMMMMMMMMMMMMM
--	MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWKxl:;,'.',,,:clox0XWMWNKOxdllodOKNMMMMMMMMMMMMMMMMMMMMMMM
--	MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWXOxlcccccllllllldkXWMMMWXkllokXMMMMMMMMMMMMMMMMMMMMMMMM
--	MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWXOkxolllllllllokNMMMMMX0OKNWMMMMMMMMMMMMMMMMMMMMMMMM
--	MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWX0kxdooodk0NMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
--	MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMWWNXXKNWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
--	MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
--	MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
--	MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
--	MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
--	MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM