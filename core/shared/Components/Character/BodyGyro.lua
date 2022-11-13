-- rotate any character with a humanoid

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local BodyGyro = {}
BodyGyro.__index = BodyGyro
BodyGyro.Name = "BodyGyro"
BodyGyro.Tag = "Character"
BodyGyro.Ancestor = workspace

function BodyGyro.new(root: any)
    local hrp = root:WaitForChild("HumanoidRootPart")
    local humanoid = root:FindFirstChild("Humanoid")
    
    assert(hrp, "No HumanoidRootPart exists on "..root.Name)
    assert(humanoid, "No Humanoid exists on "..root.Name)

    return setmetatable({
        Root = root,

        HumanoidRootPart = hrp,
        Humanoid = humanoid,

        Gyro = nil,
        Enabled = false,
    }, BodyGyro)
end

function BodyGyro:Start()
    self:SetGyro(false)
end

function BodyGyro:SetGyro(bool: boolean)
    if bool then
        local gyro = Instance.new("BodyGyro")

        gyro.D = 500
        gyro.MaxTorque = Vector3.new(0, math.huge, 0)
        gyro.P = 5000
        gyro.Parent = self.HumanoidRootPart
        self.Gyro = gyro

        self.Humanoid.AutoRotate = false
    else
        self.Humanoid.AutoRotate = true
        if self.Gyro then
            self.Gyro:Destroy()
        end
    end

    self.Enabled = bool
end

function BodyGyro:SetRotationTarget(position: Vector3)
    if self.Gyro then
        self.Gyro.CFrame = CFrame.new(self.HumanoidRootPart.Position, position)
    end    
end

function BodyGyro:Destroy()
    self.Gyro:Destroy()
end

tcs.create_component(BodyGyro)

return BodyGyro