package.path = package.path .. ";Mods/[B]InteractiveMenu.rte/Script/?.lua";
require("InteractiveMenu")

InteractiveMenu.InitializeCoreTable("Assembly")

InteractiveMenu.Assembly.Create = function(self) 
	self.FailSound = CreateSoundContainer("Factorio.rte/Failed Construction")
	self.SuccessSound = CreateSoundContainer("Factorio.rte/Finished Construction")
    self.ClickSound = CreateSoundContainer("Factorio.rte/Factorio Menu Click")

	self.Activity = ActivityMan:GetActivity()
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
        
            local ASSMenu = InteractiveMenu.Root("AssemblyMenu", 570, 125, 150, 180, 0, false, {})

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

			local BorderX = -5
			local BorderY = -5
            
            ASSMenu.Child = {
				InteractiveMenu.Box("AssemblyMenuBorder", BorderX, BorderY, ASSMenu.Width - BorderX + 5, ASSMenu.Height - BorderY + 5, 247, true),
                InteractiveMenu.Box("AssemblyMenuBG", 0, 0, ASSMenu.Width, ASSMenu.Height, 250, true),

                InteractiveMenu.Button("CloseButton", ASSMenu.Width - 20, ASSMenu.Height - 180, 20, 20, 247, 251, true, true, nil, nil, true, false,
                function()
                    InteractiveMenu.Delete(self, mouse)
                end,
                function()
                    local box = InteractiveMenu.GetBoxName("CloseButton")
                    local ChildBox = InteractiveMenu.GetChildName(self, menu, "CloseButton")
                    local Pos = InteractiveMenu.ScreenPos(self, actor, box.Corner.X, box.Corner.Y)


                    PrimitiveMan:DrawLinePrimitive(self.CurrentScreen, Pos + Vector(15, 15), Pos + Vector(0, 0), ChildBox.OnHover and 247 or 251)
                    PrimitiveMan:DrawLinePrimitive(self.CurrentScreen, Pos + Vector(0, 15), Pos + Vector(15, 0), ChildBox.OnHover and 247 or 251)
                end
                ),

                InteractiveMenu.Label("AssemblyMenuTitle", 25, 0, 0, 0, 100, 100, "Assembly", false, true),
            }

            self[menu] = {ASSMenu}

            InteractiveMenu.CreateMenu(self, actor, mouse, PATH, menu)
		end
	else
		if actor:GetNumberValue("ActiveAssemblyMenu") ~= 0 then
			actor:SetNumberValue("ActiveAssemblyMenu", 0)
		end
	end

	InteractiveMenu.UpdateMenu(self, actor, mouse, menu)
end