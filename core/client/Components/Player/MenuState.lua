local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local bluejay = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("bluejay"))

local Assets = ReplicatedStorage:WaitForChild("Assets")
local UIAssets = Assets:WaitForChild("UI")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local CAMERA_CFRAME = CFrame.new(0.0242614746, 1.8589077, -10.2855835, -0.946889699, -0.0290494263, 0.320242703, 0, 0.995911181, 0.0903397501, -0.321557522, 0.0855417699, -0.9430179 )
local PART_CFRAME = CFrame.new(-6.80073547, 0.424999237, -1.60940552, 0.499999821, 0, 0.866025031, 0, 1, 0, -0.866025031, 0, 0.499999821)
local PART_SIZE = Vector3.new(0.25, 7, 9)

local function createMenuPart(cframe: CFrame, parent: Instance): Part
    local menu = Instance.new("Part")
    menu.Size = PART_SIZE
    menu.CFrame = cframe
    menu.Transparency = 1
    menu.Anchored = true
    menu.CanCollide = false
    menu.CanTouch = false
    menu.CanQuery = false
    menu.Parent = parent

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
        Open: boolean
    },

    Cleaner: Cleaner_T
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
        }
    }, MenuState)
end

function MenuState:CreateDependencies()
    return {}
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
    if self.State.InArmory and not self.State.Open then
        self:Open()
    elseif self.State.Open then
        self:Close()
    end
end

function MenuState:Open()
    self.State.Open = true
    Camera.CameraType = Enum.CameraType.Scriptable
    self.SavedCFrame = Camera.CFrame
    
    TweenService:Create(Camera, TweenInfo.new(0.5), {CFrame = self.HumanoidRootPart.CFrame:ToWorldSpace(CAMERA_CFRAME)}):Play()

    local menuPart = createMenuPart(self.HumanoidRootPart.CFrame:ToWorldSpace(PART_CFRAME), self.Character)
    local ui = UIAssets:FindFirstChild("InventoryMenu"):Clone() :: SurfaceGui
    ui.Adornee = menuPart
    ui.Parent = PlayerGui

    self.MenuPart = menuPart
    self.MenuUI = ui

    Player:SetAttribute("LocalCanMove", false)
    Player:SetAttribute("LocalCanCrouch", false)
    Player:SetAttribute("LocalCanSprint", false)
end

function MenuState:Close()
    self.State.Open = false
    
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
end

function MenuState:Destroy()
    self.Cleaner:Clean()
end

bluejay.create_component(MenuState)

return MenuState