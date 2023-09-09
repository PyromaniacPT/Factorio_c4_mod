dofile("[B]InteractiveMenu.rte/Script/InteractiveMenu.lua")

InteractiveMenu.InitializeCoreTable("Engineer")

InteractiveMenu.Engineer.Create = function(self) 
	self.FailSound = CreateSoundContainer("Factorio.rte/Failed Construction")
	self.SuccessSound = CreateSoundContainer("Factorio.rte/Finished Construction")

	self.Activity = ActivityMan:GetActivity()
end


InteractiveMenu.Engineer.Update = function(self, actor, device)

	local playerControlled = actor:IsPlayerControlled()

	local mouse = "FMouse"
	local menu = "FMenu"
	local PATH = "Factorio.rte/Factorio Mouse"

	if playerControlled then
		if device:GetNumberValue("ActiveEngineerMenu") == 1 then
			device:SetNumberValue("ActiveEngineerMenu", 0)
			InteractiveMenu.Engineer.Menu(self, actor, menu)
			InteractiveMenu.CreateMenuCursor(self, actor, mouse, PATH)
		end
	end

	InteractiveMenu.PersistentMenu(self, actor, mouse, menu)
end

InteractiveMenu.Engineer.Menu = function(self, actor, table)

	self[table] = {}

	local function GetMaterialCount(self)
		return "Material Count: " .. tostring(math.floor(self.Magazine and self.Magazine.RoundCount or self.resource))
	end

	local function GiveItem(actor, ItemName)
		actor:AddInventoryItem(CreateTDExplosive("Factorio.rte/" .. ItemName))
	end

	local function GetBox(Name)
		return InteractiveBox[Name]
	end

	local ItemPrices = {500, 1000, 350, 450, 1800}

	local CMenu = InteractiveMenu.Root("ConstructMenu", 575, 190, 145, 80, 81, true, {})

	CMenu.Child = {

		InteractiveMenu.Button("DefenderButton", 5, 45, 30, 30, 80, true, true, "Cost: " .. ItemPrices[1], "down", true,
			function()
				if self.resource >= ItemPrices[1] then
					self.resource = self.resource - ItemPrices[1]
					GiveItem(actor, "Defender Capsule")
					self.SuccessSound:Play(actor.Pos)
				else
					self.FailSound:Play(actor.Pos)
				end
			end,
			function()
				local Defender
				if not Defender then
					Defender = CreateMOSRotating("Factorio.rte/Defender Icon")
				end
				local Pos = InteractiveMenu.ScreenPos(self, GetBox("DefenderButton").Center.X, GetBox("DefenderButton").Center.Y)
				PrimitiveMan:DrawBitmapPrimitive(self.CurrentScreen, Pos + Vector(-2, 0), Defender, 0, 0)
			end
		),

		InteractiveMenu.Button("DestroyerButton", 40, 45, 30, 30, 80, true, true, "Cost: " .. ItemPrices[2], "down", true,
			function()
				if self.resource >= ItemPrices[2] then 
					self.resource = self.resource - ItemPrices[2]
					GiveItem(actor, "Destroyer Capsule")
					self.SuccessSound:Play(actor.Pos)
				else
					self.FailSound:Play(actor.Pos)
				end
			end,
			function()
				local Destroyer
				if not Destroyer then
					Destroyer = CreateMOSRotating("Factorio.rte/Destroyer Icon")
				end
				local Pos = InteractiveMenu.ScreenPos(self, GetBox("DestroyerButton").Center.X, GetBox("DestroyerButton").Center.Y)
				PrimitiveMan:DrawBitmapPrimitive(self.CurrentScreen, Pos + Vector(-2, 0), Destroyer, 0, 0)
			end
		),

		InteractiveMenu.Button("GrenadeButton", 75, 45, 30, 30, 80, true, true, "Cost: " .. ItemPrices[3], "down", true,
			function()
				if self.resource >= ItemPrices[3] then
					self.resource = self.resource - ItemPrices[3]
					GiveItem(actor, "Grenade")
					self.SuccessSound:Play(actor.Pos)
				else
					self.FailSound:Play(actor.Pos)
				end
			end,
			function()
				local Grenade
				if not Grenade then
					Grenade = CreateMOSRotating("Factorio.rte/Grenade Icon")
				end
				local Pos = InteractiveMenu.ScreenPos(self, GetBox("GrenadeButton").Center.X, GetBox("GrenadeButton").Center.Y)
				PrimitiveMan:DrawBitmapPrimitive(self.CurrentScreen, Pos + Vector(-2, 0), Grenade, 0, 0)
			end
		),

		InteractiveMenu.Button("ClusterGButton", 110, 45, 30, 30, 80, true, true, "Cost: " .. ItemPrices[4], "down", true,
			function()
				if self.resource >= ItemPrices[4] then
					self.resource = self.resource - ItemPrices[4]
					GiveItem(actor, "Cluster Grenade")
					self.SuccessSound:Play(actor.Pos)
				else
					self.FailSound:Play(actor.Pos)
				end
			end,
			function()
				local ClusterGrenade
				if not ClusterGrenade then
					ClusterGrenade = CreateMOSRotating("Factorio.rte/Cluster Grenade Icon")
				end
				local Pos = InteractiveMenu.ScreenPos(self, GetBox("ClusterGButton").Center.X, GetBox("ClusterGButton").Center.Y)
				PrimitiveMan:DrawBitmapPrimitive(self.CurrentScreen, Pos + Vector(-2, 0), ClusterGrenade, 0, 0)
			end
		),

		InteractiveMenu.Button("CloseButton", 130, 0, 15, 15, 83, true, true, nil, nil, true,
			function()
				self.Activity:SwitchToActor(actor, self.Team, self.Team) --We don't need to call DeleteFCursor, it will check if the cursor is alive regardless
			end,
			function()
				local Pos = InteractiveMenu.ScreenPos(self, GetBox("CloseButton").Center.X, GetBox("CloseButton").Center.Y)
				PrimitiveMan:DrawLinePrimitive(self.CurrentScreen, Pos + Vector(3, 3), Pos + Vector(-7, -7), 20)
				PrimitiveMan:DrawLinePrimitive(self.CurrentScreen, Pos + Vector(3, -7), Pos + Vector(-7, 3), 20)
			end
		),

		InteractiveMenu.Label("ConstructMenuTitle", 25, 0, GetMaterialCount(self), false, true,
		function()
			return GetMaterialCount(self)
		end
		)
	}
	self[table] = {CMenu}

	InteractiveMenu.TableChecker(self, table)
end