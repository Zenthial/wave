local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local bluejay = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("bluejay"))

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local CAMERA_CFRAME = CFrame.new(0.0242614746, 1.8589077, -10.2855835, -0.946889699, -0.0290494263, 0.320242703, 0, 0.995911181, 0.0903397501, -0.321557522, 0.0855417699, -0.9430179 )

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

    end
end

function MenuState:Open()
    self.State.Open = true
    Camera.CameraType = Enum.CameraType.Scriptable
    Camera.CFrame = self.HumanoidRootPart.CFrame:ToWorldSpace(CAMERA_CFRAME)
    self.Humanoid.WalkSpeed = 0
end

function MenuState:Close()
    self.State.Open = false
    Camera.CameraType = Enum.CameraType.Custom
    Camera.CameraSubject = self.Character
end

function MenuState:Destroy()
    self.Cleaner:Clean()
end

bluejay.create_component(MenuState)

return MenuState