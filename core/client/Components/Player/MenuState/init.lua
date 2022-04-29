local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))
local initializeInspectUi = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("functions"):WaitForChild("initializeInspectUi"))

local Assets = ReplicatedStorage:WaitForChild("Assets")
local UIAssets = Assets:WaitForChild("UI")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local CAMERA_CFRAME = CFrame.new(0.0242614746, 1.8589077, -10.2855835, -0.946889699, -0.0290494263, 0.320242703, 0, 0.995911181, 0.0903397501, -0.321557522, 0.0855417699, -0.9430179 )
local PART_CFRAME = CFrame.new(-6.80073547, 0.424999237, -1.60940552, 0.499999821, 0, 0.866025031, 0, 1, 0, -0.866025031, 0, 0.499999821)
local PART_SIZE = Vector3.new(0.25, 7, 9)

local INSPECT_PART_RELATIVE_CFRAME = CFrame.new(-1.68988037, 1.87501335, -10.3878784, 0.965925634, 0, 0.258819014, 0, 1, 0, -0.258819014, 0, 0.965925634)
local INSPECT_POSITION = CFrame.new(0.0400543213, 2.07883072, -2.16635132, 0.968976021, -0.000633612042, 0.247152478, 0, 0.999996722, 0.00256363978, -0.247153267, -0.00248410529, 0.968972862)

local function createInspectPart(cframe: CFrame)
    local part = Instance.new("Part")
    part.Name = "part"
    part.Anchored = true
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.CFrame = cframe
    part.Size = Vector3.new(15, 9.75, 2)
    part.TopSurface = Enum.SurfaceType.Smooth
    part.Transparency = 1
    part.Parent = workspace

    return part
end

local function createMenuPart(cframe: CFrame): Part
    local menu = Instance.new("Part")
    menu.Size = PART_SIZE
    menu.CFrame = cframe
    menu.Transparency = 1
    menu.Anchored = true
    menu.CanCollide = false
    menu.CanTouch = false
    menu.CanQuery = false
    menu.Parent = workspace

    return menu
end

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type MenuState_T = {
    __index: MenuState_T,
    Name: string,
    Tag: string,
    Character: Model,
    HumanoidRootPart: Part,
    Humanoid: Humanoid,

    SavedCFrame: CFrame | nil,

    State: {
        InArmory: boolean,
        Open: boolean,
        Animating: boolean,
    },

    Cleaner: Cleaner_T,
    OpenCleaner: Cleaner_T
}

-- This Component handles determining if the 3D UI should be displayed in game
-- Also handles the camera of the inventory, as well as creating the UI
local MenuState: MenuState_T = {}
MenuState.__index = MenuState
MenuState.Name = "MenuState"
MenuState.Tag = "Player"
MenuState.Ancestor = game
MenuState.Needs = {"Cleaner"}

function MenuState.new(root: any)
    return setmetatable({
        Root = root,

        State = {
            InArmory = false,
            Open = false,
            Animating = false,
        }
    }, MenuState)
end

function MenuState:Start()
    self.Character = Player.Character or Player.CharacterAdded:Wait()
    self.HumanoidRootPart = self.Character:WaitForChild("HumanoidRootPart")
    self.Humanoid = self.Character:WaitForChild("Humanoid")

    local InArmoryChangedSignal = Player:GetAttributeChangedSignal("InArmory")

    self.Cleaner:Add(InArmoryChangedSignal:Connect(function()
        self.State.InArmory = Player:GetAttribute("InArmory")
    end))
end

function MenuState:FeedInput()
    if self.State.Animating == true then return end
    if self.State.InArmory and not self.State.Open then
        self:Open()
    elseif self.State.Open then
        self:Close()
    end
end

function MenuState:Open()
    self.State.Open = true
    self.State.Animating = true
    self.SavedCFrame = Camera.CFrame
    Camera.CameraType = Enum.CameraType.Scriptable
    self.OpenCleaner = Trove.new()
    
    TweenService:Create(Camera, TweenInfo.new(0.5), {CFrame = self.HumanoidRootPart.CFrame:ToWorldSpace(CAMERA_CFRAME)}):Play()

    local menuPart = createMenuPart(self.HumanoidRootPart.CFrame:ToWorldSpace(PART_CFRAME))
    local ui = UIAssets:FindFirstChild("InventoryMenu"):Clone() :: SurfaceGui
    ui.AlwaysOnTop = true
    ui.Adornee = menuPart
    ui.Parent = PlayerGui

    local uiComponent = tcs.get_component(ui, "InventoryMenu") --[[:await()]]
    self.OpenCleaner:Add(uiComponent.Events.Inspect:Connect(function(itemName: string, slot: number)
        local inspectPart = createInspectPart(self.HumanoidRootPart.CFrame:ToWorldSpace(INSPECT_PART_RELATIVE_CFRAME))

        local inspectUi = UIAssets:FindFirstChild("InspectGui"):Clone() :: SurfaceGui
        inspectUi.AlwaysOnTop = true
        inspectUi.Adornee = inspectPart
        local backButtonConnection = initializeInspectUi(itemName, inspectUi, slot)
        if backButtonConnection == nil then return end
        inspectUi.Parent = PlayerGui

        TweenService:Create(Camera, TweenInfo.new(0.5), {CFrame = self.HumanoidRootPart.CFrame:ToWorldSpace(INSPECT_POSITION)}):Play()

        local con
        con = backButtonConnection:Connect(function(returnType: string)
            if returnType == "Purchase" then
                -- do some purchasey things
            end

            local tween = TweenService:Create(Camera, TweenInfo.new(0.5), {CFrame = self.HumanoidRootPart.CFrame:ToWorldSpace(CAMERA_CFRAME)})
            tween:Play()
            tween.Completed:Connect(function()
                inspectUi:Destroy()
                inspectPart:Destroy()
            end)
            
            con:Disconnect()
        end)
    end))

    self.MenuPart = menuPart
    self.MenuUI = ui

    local dof = Instance.new("DepthOfFieldEffect")
    dof.FocusDistance = 0
    dof.Parent = Camera

    self.OpenCleaner:Add(dof)

    Player:SetAttribute("LocalCanMove", false)
    Player:SetAttribute("LocalCanCrouch", false)
    Player:SetAttribute("LocalCanSprint", false)
    self.State.Animating = false
end

function MenuState:Close()
    self.State.Open = false
    self.State.Animating = true
    
    local tween = TweenService:Create(Camera, TweenInfo.new(0.5), {CFrame = self.SavedCFrame})
    tween:Play()
    tween.Completed:Wait()

    self.MenuUI:Destroy()
    self.MenuPart:Destroy()

    Camera.CameraType = Enum.CameraType.Custom
    Camera.CameraSubject = self.Humanoid
    
    Player:SetAttribute("LocalCanMove", true)
    Player:SetAttribute("LocalCanCrouch", true)
    Player:SetAttribute("LocalCanSprint", true)

    self.OpenCleaner:Clean()
    self.State.Animating = false
end

function MenuState:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(MenuState)

return MenuState