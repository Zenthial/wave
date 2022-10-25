local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local Mouse = Players.LocalPlayer:GetMouse()
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Camera = workspace.CurrentCamera

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> (Cleaner_T, Instance, string?)
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type StaticTurret_T = {
    __index: StaticTurret_T,
    Name: string,
    Tag: string,
    Root: Model & {
        Y: Model & {
            XZ: Folder,
            Core: Part & {
                XZ: HingeConstraint,
                Y: HingeConstraint
            },
    
            Middle: Part
        },
    },

    Core: Part & {
        XZ: HingeConstraint,
        Y: HingeConstraint
    },
    Middle: Part,

    HingeXZ: HingeConstraint,
    HingeY: HingeConstraint,

    SessionCleaner: typeof(Trove),

    Cleaner: Cleaner_T,
    Courier: Courier_T,
}

local StaticTurret: StaticTurret_T = {}
StaticTurret.__index = StaticTurret
StaticTurret.Name = "StaticTurret"
StaticTurret.Tag = "StaticTurret"
StaticTurret.Ancestor = game

function StaticTurret.new(root: any)
    return setmetatable({
        Root = root,
    }, StaticTurret)
end

function StaticTurret:Start()
end

function StaticTurret:UpdateCamera()
    Camera.CameraType = Enum.CameraType.Attach
    Camera.CameraSubject = self.Root.BaseMount

    Camera.CFrame *= CFrame.new(Vector3.new(0, 10, 10))
end

function StaticTurret:Bind(networkOwner: boolean)
    local sessionCleaner = Trove.new()
    self.Cleaner:Add(sessionCleaner, "Clean")
    self.SessionCleaner = sessionCleaner

    self:UpdateCamera()
    
    if self.Root.Parent == workspace then
        self.Root.BaseMount:SetNetworkOwner(Players.LocalPlayer)
    end
end

function StaticTurret:Unbind()
    self.SessionCleaner:Clean()

    Camera.CameraType = Enum.CameraType.Custom
    Camera.CameraSubject = Character
    
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default

    if self.Root.Parent == workspace then
        self.Root.BaseMount:SetNetworkOwner(nil)
    end
end

function StaticTurret:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(StaticTurret)

return StaticTurret