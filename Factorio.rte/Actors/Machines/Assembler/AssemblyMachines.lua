local igui = require("imenu/igui")

function Create(self)
	self.Menu = require("imenu/core")
	self.Menu:Initialize(self)
	self.Menu.ForceOpen = true
	self.Menu.OneInstance = true

	local pos = self.Pos + self.SpriteOffset - Vector(3, 0)
	local width = self:GetSpriteWidth() + 10
	local height = self:GetSpriteHeight() + 4

	self.DBox = Box(pos, width, height)

	self.InsertItemTimer = Timer()
	self.ProgressTimer = Timer()

	self.InsertItemDelay = 1000
	self.ProgressDelay = 1000
	self.CurrentlyControlled = false

	self.Resource = 9999
	self.IsCrafting = false

	--VoidWanderers stuff
	self.TickTimer = Timer()
	self.TickTimer:Reset()
	self.TickInterval = 1000
	self.StorageInputDelay = 3
	self.Time = 0

	self.FailSound = CreateSoundContainer("Factorio.rte/Failed Construction")
	self.SuccessSound = CreateSoundContainer("Factorio.rte/Finished Construction")
	self.ClickSound = CreateSoundContainer("Factorio.rte/Factorio Menu Click")

	self.Bitmap = {
		CreateMOSRotating("Factorio.rte/Defender Icon"),
		CreateMOSRotating("Factorio.rte/Destroyer Icon"),
		CreateMOSRotating("Factorio.rte/Grenade Icon"),
		CreateMOSRotating("Factorio.rte/Cluster Grenade Icon"),
	}
	self.SpriteAnimMode = 0
end

function OnMessage(self, message)
	if message == "Assembly Machine 1 Menu" then AssemblyA(self) end
	if message == "Assembly Machine 2 Menu" then AssemblyB(self) end
	if message == "Assembly Machine 3 Menu" then AssemblyC(self) end
end

function AssemblyA(self)
	self.Menu.Main = igui.CollectionBox()
	self.Menu.Main:SetTitle("A S S E M B L Y\nT I E R 2 \nA U T O M A T I O N")
	self.Menu.Main:SetName("Main")
	self.Menu.Main:SetPos(Vector(460, 160))
	self.Menu.Main:SetSize(Vector(220, 125))
	self.Menu.Main:SetColor(207)
	self.Menu.Main:SetOutlineColor(208)
	self.Menu.Main:SetOutlineThickness(5)

	local materialLabel = igui.Label()
	materialLabel:SetName("MaterialCount")
	materialLabel:SetParent(self.Menu.Main)
	materialLabel:SetPos(Vector(0, 29))
	materialLabel:SetSmallText(false)
	materialLabel.Think = function(entity, screen)
		materialLabel:SetText("Material Count: " .. math.floor(self.Resource))
	end

	local assemblyList = {
		{"DefenderButton", self.Bitmap[1], CreateTDExplosive, "Defender Capsule", 500, 150},
		{"DestroyerButton", self.Bitmap[2], CreateTDExplosive, "Destroyer Capsule", 1000, 300},
		{"GrenadeButton", self.Bitmap[3], CreateTDExplosive, "Grenade", 300, 100},
		{"ClusterButton", self.Bitmap[4], CreateTDExplosive, "Cluster Grenade", 450, 180}
	}

	local craftingBox = igui.CollectionBox()
	craftingBox:SetTitle("")
	craftingBox:SetName("craftingBox")
	craftingBox:SetParent(self.Menu.Main)
	craftingBox:SetPos(Vector(230, 0))
	craftingBox:SetSize(Vector(150, 125))
	craftingBox:SetColor(207)
	craftingBox:SetOutlineColor(208)
	craftingBox:SetOutlineThickness(5)

	for i, item in ipairs(assemblyList) do
		local rows = 4
		local x = craftingBox:GetPos().X + 8 + ((i - 1) % rows + 1 - 1) * 35
		local y = 7 + (math.floor((i - 1) / rows ) + 1 - 1) * 35

		local button = igui.Button()
		button:SetName(item[1] .. i)
		button:SetParent(self.Menu.Main)
		button:SetPos(Vector(x, y))
		button:SetSize(Vector(26, 26))
		button:SetColor(248)
		button:SetText(item[5])
		button:SetTextPos(Vector(0, 10))
		button:SetOutlineColor(247)
		button:SetOutlineThickness(2)

		button.LeftClick = function(entity)
			if self.IsCrafting then self.FailSound:Play(entity.Pos) return end
			if self.Resource >= item[5] then
				self.Resource = self.Resource - item[5]

				self.ItemName = nil
				self.ItemType = nil

				self.ItemName = item[4]
				self.ItemType = item[3]
				self.ClickSound:Play(entity.Pos)
				self.IsCrafting = true
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

	local pbar = igui.ProgressBar()
	pbar:SetName("pbarFG")
	pbar:SetParent(self.Menu.Main)
	pbar:SetPos(Vector(13, 70))
	pbar:SetSize(Vector(190, 10))
	pbar:SetBGColor(247)
	pbar:SetFGColor(162)
	pbar:SetOutlineColor(247)
	pbar:SetDrawAfterParent(true)

	pbar.OnComplete = function(entity)
		local weapon = self.ItemType("Factorio.rte/" .. self.ItemName)
		weapon.Pos = self.Pos  + Vector(-50, 6)
		weapon.HFlipped = true
		weapon.RotAngle = 0.45
		weapon.Vel = Vector()
		MovableMan:AddItem(weapon)
		self.IsCrafting = false
		self.SuccessSound:Play(entity.Pos)
		self.SpriteAnimMode = 0
	end

	pbar.OnProgress = function(entity, screen)
		if self.IsCrafting then
			if self.ProgressTimer:IsPastSimMS(self.ProgressDelay) then
				pbar:SetFraction(pbar:GetFraction() + 0.05)
				self.ProgressTimer:Reset()
			end
			if self.SpriteAnimMode ~= 1 then
				self.SpriteAnimDuration = 1000
				self.SpriteAnimMode = 1
			end
			pbar:SetText(string.format("%.0f%%", pbar:GetFraction() * 100))
		end
	end

	--[[
	local button = igui.Button()
	button:SetName("pbar Button")
	button:SetParent(self.Menu.Main)
	button:SetSize(Vector(26, 26))
	button:SetColor(248)
	button.LeftClick = function(entity)
		pbar.SetFraction(pbar:GetFraction() + 0.05)
		self.PBarLength = pbar:GetFraction()
	end
	]]

	--[[
	for i = 1, 256 do
		local rows = 20
		local x = -500 + ((i - 1) % rows + 1 - 1) * 35
		local y = -125 + (math.floor((i - 1) / rows) + 1 - 1) * 35

		local button2 = igui.CollectionBox()
		button2:SetName(button2:GetName() .. i)
		button2:SetParent(self.Menu.Main)
		button2:SetPos(Vector(x, y))
		button2:SetSize(Vector(26, 26))
		button2:SetColor(i)
	end
	]]
end

function Update(self)
	local ctrl = self:GetController()
	local playerControlled = self:IsPlayerControlled()
	local screen = ActivityMan:GetActivity():ScreenOfPlayer(ctrl.Player)

	self.Menu:MessageEntity(self, self.PresetName .. " Menu")
	if self.Menu.Open then
		self.Menu.Main:Update(self)
	end
	self.Menu:Update(self)

	local closestActor = MovableMan:GetClosestActor(self.Pos, 30, Vector(), self)
	if closestActor then
		if closestActor.Team == self.Team then
			if self.DBox:IsWithinBox(closestActor.Pos) then
				self.HitsMOs = false
				self.GetsHitByMOs = false
			end
		end
	else
		self.HitsMOs = true
		self.GetsHitByMOs = true
	end
	--I'm not stealing I'm only Borrowing -Void Wanderers code

	--[[
	local topleftPos = self.DBox.Corner
	local bottomRightPos = topleftPos + Vector(self.DBox.Width - 4.5, self.DBox.Height - 4.5)
	PrimitiveMan:DrawBoxFillPrimitive(0, topleftPos, bottomRightPos, 13)
	]]

	if self.TickTimer:IsPastRealMS(self.TickInterval) then
		self.Time = self.Time + 1
		self.TickTimer:Reset()
	end

	local toreset = true

	for item in MovableMan.Items do
		if item.PresetName ~= "Engineer's Tool" then
			if IsHeldDevice(item) and not ToHeldDevice(item).UnPickupable then
				item = ToHeldDevice(item)
				local activated = false
				if IsHDFirearm(item) then
					activated = ToHDFirearm(item):IsActivated()
				elseif IsTDExplosive(item) then
					activated = ToTDExplosive(item):IsActivated()
				end

				if self.DBox:IsWithinBox(item.Pos) and not activated then
					toreset = false
					if self.LastDetectedItemTime ~= nil then
						PrimitiveMan:DrawTextPrimitive(item.Pos + Vector(-25, -40), "Store in " .. self.LastDetectedItemTime + self.StorageInputDelay - self.Time, false, 0)

						if self.Time >= self.LastDetectedItemTime + self.StorageInputDelay then
							item.ToDelete = true
							self.Resource = self.Resource + item.Mass
							self.LastDetectedItemTime = nil
						end

						break
					else
						self.LastDetectedItemTime = self.Time
					end
				end
			end
		end
	end

	if toreset then
		self.LastDetectedItemTime = nil
	end
end

function Destroy(self)
	self.Menu:Remove()
end