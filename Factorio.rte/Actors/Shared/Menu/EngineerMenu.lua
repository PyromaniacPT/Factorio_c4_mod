package.path = package.path .. ";Mods/[B]InteractiveMenu.rte/Script/?.lua";
require("InteractiveMenu")

InteractiveMenu.InitializeCoreTable("Engineer")

InteractiveMenu.Engineer.Create = function(self) 
	self.FailSound = CreateSoundContainer("Factorio.rte/Failed Construction")
	self.SuccessSound = CreateSoundContainer("Factorio.rte/Finished Construction")
    self.ClickSound = CreateSoundContainer("Factorio.rte/Factorio Menu Click")

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

            self[menu] = {}

            local function GetMaterialCount(self)
                return "Material Count: " .. tostring(math.floor(self.Magazine and self.Magazine.RoundCount or self.resource))
            end
        
            local function GiveItem(actor, type, item)
                actor:AddInventoryItem(type("Factorio.rte/" .. item))
            end

			local function SpawnMachine(actor, MachineActor)

				local Machine = CreateActor("Factorio.rte/" .. MachineActor)
				Machine.Pos = actor.Pos + Vector(0, 2)
				Machine.Team = actor.Team
				Machine.HUDVisible = false
				MovableMan:AddActor(Machine)

            end
        
            local ItemPrices = {500, 1000, 350, 450, 1800}
        
            local CMenu = InteractiveMenu.Root("ConstructMenu", 570, 125, 150, 180, 0, false, {})

            local MilitaryList = {
                {Name = "DefenderButton",   Sprite = "Defender Icon",           Type = CreateTDExplosive, Item = "Defender Capsule",  Price = 1},
                {Name = "DestroyerButton",  Sprite = "Destroyer Icon",          Type = CreateTDExplosive, Item = "Destroyer Capsule", Price = 2},
                {Name = "GrenadeButton",    Sprite = "Grenade Icon",            Type = CreateTDExplosive, Item = "Grenade",           Price = 3},
                {Name = "ClusterGButton",   Sprite = "Cluster Grenade Icon",    Type = CreateTDExplosive, Item = "Cluster Grenade",   Price = 4}
            }

			local ProductList = {
                {Name = "AssemblyMachine1Button",	Sprite = "Assembly Machine 1 Icon",	Spawn = "Assembly Machine 1",	Price = 5},
            }

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

            local function DisplayMilitary(actor)
				ExistanceCheck(CMenu, ProductList, MilitaryList)

                local Rows = 4
                --local numRows = math.ceil(#MilitaryList / Rows) -- active num of rows

                for i, MB in ipairs(MilitaryList) do
                    local x = 7 + ((i - 1) % Rows + 1 - 1) * 35
                    local y = 102 + (math.floor((i - 1) / Rows) + 1 - 1) * 35
            
                    local MilitaryButton = InteractiveMenu.Button(MB.Name, x, y, 26, 26, 248, self.resource >= ItemPrices[MB.Price] and 86 or 13, true, true, "Cost: " .. ItemPrices[MB.Price], "down", true, false,
                        function()
                            if self.resource >= ItemPrices[MB.Price] then
                                self.resource = self.resource - ItemPrices[MB.Price]
                                GiveItem(actor, MB.Type, MB.Item)
                                self.SuccessSound:Play(actor.Pos)
                            else
                                self.FailSound:Play(actor.Pos)
                            end
                        end,
                        function()
                            local box = InteractiveMenu.GetBoxName(MB.Name)
                            local Pos = InteractiveMenu.ScreenPos(self, box.Corner.X, box.Corner.Y)
                            local spritePath = "Factorio.rte/" .. MB.Sprite
                            PrimitiveMan:DrawBitmapPrimitive(self.CurrentScreen, Pos + Vector(11, 14), CreateMOSRotating(spritePath), 0, 0)
                        end
                    )
                    table.insert(CMenu.Child, self.ItemBoxs + 2, MilitaryButton)
                end
                InteractiveMenu.InitializeTable(self, menu)
            end

			local function DisplayProduct(actor)
				ExistanceCheck(CMenu, ProductList, MilitaryList)

                local Rows = 4
                --local numRows = math.ceil(#ProductList / Rows) -- active num of rows

                for i, PB in ipairs(ProductList) do
                    local x = 7 + ((i - 1) % Rows + 1 - 1) * 35
                    local y = 102 + (math.floor((i - 1) / Rows) + 1 - 1) * 35
            
                    local ProductButton = InteractiveMenu.Button(PB.Name, x, y, 26, 26, 248, self.resource >= ItemPrices[PB.Price] and 86 or 13, true, true, "Cost: " .. ItemPrices[PB.Price], "down", true, false,
                        function()
                            if self.resource >= ItemPrices[PB.Price] then
                                self.resource = self.resource - ItemPrices[PB.Price]
								SpawnMachine(actor, PB.Spawn)
                                self.SuccessSound:Play(actor.Pos)
                            else
                                self.FailSound:Play(actor.Pos)
                            end
                        end,
                        function()
                            local box = InteractiveMenu.GetBoxName(PB.Name)
                            local Pos = InteractiveMenu.ScreenPos(self, box.Corner.X, box.Corner.Y)
                            local spritePath = "Factorio.rte/" .. PB.Sprite
                            PrimitiveMan:DrawBitmapPrimitive(self.CurrentScreen, Pos + Vector(11, 14), CreateMOSRotating(spritePath), 0, 0)
                        end
                    )
                    table.insert(CMenu.Child, self.ItemBoxs + 2, ProductButton)
                end
                InteractiveMenu.InitializeTable(self, menu)
            end
            
            CMenu.Child = {
        
                InteractiveMenu.Box("ConstructMenuBackground", 0, 0, CMenu.Width, CMenu.Height, 250, true),

                InteractiveMenu.Button("CloseButton", 128, 4, 20, 20, 247, 251, true, true, nil, nil, true, false,
                function()
                    InteractiveMenu.Delete(self, mouse)
                end,
                function()
                    local box = InteractiveMenu.GetBoxName("CloseButton")
                    local ChildBox = InteractiveMenu.GetChildName(self, menu, "CloseButton")
                    local Pos = InteractiveMenu.ScreenPos(self, box.Corner.X, box.Corner.Y)


                    PrimitiveMan:DrawLinePrimitive(self.CurrentScreen, Pos + Vector(15, 15), Pos + Vector(0, 0), ChildBox.OnHover and 247 or 251)
                    PrimitiveMan:DrawLinePrimitive(self.CurrentScreen, Pos + Vector(0, 15), Pos + Vector(15, 0), ChildBox.OnHover and 247 or 251)
                end
                ),
            
                InteractiveMenu.Label("ConstructMenuTitle", CMenu.PosX + 25, CMenu.PosY + 1, GetMaterialCount(self), false, true, function() return GetMaterialCount(self) end),
            
                --Borders
            
                InteractiveMenu.Box("CornerFrameUp", -2, 0, CMenu.Width, 8, 247, true),
            
                InteractiveMenu.Box("CornerFrameDown", -4, CMenu.Height - 5, CMenu.Width + 4, 8, 247, true),
            
                InteractiveMenu.Box("CornerFrameLeft", -4, 0, 8, CMenu.Height, 247, true),
            
            
                InteractiveMenu.Box("CornerFrameRight", CMenu.Width - 6, 0, 8, CMenu.Height + 3, 247, true),
            }


            local Category = {
                --{Name = "LogicButton",                  ToolTip = "LOGISTICS",              func = function() DisplayLogic(actor) end, Sprite = "logistics"},
                {Name = "ProductButton",                ToolTip = "PRODUCTION",             func = function() DisplayProduct(actor) end, Sprite = "production"},
                --{Name = "intermediateProductButton",    ToolTip = "INTERMEDIATE PRODUCTS",  func = function() DisplayINProduct(actor) end, Sprite = "intermediate-products"},
                {Name = "MilitaryButton",               ToolTip = "MILITARY",               func = function() DisplayMilitary(actor) end, Sprite = "military"}
            }

            for i, CB in ipairs(Category) do
                local x = 10 + (i - 1) * 70
            
                local button = InteractiveMenu.Button(CB.Name, x, 25, 60, 65, 247, 251, true, true, CB.ToolTip, "down", true, false,
                    function()
                        CB.func()
                        self.ClickSound:Play(actor.Pos)
                    end,
                    function()
                        local box = InteractiveMenu.GetBoxName(CB.Name)
                        local Pos = InteractiveMenu.ScreenPos(self, box.Corner.X, box.Corner.Y)
                        local spritePath = "Factorio.rte/" .. CB.Sprite
                        PrimitiveMan:DrawBitmapPrimitive(self.CurrentScreen, Pos + Vector(27, 35), CreateMOSRotating(spritePath), 0, 0)
                    end
                )

                table.insert(CMenu.Child, 2, button)
            end

            local function DisplayCategoryBoxs()
                for i, _ in ipairs(Category) do
                    local x = 5 + (i - 1) * 70

                    local CategoryBox = InteractiveMenu.Box("CategoryBox " .. i, x, 20, 70, 75, 247, true)

                    table.insert(CMenu.Child, 2, CategoryBox)
                end
            end

            DisplayCategoryBoxs()

            local function DisplayItemBoxs()
                local BoxCount = 4
                local Rows = 4

                for i = 1, BoxCount do
                    local x = 5 + ((i - 1) % Rows + 1 - 1) * 35
                    local y = 100 + (math.floor((i - 1) / Rows) + 1 - 1) * 35
            
                    local ButtonBox = InteractiveMenu.Box("ButtonBox " .. i, x, y, 30, 30, 247, true)

                    table.insert(CMenu.Child, 2, ButtonBox)
                    self.ItemBoxs = i
                end
            end

            DisplayItemBoxs()

            self[menu] = {CMenu}

            InteractiveMenu.CreateMenu(self, actor, mouse, PATH, menu)
		end
	end

	InteractiveMenu.UpdateMenu(self, actor, mouse, menu)
end