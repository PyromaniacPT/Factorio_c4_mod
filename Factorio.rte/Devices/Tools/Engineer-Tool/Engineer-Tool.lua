local igui = require("imenu/igui")

function Create(self)

	self.Activity = ActivityMan:GetActivity()

	self.Income = 3	-- Basically it's like a speed modifier I think idk :b -- Used to be called self.buildCost
	self.FullMag = 64 * self.Income
	self.MaxResource = 12 * self.FullMag
	self.StartResource = 0
	self.Resource = self.StartResource * self.FullMag

	self.DigStrength = 200	--The StructuralIntegrity limit of harvestable materials

	self.DigLength = 50
	self.SpreadRange = math.rad(self.ParticleSpreadRange)
	self.Menu = require("imenu/core")
	self.Menu:Initialize(self)

	self.FailSound = CreateSoundContainer("Factorio.rte/Failed Construction")
	self.SuccessSound = CreateSoundContainer("Factorio.rte/Finished Construction")
	--self.SuccessSound.Volume = self.SuccessSound.Volume * 2
	self.ClickSound = CreateSoundContainer("Factorio.rte/Factorio Menu Click")

	self.operatedByAI = false

	self.Bitmap = {
		CreateMOSRotating("Factorio.rte/production"),
		CreateMOSRotating("Factorio.rte/military"),
		CreateMOSRotating("Factorio.rte/Defender Icon"),
		CreateMOSRotating("Factorio.rte/Destroyer Icon"),
		CreateMOSRotating("Factorio.rte/Grenade Icon"),
		CreateMOSRotating("Factorio.rte/Cluster Grenade Icon"),
		CreateMOSRotating("Factorio.rte/Assembly Machine 1 Icon")
	}
end

function OnMessage(self, message)
	if message == "EngineerMenu" then CreateMenu(self) end
end

function GetMaterialCount(self)
	return "Material Count: " .. tostring(math.floor(self.Magazine and self.Magazine.RoundCount or self.Resource))
end
function CreateMenu(self)

	self.Menu.Main = igui.CollectionBox()
	self.Menu.Main:SetTitle("")
	self.Menu.Main:SetName("Main")
	self.Menu.Main:SetPos(Vector(570, 90))
	self.Menu.Main:SetSize(Vector(150, 180))
	self.Menu.Main:SetColor(250)
	self.Menu.Main:SetOutlineColor(247)
	self.Menu.Main:SetOutlineThickness(5)

	local militaryList = {
		{"DefenderButton", self.Bitmap[3], CreateTDExplosive, "Defender Capsule", 500},
		{"DestroyerButton", self.Bitmap[4], CreateTDExplosive, "Destroyer Capsule", 1000},
		{"GrenadeButton", self.Bitmap[5], CreateTDExplosive, "Grenade", 300},
		{"ClusterGrenadeButton", self.Bitmap[6], CreateTDExplosive, "Cluster Grenade", 450}
	}

	local productList = {
		{"AssemblyMachine1Button", self.Bitmap[7], "Assembly Machine 1", 5},
	}

	local function DisplayMilitary(actor)
		for i, item in ipairs(militaryList) do
			local rows = 4
			local x = 7 + ((i - 1) % rows + 1 - 1) * 35
			local y = 102 + (math.floor((i - 1) / rows) + 1 - 1) * 35

			local button = igui.Button()
			button:SetName(item[1])
			button:SetParent(self.Menu.Main)
			button:SetPos(Vector(x, y))
			button:SetSize(Vector(26, 26))
			button:SetColor(248)
			button:SetText(item[5])
			button:SetTextPos(Vector(0, 10))
			button:SetOutlineColor(247)
			button:SetOutlineThickness(2)

			button.LeftClick = function(entity)
				if self.Resource >= item[5] then
					self.Resource = self.Resource - item[5]
					entity:AddInventoryItem(item[3]("Factorio.rte/" .. item[4]))
					self.SuccessSound:Play(entity.Pos)
				else
					self.FailSound:Play(entity.Pos)
				end
			end

			button.Think = function(entity, screen)
				button:SetColor(button.IsHovered and (self.Resource >= item[5] and 86 or 13) or 248)
				local world_pos = button.Parent.Pos + button:GetPos() + CameraMan:GetOffset(screen)
				PrimitiveMan:DrawBitmapPrimitive(screen, world_pos + Vector(13, 11), item[2], 0, 0)
			end
		end
	end
	local function DisplayProduct()
		local rows = 4
		for i, item in ipairs(productList) do
			local x = 7 + ((i - 1) % rows + 1 - 1) * 35
			local y = 102 + (math.floor((i - 1) / rows) + 1 - 1) * 35

			local button = igui.Button()
			button:SetName(item[1])
			button:SetParent(self.Menu.Main)
			button:SetPos(Vector(x, y))
			button:SetSize(Vector(26, 26))
			button:SetColor(248)
			button:SetText(item[4])
			button:SetTextPos(Vector(0, 10))
			button:SetOutlineColor(247)
			button:SetOutlineThickness(2)

			button.LeftClick = function(entity)
				if self.Resource >= item[4] then
					self.Resource = self.Resource - item[4]
					local machine = CreateActor("Factorio.rte/" .. item[3])
					machine.Pos = entity.Pos + Vector(0, 4)
					machine.Team = entity.Team
					machine.HUDVisible = false
					MovableMan:AddActor(machine)
					self.SuccessSound:Play(entity.Pos)
				else
					self.FailSound:Play(entity.Pos)
				end
			end

			button.Think = function(entity, screen)
				button:SetColor(button.IsHovered and (self.Resource >= item[4] and 86 or 13) or 248)
				local world_pos = button.Parent.Pos + button:GetPos() + CameraMan:GetOffset(screen)
				PrimitiveMan:DrawBitmapPrimitive(screen, world_pos + Vector(13, 11), item[2], 0, 0)
			end
		end
	end

	local categorys = {
		--{"LogicCategory", function() DisplayLogic() end, "logistics"},
		{"Product Category", self.Bitmap[1], DisplayProduct,
			{
				"DefenderButton",
				"DestroyerButton",
				"GrenadeButton",
				"ClusterGrenadeButton"
			}
		},
		--{"intermediateProductCategory", function() DisplayINProduct(actor) end, "intermediate-products"},
		{"Military Category", self.Bitmap[2], DisplayMilitary,
			{
				"AssemblyMachine1Button",
			}
		}
	}

	for i, item in ipairs(categorys) do
		local x = 10 + (i - 1) * 70

		local category = igui.Button()
		category:SetName(item[1])
		category:SetParent(self.Menu.Main)
		category:SetPos(Vector(x, 25))
		category:SetSize(Vector(60, 65))
		category:SetColor(248)
		category:SetOutlineColor(247)
		category:SetOutlineThickness(2)

		category.LeftClick = function(entity)
			igui.RemoveChild(self.Menu.Main.Child, item[4])
			item[3]()
			self.ClickSound:Play(entity.Pos)
		end

		category.Think = function(entity, screen)
			category:SetColor(category.IsHovered and 249 or 248)
			local world_pos = category.Parent.Pos + category:GetPos() + CameraMan:GetOffset(screen)
			PrimitiveMan:DrawBitmapPrimitive(screen, world_pos + Vector(30, 35), item[2], 0, 0)
		end
	end
end

function Update(self)

	local actor = self:GetRootParent()
	if actor and IsActor(actor) then

		actor = ToActor(actor)
		local ctrl = actor:GetController()
		local playerControlled = actor:IsPlayerControlled()

		if self.Magazine then
			self.Magazine.RoundCount = math.max(self.Resource, 1)

			self.Magazine.Mass = 1 + 39 * (self.Resource / self.MaxResource)
			self.Magazine.Scale = 0.5 + (self.Resource / self.MaxResource) * 0

			local parentWidth = ToMOSprite(actor):GetSpriteWidth()
			local parentHeight = ToMOSprite(actor):GetSpriteHeight()

			self.Magazine.Pos = actor.Pos + Vector(-(self.Magazine.Radius * 0.3 + parentWidth * 0.2 - 0.5) *
			self.FlipFactor, -(self.Magazine.Radius * 0.15 + parentHeight * 0.2)):RadRotate(actor.RotAngle)

			self.Magazine.RotAngle = actor.RotAngle
		end

		if playerControlled then
			self.operatedByAI = false
		elseif actor.AIMode == Actor.AIMODE_GOLDDIG then
			if ctrl:IsState(Controller.WEAPON_FIRE) and SceneMan:ShortestDistance(actor.Pos, ConstructorTerrainRay(actor.Pos, Vector(0, 50), 3), SceneMan.SceneWrapsX):MagnitudeIsLessThan(30) then
				self.operatedByAI = true
			end
		end

		if self:NumberValueExists("EngineerMenu") then
			self.Menu:MessageEntity(self, "EngineerMenu", actor)
			self:RemoveNumberValue("EngineerMenu")
		end

		if self.Menu.Open then
			self.Menu.Main:Update(actor)
		end

		self.Menu:Update(actor)

		if ctrl:IsState(Controller.WEAPON_FIRE) then

			local angle = actor:GetAimAngle(true)

			for i = 1, self.RoundsFired do
				local trace = Vector(self.DigLength, 0):RadRotate(angle + RangeRand(-1, 1) * self.SpreadRange)
				local digPos = ConstructorTerrainRay(self.MuzzlePos, trace, 0)

				if SceneMan:GetTerrMatter(digPos.X, digPos.Y) ~= rte.airID then

					local digWeightTotal = 0
					local totalVel = Vector()
					local found = 0

					for x = 1, 3 do
						for y = 1, 3 do
							local checkPos = ConstructorWrapPos(Vector(digPos.X - 2 + x, digPos.Y - 2 + y))
							local terrCheck = SceneMan:GetTerrMatter(checkPos.X, checkPos.Y)
							local material = SceneMan:GetMaterialFromID(terrCheck)
							if material.StructuralIntegrity <= self.DigStrength and material.StructuralIntegrity <= self.DigStrength * RangeRand(0.5, 1.05) then
								local px = SceneMan:DislodgePixel(checkPos.X, checkPos.Y)
								if px then
									local digWeight = math.sqrt(material.StructuralIntegrity/self.DigStrength)
									local speed = 3
									if terrCheck == rte.goldID then
										--Spawn a glowy gold pixel and delete the original
										px.ToDelete = true
										px = CreateMOPixel("Gold Particle", "Base.rte")
										px.Pos = checkPos
										--Sharpness temporarily stores the ID of the target
										px.Sharpness = actor.ID
										MovableMan:AddParticle(px)
									else
										px.Sharpness = self.ID
										px.Lifetime = 1000
										speed = speed + (1 - digWeight) * 5
										digWeightTotal = digWeightTotal + digWeight
									end
									px.IgnoreTerrain = true
									px.Vel = Vector(trace.X, trace.Y):SetMagnitude(-speed):RadRotate(RangeRand(-0.5, 0.5))
									totalVel = totalVel + px.Vel
									px:AddScript("Base.rte/Devices/Tools/Constructor/ConstructorCollect.lua")
									found = found + 1
								end
							end
						end
					end
					if found > 0 then
						if digWeightTotal > 0 then
							digWeightTotal = digWeightTotal/9
							self.Resource = math.min(self.Resource + digWeightTotal * self.Income, self.MaxResource)
						end
						local collectFX = CreateMOPixel("Particle Constructor Gather Material" .. (digWeightTotal > 0.5 and " Big" or ""))
						collectFX.Vel = totalVel/found
						collectFX.Pos = Vector(digPos.X, digPos.Y) + collectFX.Vel * rte.PxTravelledPerFrame

						MovableMan:AddParticle(collectFX)
					else
						self:Deactivate()
					end
				else	-- deactivate if digging air
					self:Deactivate()
					break
				end
			end
		end
	end
end

function ConstructorWrapPos(checkPos)
	if SceneMan.SceneWrapsX then
		if checkPos.X > SceneMan.SceneWidth then
			checkPos = Vector(checkPos.X - SceneMan.SceneWidth, checkPos.Y)
		elseif checkPos.X < 0 then
			checkPos = Vector(SceneMan.SceneWidth + checkPos.X, checkPos.Y)
		end
	end
	return checkPos
end

function ConstructorTerrainRay(start, trace, skip)
	local hitPos = start + trace
	SceneMan:CastStrengthRay(start, trace, 0, hitPos, skip, rte.airID, SceneMan.SceneWrapsX)	
	return hitPos
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
