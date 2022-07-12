local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local Mouse = Players.LocalPlayer:GetMouse()

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> (Cleaner_T, Instance, string?)
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type Turret_T = {
    __index: Turret_T,
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

local Turret: Turret_T = {}
Turret.__index = Turret
Turret.Name = "Turret"
Turret.Tag = "Turret"
Turret.Ancestor = game

function Turret.new(root: any)
    return setmetatable({
        Root = root,
    }, Turret)
end

function Turret:Start()
    local body = self.Root.Y
    local middle = body.Middle
    local core = body.Core

    if middle and core then
        self.Core = core
        self.Middle = middle

        local hingeXZ = core:FindFirstChild("XZ")
        local hingeY = core:FindFirstChild("Y")
        assert(hingeXZ, "No XZ Hinge for " .. self.Root.Name)
        assert(hingeY, "No Y Hinge for " .. self.Root.Name)

        self.HingeXZ = hingeXZ
        self.HingeY = hingeY
    else
        error("missing core or middle" .. self.Root.Name)
    end
end

function Turret:GetY(goalPosition: Vector3)
	local ObjectSpacePosition = self.Middle.CFrame:PointToObjectSpace(goalPosition)
	local ClampLower, ClampUpper = self.HingeY.LowerAngle, self.HingeY.UpperAngle

	if not self.HingeY.LimitsEnabled then
		ClampLower, ClampUpper = -360,360
	end

	local TargetAngle = -math.deg(math.atan2(ObjectSpacePosition.X, ObjectSpacePosition.Z))
	return math.clamp(TargetAngle, ClampLower, ClampUpper)
end

function Turret:GetXZ(goalPosition: Vector3)
	local ObjectSpacePosition = self.Middle.CFrame:PointToObjectSpace(goalPosition)
	local ClampLower, ClampUpper = self.HingeXZ.LowerAngle, self.HingeXZ.UpperAngle

	if not self.HingeXZ.LimitsEnabled then
		ClampLower, ClampUpper = -89,89
	end

	local TargetAngle = -(math.deg(math.atan2(ObjectSpacePosition.Y, (ObjectSpacePosition.X^2 + ObjectSpacePosition.Z^2) ^ 0.5)))
	return math.clamp(TargetAngle, ClampLower, ClampUpper)
end

function Turret:Bind(networkOwner: boolean)
    local sessionCleaner = Trove.new()
    self.SessionCleaner = sessionCleaner
    self.Cleaner:Add(sessionCleaner, "Clean")

    sessionCleaner:Add(RunService.RenderStepped:Connect(function()
        local goalPosition = Mouse.Hit.Position
        local positionXZ = self:GetXZ(goalPosition)
        local positionY = self:GetY(goalPosition)

        if networkOwner then
            self.HingeXZ.TargetAngle = positionXZ
            self.HingeY.TargetAngle = positionY
        else
            self.Courier:SendToOthers("UpdateServo", self.HingeXZ, positionXZ)
            self.Courier:SendToOthers("UpdateServo", self.HingeY, positionY)
        end
    end))
end

function Turret:Unbind()
    self.SessionCleaner:Clean()
    self.SessionCleaner = nil
end

function Turret:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(Turret)

return Turret