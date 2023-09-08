function CreateFCursor(self, actor)
    local BASE_PATH = "Factorio.rte/"

    self.FCursor = CreateActor(BASE_PATH .. "Factorio Static Actor")
	self.FCursor.Pos = actor.Pos
	self.FCursor.Team = -1
    
	self.FCursor.IgnoresTeamHits = true
	self.FCursor.HUDVisible = false

	MovableMan:AddActor(self.FCursor)
    self.Activity:SwitchToActor(self.FCursor, self.Team, self.Team)

    self.Mouse = self.FCursor.Pos
    self.Mid = self.FCursor.Pos
    self.ResX2 = FrameMan.PlayerScreenWidth / 2
    self.ResY2 = FrameMan.PlayerScreenHeight / 2

    self.Cursor = CreateMOSRotating(BASE_PATH .. "Factorio Mouse")
    self.Cursor.Pos = self.Mouse + Vector(4.5, 10)
    self.Cursor.HitsMOs = false
    self.Cursor.GetsHitByMOs = false

	self.CursorExist = true

    self.FCtrl = self.FCursor:GetController()
end

function Create(self)

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
	self.FailSound = CreateSoundContainer("Factorio.rte/Failed Construction")
	self.SuccessSound = CreateSoundContainer("Factorio.rte/Finished Construction")
	self.SuccessSound.Volume = self.SuccessSound.Volume * 2

	self.operatedByAI = false
end

function CreateMenu(self, actor)
	self.LCPanels = {}

    --[[
    --? E L E M E N T S

    --? You only need to call these Elements once, it'll do some checks to prevent it from falling apart
    Name
    PosX
    PosY
    Width
    Height
	PALETTE -- Palette Index
	Text
    ToolTip
    isSmall
    Visible
    IsClickable
    Clicked

	Child - Subtables (Root is our main)


    --? F U N C T I O N S
	ONE_TIME_FUNCTION -- Happens once everytime
	CALLBACK -- Always Updating
    ]]

	local function Root(N, X, Y, W, H, PALETTE, VISIBLE, Table)
		return {
			ControlType = "COLLECTIONBOX",
			Name = N,
			PosX = X,
			PosY = Y,
			Width = W,
			Height = H,
			Color = PALETTE,
			Visible = VISIBLE,
			Child = Table,
		}
	end

	local function Button(N, X, Y, W, H, PALETTE, CLICKABLE, VISIBLE, TIP, DIRECT, SMALL, ONE_TIME_FUNCTION, CALLBACK)
		return {
			ControlType = "BUTTON",
			Name = N,
			PosX = X,
			PosY = Y,
			Width = W,
			Height = H,
			Color = PALETTE,
			IsClickable = CLICKABLE,
			Clicked = false,
			Visible = VISIBLE,
			ToolTip = TIP,
			AnchorTip = DIRECT,
			isSmall = SMALL,
			OnClick = ONE_TIME_FUNCTION,
			CallBack = CALLBACK
		}
	end
	
	local function Label(N, X, Y, W, H, TXT, SMALL, VISIBLE, CALLBACK)
		return {
			ControlType = "LABEL",
			Name = N,
			PosX = X,
			PosY = Y,
			Width = W,
			Height = H,
			Text = TXT,
			isSmall = SMALL,
			Visible = VISIBLE,
			CallBack = CALLBACK,
		}
	end

	local function GetMaterialCount(self)
		return "Material Count: " .. tostring(math.floor(self.Magazine and self.Magazine.RoundCount or self.resource))
	end

	local function GiveItem(actor, ItemName)
		actor:AddInventoryItem(CreateTDExplosive("Factorio.rte/" .. ItemName))
	end

	local function GetBox(Name)
		return self.InteractiveBox[Name]
	end

	local ItemPrices = {500, 1000, 350, 450, 1800}

	--To draw things properly...
	--Label Above (Drawn Behind)
	--Label Below (Drawn Infront)

	local CMenu = Root("ConstructMenu", 575, 190, 145, 80, 81, true, {})

	CMenu.Child = {

		Button("DefenderButton", 5, 45, 30, 30, 80, true, true, "Cost: " .. ItemPrices[1], "down", true,
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
				local Pos = ScreenPos(self, GetBox("DefenderButton").Center.X, GetBox("DefenderButton").Center.Y)
				PrimitiveMan:DrawBitmapPrimitive(self.CurrentScreen, Pos + Vector(-2, 0), Defender, 0, 0)
			end
		),

		Button("DestroyerButton", 40, 45, 30, 30, 80, true, true, "Cost: " .. ItemPrices[2], "down", true,
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
				local Pos = ScreenPos(self, GetBox("DestroyerButton").Center.X, GetBox("DestroyerButton").Center.Y)
				PrimitiveMan:DrawBitmapPrimitive(self.CurrentScreen, Pos + Vector(-2, 0), Destroyer, 0, 0)
			end
		),

		Button("GrenadeButton", 75, 45, 30, 30, 80, true, true, "Cost: " .. ItemPrices[3], "down", true,
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
				local Pos = ScreenPos(self, GetBox("GrenadeButton").Center.X, GetBox("GrenadeButton").Center.Y)
				PrimitiveMan:DrawBitmapPrimitive(self.CurrentScreen, Pos + Vector(-2, 0), Grenade, 0, 0)
			end
		),

		Button("ClusterGButton", 110, 45, 30, 30, 80, true, true, "Cost: " .. ItemPrices[4], "down", true,
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
				local Pos = ScreenPos(self, GetBox("ClusterGButton").Center.X, GetBox("ClusterGButton").Center.Y)
				PrimitiveMan:DrawBitmapPrimitive(self.CurrentScreen, Pos + Vector(-2, 0), ClusterGrenade, 0, 0)
			end
		),

		Button("CloseButton", 130, 0, 15, 15, 83, true, true, nil, nil, true,
			function()
				self.Activity:SwitchToActor(actor, self.Team, self.Team) --We don't need to call DeleteFCursor, it will check if the cursor is alive regardless
			end,
			function()
				local Pos = ScreenPos(self, GetBox("CloseButton").Center.X, GetBox("CloseButton").Center.Y)
				PrimitiveMan:DrawLinePrimitive(self.CurrentScreen, Pos + Vector(3, 3), Pos + Vector(-7, -7), 20)
				PrimitiveMan:DrawLinePrimitive(self.CurrentScreen, Pos + Vector(3, -7), Pos + Vector(-7, 3), 20)
			end
		),

		Label("ConstructMenuTitle", 25, 0, 0, 0, GetMaterialCount(self), false, true,
		function()
			return GetMaterialCount(self)
		end
		)
	}

	self.LCPanels = {CMenu}
end

function UpdateMenu(self)
    for _, Parent in ipairs(self.LCPanels) do
        local Frame = self.InteractiveBox[Parent.Name]

        local PBox = Parent.ControlType == "COLLECTIONBOX"

        if PBox then
            local cornerX, cornerY = Frame.Corner.X, Frame.Corner.Y
            local width, height = Frame.Width, Frame.Height
            local topleftPos = ScreenPos(self, cornerX, cornerY)
            local bottomRightPos = topleftPos + Vector(width - 4.5, height - 4.5)
			if Parent.Visible then
            	PrimitiveMan:DrawBoxFillPrimitive(self.CurrentScreen, topleftPos, bottomRightPos, Parent.Color)
			end
            Frame = Box(topleftPos, width, height )
        end
        if Parent.Child then
            for _, Child in ipairs(Parent.Child) do
                local Panel = self.InteractiveBox[Child.Name]
                local CBox = Child.ControlType == "COLLECTIONBOX"
                local CButton = Child.ControlType == "BUTTON"
                local CLabel = Child.ControlType == "LABEL"

                --If we only need to Draw the Box we do this
                if CBox or CButton then
                    local cornerX, cornerY = Panel.Corner.X, Panel.Corner.Y
                    local width, height = Panel.Width, Panel.Height
                    local topleftPos = ScreenPos(self, cornerX, cornerY)
                    local bottomRightPos = topleftPos + Vector(width - 4.5, height - 4.5)
					if Child.Visible then
                    	PrimitiveMan:DrawBoxFillPrimitive(self.CurrentScreen, topleftPos, bottomRightPos, Child.Color)
					end
                    Panel = Box(topleftPos, width, height )
                end

				--If we only need to Draw the Text we do this
				if CLabel then
					if Child.Visible then
						if Child.CallBack then
							Child.Text = Child.CallBack()
						end
				    	local TexPos = ScreenPos(self, Child.PosX, Child.PosY)
				    	PrimitiveMan:DrawTextPrimitive(self.CurrentScreen, TexPos, Child.Text, Child.isSmall, 0)
					end
				end

                if CButton then
                    if Panel:IsWithinBox(self.Cursor.Pos - Vector(0.2,2.621)) then
                        if Child.IsClickable then
                            Child.Clicked = true
                        end
                        if Child.ToolTip then
							local ToolTipPos = Vector(0, 0)
							local Anchor = string.lower(Child.AnchorTip)
							if Anchor == "up" then
								ToolTipPos = Vector(Panel.Width * 0.02, -9)
							elseif Anchor == "down" then
								ToolTipPos = Vector(Panel.Width * 0.02, Panel.Height - 3)
							elseif Anchor == "left" then
								ToolTipPos = Vector(-32, Panel.Height * 0.3)
							elseif Anchor == "right" then
								ToolTipPos = Vector(Panel.Width - 2, Panel.Height * 0.3)
							end
							PrimitiveMan:DrawTextPrimitive(self.CurrentScreen, Panel.Corner + ToolTipPos, Child.ToolTip, Child.isSmall, 0)
                        end
                    else
                        if Child.IsClickable then
                            if Child.Clicked then
                                Child.Clicked = false
                            end
                        end
                    end
					if Child.CallBack then
						Child.CallBack()
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
end

function InitializeTables(self)
	self.InteractiveBox = {}

	if SettingsMan.PrintDebugInfo then
		print("\n--------------------------------------------------------\nYour Resolution: {" .. FrameMan.PlayerScreenWidth .. ", " .. FrameMan.PlayerScreenHeight .. "}\n--------------------------------------------------------")
	end

	local Resolution = Vector(FrameMan.PlayerScreenWidth / 1280, FrameMan.PlayerScreenHeight / 720)

    for _, Parent in ipairs(self.LCPanels) do
        self.InteractiveBox[Parent.Name] = {}

        local ParentPos = Vector(Parent.PosX, Parent.PosY)

		ParentPos.X = ParentPos.X * Resolution.X
		ParentPos.Y = ParentPos.Y * Resolution.Y
		
        local ParentWidth = Parent.Width
        local ParentHeight = Parent.Height 

        self.InteractiveBox[Parent.Name] = Box(ParentPos, ParentWidth, ParentHeight)

		if SettingsMan.PrintDebugInfo then
			print("Parent: " .. Parent.Name .. " Pos: " .. tostring(ParentPos) .. " Size: {" .. ParentWidth .. ", " .. ParentHeight .. "}")
		end
        if Parent.Child then
            for _, Child in ipairs(Parent.Child) do

                local Frame = self.InteractiveBox[Parent.Name]

                local CBox = Child.ControlType == "COLLECTIONBOX"
                local CButton = Child.ControlType == "BUTTON"
                local CLabel = Child.ControlType == "LABEL"

                if CBox or CButton then
                    local ChildPos = Vector(Child.PosX, Child.PosY)
                    local ChildWidth = Child.Width
                    local ChildHeight = Child.Height 

                    local NewPos = ParentPos + ChildPos
                    self.InteractiveBox[Child.Name] = Box(NewPos, ChildWidth, ChildHeight)

					if SettingsMan.PrintDebugInfo then
						print("Child: " .. Child.Name .. " Pos: " .. tostring(ChildPos) .. " Size: {" .. ChildWidth .. ", " .. ChildHeight .. "}")
					end
                end

                if Child.ControlType == "LABEL" then
					Child.PosX = Child.PosX + Parent.PosX * Resolution.X
                    Child.PosY = Child.PosY + Parent.PosY * Resolution.Y

					if SettingsMan.PrintDebugInfo then
						print("Child: " .. Child.Name .. " Pos: {" .. Child.PosX .. ", " .. Child.PosY .. "}" .. " Size: {" .. Child.Width .. ", " .. Child.Height .. "}")
					end
                end
            end
        end
    end
end

function Update(self)
	
	local actor = self:GetRootParent()
	if actor and IsActor(actor) then
		actor = ToActor(actor)
		local ctrl = actor:GetController()
		self.ctrlactor = ctrl

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

		if playerControlled then
			if self:GetNumberValue("ActiveMenu") == 1 then
				self:SetNumberValue("ActiveMenu", 0)
                CreateFCursor(self, actor)
                CreateMenu(self, actor)
				InitializeTables(self)
            end
			self.operatedByAI = false
		elseif actor.AIMode == Actor.AIMODE_GOLDDIG then
			if ctrl:IsState(Controller.WEAPON_FIRE) and SceneMan:ShortestDistance(actor.Pos, ConstructorTerrainRay(actor.Pos, Vector(0, 50), 3), SceneMan.SceneWrapsX).Magnitude < 30 then
				self.operatedByAI = true
				self.aiSkillRatio = 1.5 - self.Activity:GetTeamAISkill(actor.Team)/100
			end
		end

		if self.FCursor then
			if self.FCursor:IsPlayerControlled() then
				if actor.Health <= 0 then -- For some reason this is better than self:Dead()
					DeleteFCursor(self)
				end
			else
				DeleteFCursor(self)
				self.Activity:SwitchToActor(actor, self.Team, self.Team)
			end
		end

		if self.CursorExist then
			UpdateFCursor(self, actor)
			UpdateMenu(self)
			FreezeActor(self, actor)
			DrawCursor(self)
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

function UpdateFCursor(self, actor)
	self.FCursor.Pos = actor.Pos -- Never leave the actor that we are controlling!

	--If User has Mouse then we mouse, if not we Xbox the 360
	if self.FCtrl:IsMouseControlled() == true then
        self.Mouse = self.Mouse + UInputMan:GetMouseMovement(self.Team)
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
		self.Mouse.X = self.Mid.X - self.ResX2
	end

	if self.Mouse.Y - self.Mid.Y < -self.ResY2 then
		self.Mouse.Y = self.Mid.Y - self.ResY2
	end

	if self.Mouse.X - self.Mid.X > self.ResX2 - 10 then
		self.Mouse.X = self.Mid.X + self.ResX2 - 10
	end

	if self.Mouse.Y - self.Mid.Y > self.ResY2 - 10 then
		self.Mouse.Y = self.Mid.Y + self.ResY2 - 10
	end
end

function DrawCursor(self)
	self.Cursor.Pos = self.Mouse + Vector(5, 12)
	PrimitiveMan:DrawBitmapPrimitive(self.CurrentScreen, self.Cursor.Pos, self.Cursor, 0, 0)
end

function FreezeActor(self, actor)
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
        actor:GetController():SetState(input, false)
    end
end

function ScreenPos(self, PosX, PosY)
	local Screen = Vector(
		CameraMan:GetOffset(self.Team).X + PosX,
		CameraMan:GetOffset(self.Team).Y + PosY
	)
	return Screen
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
    if self.FCursor and not self.FCursor.ToDelete then
        self.FCursor.ToDelete = true
        self.Cursor.ToDelete = true
        self.CursorExist = false
        self.Mouse = nil
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
