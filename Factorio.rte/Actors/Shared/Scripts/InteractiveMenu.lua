function CreateFCursor(self)
    local BASE_PATH = "Factorio.rte/"

    self.FCursor = CreateActor(BASE_PATH .. "Factorio Static Actor")
	self.FCursor.Pos = self.Engineer.Pos
	self.FCursor.Team = -1
    
	self.FCursor.IgnoresTeamHits = true
	self.FCursor.HUDVisible = false

	MovableMan:AddActor(self.FCursor)
    self.Activity:SwitchToActor(self.FCursor, self.ctrlplayer, self.CurrentTeam)

    self.Mouse = self.FCursor.Pos
    self.Mid = self.FCursor.Pos
    self.ResX2 = FrameMan.PlayerScreenWidth / 3
    self.ResY2 = FrameMan.PlayerScreenHeight / 3

    self.Cursor = CreateMOSRotating(BASE_PATH .. "Factorio Mouse")
    self.Cursor.Pos = self.Mouse + Vector(4.5, 10)
    self.Cursor.HitsMOs = false
    self.Cursor.GetsHitByMOs = false

	self.CursorExist = true

    self.FCtrl = self.FCursor:GetController()
end
function Create(self)
    --Get the information about the player
    self.Activity = ActivityMan:GetActivity()
    self.ctrlplayer = self:GetController().Player
    self.ctrlactor = self:GetController()
    self.CurrentTeam = self.Activity:GetTeamOfPlayer(self.ctrlplayer)
    self.CurrentScreen = self.Activity:ScreenOfPlayer(self.ctrlplayer)


    --[[
        If we have multiple Engineer's they won't affect eachother because they each will have different ID's
    ]]
    
    local CurrentID = "Engineer " .. tostring(self.ID)

    self:SetNumberValue(CurrentID, self.ID)

    for actor in MovableMan.Actors do
        if actor:GetNumberValue(CurrentID) == self.ID then
            self.Engineer = ToAHuman(actor)
        end
    end

    --self.EngineerID = self:GetNumberValue(CurrentID)
    --print("\nName: " .. self.Engineer.PresetName .. "" .. " \nID: " .. self.EngineerID)
end

function DrawCursor(self)
	self.Cursor.Pos = self.Mouse + Vector(5, 10)
	PrimitiveMan:DrawBitmapPrimitive(self.CurrentScreen, self.Cursor.Pos, self.Cursor, 0, 0)
end

function FreezeActor(self)
    local ControlState = {
        Controller.MOVE_UP,
        Controller.MOVE_DOWN,
        Controller.BODY_JUMPSTART,
        Controller.BODY_JUMP,
        Controller.BODY_CROUCH,
        Controller.MOVE_LEFT,
        Controller.MOVE_RIGHT,
        Controller.MOVE_IDLE,
        Controller.MOVE_FAST,
        Controller.AIM_UP,
        Controller.AIM_DOWN,
        Controller.AIM_SHARP,
        Controller.WEAPON_FIRE,
        Controller.WEAPON_RELOAD,
    }
    for _, input in ipairs(ControlState) do
        self.ctrlactor:SetState(input, false)
    end

    --Precaution
    if self.EquippedItem and self.EquippedItem.PresetName ~= "Engineer's Tool" then
        self.ctrlactor:SetState(Controller.WEAPON_CHANGE_PREV, true)
    end
end

function UpdateFCursor(self)
    self.FCursor.Pos = self.Engineer.Pos -- Never leave the actor that we are controlling!

	--If User has Mouse then we mouse, if not we Xbox the 360
	if self.FCtrl:IsMouseControlled() == true then
        self.Mouse = self.Mouse + UInputMan:GetMouseMovement(self.CurrentTeam)
	else
		if self.FCtrl:IsState(Controller.MOVE_LEFT) then
			self.Mouse = self.Mouse + Vector(-5,0)
		end

		if self.FCtrl:IsState(Controller.MOVE_RIGHT) then
			self.Mouse = self.Mouse + Vector(5,0)
		end

		if self.FCtrl:IsState(Controller.MOVE_UP) then
			self.Mouse = self.Mouse + Vector(0,-5)
		end

		if self.FCtrl:IsState(Controller.MOVE_DOWN) then
			self.Mouse = self.Mouse + Vector(0,5)
		end
	end

	-- Don't let the cursor leave the screen
	if self.Mouse.X - self.Mid.X < -self.ResX2 then
		self.Mouse.X = self.Mid.X - self.ResX2;
	end

	if self.Mouse.Y - self.Mid.Y < -self.ResY2 then
		self.Mouse.Y = self.Mid.Y - self.ResY2;
	end

	if self.Mouse.X - self.Mid.X > self.ResX2 - 10 then
		self.Mouse.X = self.Mid.X + self.ResX2 - 10;
	end

	if self.Mouse.Y - self.Mid.Y > self.ResY2 - 10 then
		self.Mouse.Y = self.Mid.Y + self.ResY2 - 10;
	end

    for _, Parent in ipairs(self.LCPanels) do
        local Frame = self.InteractiveBox[Parent.Name]

        local PBox = Parent.ControlType == "COLLECTIONBOX"

        if PBox then
            local cornerX, cornerY = Frame.Corner.X, Frame.Corner.Y
            local width, height = Frame.Width, Frame.Height
            local topleftPos = ScreenPos(cornerX, cornerY)
            local bottomRightPos = topleftPos + Vector(width - 4.5, height - 4.5)
            PrimitiveMan:DrawBoxFillPrimitive(topleftPos, bottomRightPos, Parent.Color)
            Frame = Box(topleftPos, width, height )
        end
        if Parent.Child then
            for _, Child in ipairs(Parent.Child) do
                local Panel = self.InteractiveBox[Child.Name]
                local CBox = Child.ControlType == "COLLECTIONBOX"
                local CButton = Child.ControlType == "BUTTON"
                local CSlider = Child.ControlType == "SLIDER"
                local CLabel = Child.ControlType == "LABEL"

                --If we only need to Draw the Box we do this
                if CBox or CButton or CSlider then
                    local cornerX, cornerY = Panel.Corner.X, Panel.Corner.Y
                    local width, height = Panel.Width, Panel.Height
                    local topleftPos = ScreenPos(cornerX, cornerY)
                    local bottomRightPos = topleftPos + Vector(width - 4.5, height - 4.5)
                    PrimitiveMan:DrawBoxFillPrimitive(topleftPos, bottomRightPos, Child.Color)
                    Panel = Box(topleftPos, width, height )
                end

                --If we only need to Draw the Text we do this
                if CLabel then
                    local TexPos = ScreenPos(Child.PosX, Child.PosY)
                    PrimitiveMan:DrawTextPrimitive(0, TexPos, Child.Text, Child.isSmall, 0);
                end

                if CButton then
                    if Panel:IsWithinBox(ToMOSRotating(self.Cursor).Pos) then
                        if Child.IsClickable then
                            Child.Clicked = true
                        end
                        if Child.ToolTip then
                            PrimitiveMan:DrawTextPrimitive(0, Vector(Panel.Corner.X, Panel.Corner.Y) + Vector(30, 10), Child.ToolTip, Child.isSmall, 0)
                        end
                    else
                        if Child.IsClickable then
                            if Child.Clicked then
                                Child.Clicked = false
                            end
                        end
                    end
                    if Child.Clicked then
                        local Clicked = self.FCtrl:IsState(Controller.WEAPON_FIRE)
                        if (Clicked and Child.OnClick) and not self.ConfirmClick then
                            Child.OnClick()
                            self.ConfirmClick = true
                        elseif not Clicked then
                            self.ConfirmClick = false
                        end
                    end
                end
            end
        end
    end
    DrawCursor(self)
end

function Update(self)

    if self:IsPlayerControlled() then
        if self.EquippedItem and self.EquippedItem.PresetName == "Engineer's Tool" then
            if UInputMan:KeyPressed(Key.C) then
                CreateFCursor(self)
                CreateMenu(self)
            end
        end
    end

    if self.Engineer.EquippedItem and self.Engineer.EquippedItem.PresetName == "Engineer's Tool" then
    end


    --Communication between actors is still possible because we are still inside our main actor!
    if self.FCursor then
        if self.FCursor:IsPlayerControlled() then
            if self.Health <= 0 then -- For some reason this is better than self:Dead()
                DeleteFCursor(self)
            end
        else
            DeleteFCursor(self)
            self.Activity:SwitchToActor(self.Engineer, self.ctrlplayer, self.CurrentTeam) --This is amazing that it works
        end
    end
    if self.CursorExist then
        UpdateFCursor(self)
        FreezeActor(self)
    end
end

function DeleteFCursor(self)
    if not self.FCursor.ToDelete then
        self.FCursor.ToDelete = true
        self.Cursor.ToDelete = true
        self.CursorExist = false
        self.Mouse = nil
    end
end

function ScreenPos(PosX, PosY)
	local Screen = Vector(
		CameraMan:GetOffset(Activity.PLAYER_1).X + PosX,
		CameraMan:GetOffset(Activity.PLAYER_1).Y + PosY
	)
	return Screen
end

function CreateMenu(self)
    self.InteractiveBox = {}

    self.LCPanels = {}

    --[[
    --? E L E M E N T S

    --? You only need to call these Elements once, it'll do some checks to prevent it from falling apart
    Name
    ToolTip
    Text
    isSmall
    HAlignment
    PosX
    PosY
    Width
    Height
    Color -- Palette Index
    Visible
    IsClickable
    Clicked


    --? F U N C T I O N S
    OnClick = function()
        print("Inventory box was clicked!")
    end,

    Update = function()
        print("Always Updating!")
    end,
    ]]

    self.LCPanels[1] = {
        ControlType = "COLLECTIONBOX",
        Name = "CollectionBoxSaveGameMenu",
        PosX = 565,
        PosY = 200,
        Width = 250,
        Height = 151,
        Color = 170,
        Visible = true,
        Child = {
            {
                ControlType = "BUTTON",
                Name = "DefenderButton",
                ToolTip = "Costs 500",
                isSmall = true,
                PosX = 0,
                PosY = 50,
                Width = 50,
                Height = 50,
                Color = 13,
                Visible = true,
                IsClickable = true,
                Clicked = false,
                OnClick = function()
                    if ToHDFirearm(self.EquippedItem).Magazine.RoundCount > 500 then
                        ToHDFirearm(self.EquippedItem).Magazine.RoundCount = ToHDFirearm(self.EquippedItem).Magazine.RoundCount - 499
                        self.Engineer:AddInventoryItem(CreateTDExplosive("Defender Capsule", "Factorio.rte"))
                    else
                        print("NO ENOUGH CASH")
                    end
                end,
            },
            {
                ControlType = "LABEL",
                Name = "LabelSaveGameMenuTitle",
                Text = "Material Count: " .. tostring(ToHDFirearm(self.EquippedItem).Magazine.RoundCount),
                HAlignment = "left",
                isSmall = false,
                PosX = 0,
                PosY = 0,
                Width = 550,
                Height = 32,
                Visible = true,
            },
        }
    }

    local screenW = FrameMan.PlayerScreenWidth / 1920
    local screenH = FrameMan.PlayerScreenHeight / 1080

    for _, Parent in ipairs(self.LCPanels) do
        self.InteractiveBox[Parent.Name] = {}
        local ParentPos = Vector(Parent.PosX, Parent.PosY) -- Positions are not scaled
        local ParentWidth = Parent.Width * screenW
        local ParentHeight = Parent.Height * screenH
        self.InteractiveBox[Parent.Name] = Box(ParentPos, ParentWidth, ParentHeight)

        if Parent.Child then
            for _, Child in ipairs(Parent.Child) do

                local Root = self.InteractiveBox[Parent.Name]

                local CBox = Child.ControlType == "COLLECTIONBOX"
                local CButton = Child.ControlType == "BUTTON"
                local CLabel = Child.ControlType == "LABEL"

                if CBox or CButton then
                    local ChildPos = Vector(Child.PosX, Child.PosY)
                    local ChildWidth = Child.Width * screenW
                    local ChildHeight = Child.Height * screenH
                    local NewPos = ParentPos + ChildPos
                    self.InteractiveBox[Child.Name] = Box(NewPos, ChildWidth, ChildHeight)
                end

                if Child.ControlType == "LABEL" then
                    local textWidth = #Child.Text
                    local case = string.lower(Child.HAlignment)
                    if case == "left" then
                        Child.PosX = Parent.PosX

                    elseif case == "center" then
                        Child.PosX = Root.Center.X + (Child.Width - textWidth) / -7

                    elseif case == "right" then
                        Child.PosX = Root.Center.X - textWidth - Parent.PosX / -3
                    end
                    Child.PosY = Child.PosY + Parent.PosY
                end
            end
        end
    end
end
--[[
This was bad at first but I'm going to keep it here for if I need it later

function CreateFCursor(self)
    local BASE_PATH = "Factorio.rte/"

    for player = 0, self.Activity.PlayerCount - 1 do
        if self.Activity:PlayerActive(player) and self.Activity:PlayerHuman(player) then
            local team = self.Activity:GetTeamOfPlayer(player)

            self.FCursor[player] = CreateActor(BASE_PATH .. "Factorio Static Actor")
            self.FCursor[player].Pos = self.Activity:GetControlledActor(player).Pos
            self.FCursor[player].Team = team
            self.FCursor[player].IgnoresTeamHits = true
            self.FCursor[player].HUDVisible = false
            self.CursorExist[player] = true

            MovableMan:AddActor(self.FCursor[player])
            self.Activity:SwitchToActor(self.FCursor[player], player, team)

            self.Mouse[player] = self.FCursor[player].Pos
            self.Mid[player] = self.FCursor[player].Pos

            self.Cursor[player] = CreateMOSRotating(BASE_PATH .. "Factorio Mouse")
            self.Cursor[player].Pos = self.Mouse[player] + Vector(4.5, 10)
            self.Cursor[player].HitsMOs = false
            self.Cursor[player].GetsHitByMOs = false

            self.ResX2[player] = FrameMan.PlayerScreenWidth / 2
            self.ResY2[player] = FrameMan.PlayerScreenHeight / 2

            print(self.FCursor[player].Team)
        end
    end
end
function Create(self)
    self.Cursor = {}

    self.FCursor = {}
    self.CursorExist = {}

    self.Mouse = {}
    self.Mid = {}

    self.ResX2 = {}
    self.ResY2 = {}
    self.Activity = ActivityMan:GetActivity()
end
]]