package.path = package.path .. ";Mods/[B]InteractiveMenu.rte/Script/?.lua";
require("InteractiveMenu")

InteractiveMenu.InitializeCoreTable("Assembly")

InteractiveMenu.Assembly.Create = function(self) 
	self.FailSound = CreateSoundContainer("Factorio.rte/Failed Construction")
	self.SuccessSound = CreateSoundContainer("Factorio.rte/Finished Construction")
    self.ClickSound = CreateSoundContainer("Factorio.rte/Factorio Menu Click")

	self.ASSPBarTimer = Timer()
	self.ASSPBarDelay = 1000
	self.IsMaking = false
	self.PBarLength = 5
	self.CraftingComplete = false
	self.ItemToMake = nil
	self.ItemType = nil
	self.IsCrafting = false
end

InteractiveMenu.Assembly.Update = function(self, actor)

	local playerControlled = actor:IsPlayerControlled()

	local mouse = "FAMouse"
	local menu = "FAMenu"
	local PATH = "Factorio.rte/Factorio Mouse"

	if playerControlled then
		if actor:GetNumberValue("ActiveAssemblyMenu") == 0 then
			actor:SetNumberValue("ActiveAssemblyMenu", 1)

            self[menu] = {}
        
            local ASSMenu = InteractiveMenu.Root("AssemblyMenu", 435, 150, 220, 125, 0, false, {})

            local function ExistanceCheck(RootName, ...)
                for i = #RootName.Child, 1, -1 do
                    local child = RootName.Child[i]
					for _, CategoryList in ipairs({...}) do
                    	for _, Button in ipairs(CategoryList) do
                    	    if child.Name == Button.Name then
                    	        table.remove(RootName.Child, i)
                    	        break
                    	    end
                    	end
					end
                end
            end

			local ItemPrices = {500, 1000, 350, 450, 1}

			local function GetMaterialCount(self)
                return "Material Count: " .. tostring(math.floor(actor:GetNumberValue("AssemblyMaterial")))
            end

			local ProgressMenuX = -5
			local ProgressMenuY = -5
			local CraftingMenuBorderX = -5
			local CraftingMenuBorderY = -5
			local ProgressBarX = 13
			local ProgressBarY = 70
			local CraftingMenuX = 230
			local BGHeight = 25

			local CraftingTime = {1000, 1500}
            
            ASSMenu.Child = {

				InteractiveMenu.Box("AssemblyMenuCraftingFG", CraftingMenuX + CraftingMenuBorderX, CraftingMenuBorderY, 150 - CraftingMenuBorderX + 5, ASSMenu.Height - CraftingMenuBorderY - BGHeight + 5, 207, true),
                InteractiveMenu.Box("AssemblyMenuCraftingBG", CraftingMenuX, 0, 150, ASSMenu.Height - BGHeight, 208, true),

				InteractiveMenu.Box("AssemblyMenuFG", ProgressMenuX, ProgressMenuY, ASSMenu.Width - ProgressMenuX + 5, ASSMenu.Height - ProgressMenuY - BGHeight + 5, 207, true),
                InteractiveMenu.Box("AssemblyMenuBG", 0, 0, ASSMenu.Width, ASSMenu.Height - BGHeight, 208, true),

				InteractiveMenu.Box("AssemblyMenuProgressBarBG", ProgressBarX, ProgressBarY, 190, 10, 247, true),

				InteractiveMenu.Box("AssemblyMenuProgressBarFG", ProgressBarX, ProgressBarY, self.PBarLength, 10, 162, false,
				function()
					self.IsProgressBar = true
                end
				),

                InteractiveMenu.Label("AssemblyMenuTitle", 0, 0, 0, 0, 100, 100, "A S S E M B L Y\nT I E R 1 \nA U T O M A T I O N", true, true),
				InteractiveMenu.Label("AssemblyMenuMaterialCount", 0, 29, 0, 0, 100, 100, GetMaterialCount(self), false, true, function() return GetMaterialCount(self) end),
            }

			local AssemblyList = {
                {Name = "DefenderButton",   Sprite = "Defender Icon",           Type = CreateTDExplosive, Item = "Defender Capsule",  Price = 1, Time = 150},
                {Name = "DestroyerButton",  Sprite = "Destroyer Icon",          Type = CreateTDExplosive, Item = "Destroyer Capsule", Price = 2, Time = 300},
                {Name = "GrenadeButton",    Sprite = "Grenade Icon",            Type = CreateTDExplosive, Item = "Grenade",           Price = 3, Time = 100},
                {Name = "ClusterGButton",   Sprite = "Cluster Grenade Icon",    Type = CreateTDExplosive, Item = "Cluster Grenade",   Price = 4, Time = 180}
            }

			local function DisplayAssemblyList(actor)
				ExistanceCheck(ASSMenu, AssemblyList)

                local Rows = 4
                --local numRows = math.ceil(#AssemblyList / Rows) -- active num of rows

                for i, AB in ipairs(AssemblyList) do
                    local x = CraftingMenuX + 10 + ((i - 1) % Rows + 1 - 1) * 35
                    local y = 7 + (math.floor((i - 1) / Rows) + 1 - 1) * 35
            
                    local AssemblyButton = InteractiveMenu.Button(AB.Name, x, y, 26, 26, 248, actor:GetNumberValue("AssemblyMaterial") >= ItemPrices[AB.Price] and 86 or 13, true, true, "Cost: " .. ItemPrices[AB.Price], "down", true, false,
                        function()
							if self.IsMaking then return end
                            if actor:GetNumberValue("AssemblyMaterial") >= ItemPrices[AB.Price] then
								self:SetNumberValue("AssemblyMaterial", self:GetNumberValue("AssemblyMaterial") - ItemPrices[AB.Price])
								self.IsMaking = true
								self.ItemToMake = AB.Item
								self.ItemType = AB.Type
								self.ASSPBarDelay = AB.Time
								self.IsCrafting = true
                                self.ClickSound:Play(actor.Pos)
                            else
                                self.FailSound:Play(actor.Pos)
                            end
                        end,
                        function()
                            local box = InteractiveMenu.GetBoxName(AB.Name)
                            local Pos = InteractiveMenu.ScreenPos(self, actor, box.Corner.X, box.Corner.Y)
                            local spritePath = "Factorio.rte/" .. AB.Sprite
                            PrimitiveMan:DrawBitmapPrimitive(InteractiveMenu.GetScreen(actor), Pos + Vector(11, 14), CreateMOSRotating(spritePath), 0, 0)
                        end
                    )
                    table.insert(ASSMenu.Child, self.ItemBoxs + 3, AssemblyButton)
                end
            end

			local function DisplayItemBoxs()
                local BoxCount = 4
                local Rows = 4

                for i = 1, BoxCount do
                    local x = CraftingMenuX + 8 + ((i - 1) % Rows + 1 - 1) * 35
                    local y = 5 + (math.floor((i - 1) / Rows) + 1 - 1) * 35
            
                    local ButtonBox = InteractiveMenu.Box("AssemblyButtonBox " .. i, x, y, 30, 30, 247, true)

                    table.insert(ASSMenu.Child, 3, ButtonBox)
                    self.ItemBoxs = i
                end
            end

            DisplayItemBoxs()
			DisplayAssemblyList(actor)

            self[menu] = {ASSMenu}

            InteractiveMenu.CreateMenu(self, actor, mouse, PATH, menu)
		end
	else
		if actor:GetNumberValue("ActiveAssemblyMenu") ~= 0 then
			actor:SetNumberValue("ActiveAssemblyMenu", 0)
		end
	end

	local function ActiveProgressBar(BG, FG)
		local boxBG = InteractiveMenu.GetBoxName(BG)
		local boxFG = InteractiveMenu.GetBoxName(FG)
		local ChildBox = InteractiveMenu.GetChildName(self, menu, FG)
		boxFG.Width = self.PBarLength
		if self.IsMaking then
			ChildBox.Visible = true
			actor.SpriteAnimMode = 1
			actor.SpriteAnimDuration = 1000
			if self.ASSPBarTimer:IsPastSimMS(self.ASSPBarDelay) then
				self.PBarLength = self.PBarLength + 5
				self.ASSPBarTimer:Reset()
			end
			if self.PBarLength == boxBG.Width + 5 then
				self.PBarLength = 5
				self.CraftingComplete = true
				self.IsMaking = false
			end
		else
			ChildBox.Visible = false
			self.ASSPBarTimer:Reset()
			actor.SpriteAnimMode = 0
		end
	end

	local function CraftingStatus(actor)
		if self.CraftingComplete then
			local weapon = self.ItemType("Factorio.rte/" .. self.ItemToMake)
			weapon.Pos = actor.Pos  + Vector(-50, 6)
			weapon.HFlipped = true
			weapon.RotAngle = 0.45
			weapon.Vel = Vector()
			MovableMan:AddItem(weapon)
			self.ASSPBarDelay = 1000
			self.ItemToMake = nil
			self.ItemType = nil
			self.SuccessSound:Play(actor.Pos)
			self.CraftingComplete = false
			self.IsCrafting = false
		end
	end

	if self.IsProgressBar then
		ActiveProgressBar("AssemblyMenuProgressBarBG", "AssemblyMenuProgressBarFG")
	end

	if self.IsCrafting then
		CraftingStatus(actor)
	end

	InteractiveMenu.UpdateMenu(self, actor, mouse, menu)
end