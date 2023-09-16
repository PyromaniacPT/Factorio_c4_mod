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
            
            ASSMenu.Child = {
        
                InteractiveMenu.Box("AssemblyMenuBackground", 0, 0, ASSMenu.Width, ASSMenu.Height, 250, true),

                InteractiveMenu.Button("AssemblyCloseButton", 128, 4, 20, 20, 247, 251, true, true, nil, nil, true, false,
                function()
                    InteractiveMenu.Delete(self, mouse)
                end,
                function()
                    local box = InteractiveMenu.GetBoxName("AssemblyCloseButton")
                    local ChildBox = InteractiveMenu.GetChildName(self, menu, "AssemblyCloseButton")
                    local Pos = InteractiveMenu.ScreenPos(self, actor, box.Corner.X, box.Corner.Y)


                    PrimitiveMan:DrawLinePrimitive(self.CurrentScreen, Pos + Vector(15, 15), Pos + Vector(0, 0), ChildBox.OnHover and 247 or 251)
                    PrimitiveMan:DrawLinePrimitive(self.CurrentScreen, Pos + Vector(0, 15), Pos + Vector(15, 0), ChildBox.OnHover and 247 or 251)
                end
                ),
            
                InteractiveMenu.Label("AssemblyMenuTitle", 0, 0, 0, 0, 100, 100, "Test", false, true),
            
                --Borders
            
                InteractiveMenu.Box("AssemblyCornerFrameUp", -2, 0, ASSMenu.Width, 8, 247, true),
            
                InteractiveMenu.Box("AssemblyCornerFrameDown", -4, ASSMenu.Height - 5, ASSMenu.Width + 4, 8, 247, true),
            
                InteractiveMenu.Box("AssemblyCornerFrameLeft", -4, 0, 8, ASSMenu.Height, 247, true),
            
            
                InteractiveMenu.Box("AssemblyCornerFrameRight", ASSMenu.Width - 6, 0, 8, ASSMenu.Height + 3, 247, true),
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