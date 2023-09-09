dofile("Factorio.rte/Actors/Shared/Menu/EngineerMenu.lua")

function Create(self)

	InteractiveMenu.Engineer.Create(self)

	self.Activity = ActivityMan:GetActivity()

	self.Income = 3	-- Basically it's like a speed modifier I think idk :b -- Used to be called self.buildCost
	self.fullMag = 64 * self.Income
	self.maxResource = 12 * self.fullMag
	self.startResource = 0
	self.resource = self.startResource * self.fullMag

	self.clearer = CreateMOSRotating("Engineer-Tool Terrain Clearer")

	self.digStrength = 200	--The StructuralIntegrity limit of harvestable materials

	self.digLength = 50
	self.spreadRange = math.rad(self.ParticleSpreadRange)
	self.SuccessSound.Volume = self.SuccessSound.Volume * 2

	self.operatedByAI = false
end

function Update(self)
	
	local actor = self:GetRootParent()
	if actor and IsActor(actor) then
		actor = ToActor(actor)
		local ctrl = actor:GetController()

		InteractiveMenu.Engineer.Update(self, actor, self)

		local playerControlled = actor:IsPlayerControlled()
		self.CurrentScreen = self.Activity:ScreenOfPlayer(ctrl.Player)

		if self.Magazine then
			self.Magazine.RoundCount = math.max(self.resource, 1)
			
			self.Magazine.Mass = 1 + 39 * (self.resource/self.maxResource)
			self.Magazine.Scale = 0.5 + (self.resource/self.maxResource) * 0

			local parentWidth = ToMOSprite(actor):GetSpriteWidth()
			local parentHeight = ToMOSprite(actor):GetSpriteHeight()

			self.Magazine.Pos = actor.Pos + Vector(-(self.Magazine.Radius * 0.3 + parentWidth * 0.2 - 0.5) *
			self.FlipFactor, -(self.Magazine.Radius * 0.15 + parentHeight * 0.2)):RadRotate(actor.RotAngle)

			self.Magazine.RotAngle = actor.RotAngle
		end

		if ctrl:IsState(Controller.WEAPON_FIRE) then

			local angle = actor:GetAimAngle(true)

			for i = 1, self.RoundsFired do
				local trace = Vector(self.digLength, 0):RadRotate(angle + RangeRand(-1, 1) * self.spreadRange)
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
							if material.StructuralIntegrity <= self.digStrength and material.StructuralIntegrity <= self.digStrength * RangeRand(0.5, 1.05) then
								local px = SceneMan:DislodgePixel(checkPos.X, checkPos.Y)
								if px then
									local digWeight = math.sqrt(material.StructuralIntegrity/self.digStrength)
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
							self.resource = math.min(self.resource + digWeightTotal * self.Income, self.maxResource)
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


function Destroy(self)
	InteractiveMenu.Destroy(self, "FMouse")
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
