local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local CameraLimits = require(script.Parent.CameraLimits)

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Camera = workspace.CurrentCamera

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type MountedTurret_T = {
    __index: MountedTurret_T,
    Name: string,
    Tag: string,
    Root: Model & {
        Y: Model & {
            XZ: Folder,
            Core: Part & {
                XZ: HingeConstraint,
                Y: HingeConstraint
            },
    
            Middle: Part,
            Seat: Seat
        },
        BaseMount: Part,
    },

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local MountedTurret: MountedTurret_T = {}
MountedTurret.__index = MountedTurret
MountedTurret.Name = "MountedTurret"
MountedTurret.Tag = "MountedTurret"
MountedTurret.Ancestor = game

function MountedTurret.new(root: any)
    return setmetatable({
        Root = root,
    }, MountedTurret)
end

function MountedTurret:Start()
    CollectionService:AddTag(self.Root, "Turret")
    local turretComponent = tcs.get_component(self.Root, "Turret")
    self.TurretComponent = turretComponent

    self.Offset = self.Root:GetAttribute("TurretOffset") or Vector3.new(0, 10, 10)

    self.CameraAngles = Vector2.new(0, 0)
	self.MouseDeltas = Vector2.new(0, 0)
end

function MountedTurret:UpdateCamera()
    Camera.CameraType = Enum.CameraType.Attach
    Camera.CameraSubject = self.Root.BaseMount

    -- self.CameraAngles = self.CameraAngles - (self.MouseDeltas/5)
    -- self.MouseDeltas = Vector2.new(0,0)
    -- self.CameraAngles = Vector2.new(math.clamp(self.CameraAngles.X, CameraLimits.MinX, CameraLimits.MaxX), math.clamp(self.CameraAngles.Y, CameraLimits.MinY, CameraLimits.MaxY))
    
    -- local angles1 = CFrame.Angles(0,math.rad(self.CameraAngles.X), 0)
    -- local angles2 = CFrame.Angles(math.rad(self.CameraAngles.Y), 0, 0)

    Camera.CFrame *= CFrame.new(self.Offset)
end

function MountedTurret:RunServiceLoop()
    self:UpdateCamera()    
end

function MountedTurret:Bind()
    local sessionCleaner = Trove.new()
    self.Cleaner:Add(sessionCleaner, "Clean")
    self.SessionCleaner = sessionCleaner

    sessionCleaner:Add(UserInputService.InputChanged:Connect(function(input, processed)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            self.MouseDeltas = Vector2.new(input.Delta.X, input.Delta.Y)
        end
    end))

    sessionCleaner:Add(RunService.RenderStepped:Connect(function()
        self:RunServiceLoop()
    end))

    if self.Root.Parent == workspace then
        self.Root.BaseMount:SetNetworkOwner(Players.LocalPlayer)
    end

    self.TurretComponent:Bind(self.Root.Parent == workspace)
end

function MountedTurret:Unbind()
    self.SessionCleaner:Clean()

    Camera.CameraType = Enum.CameraType.Custom
    Camera.CameraSubject = Character
    
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default

    if self.Root.Parent == workspace then
        self.Root.BaseMount:SetNetworkOwner(nil)
    end

    self.TurretComponent:Unbind()
end

function MountedTurret:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(MountedTurret)

return MountedTurret