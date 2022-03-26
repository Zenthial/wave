-- rotate any character with a humanoid

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local wcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("wcs"))

local BodyGyro = {}
BodyGyro.__index = BodyGyro
BodyGyro.Name = "BodyGyro"
BodyGyro.Tag = "Character"
BodyGyro.Ancestor = workspace

function BodyGyro.new(root: any)
    local hrp = root:FindFirstChild("HumanoidRootPart")
    local humanoid = root:FindFirstChild("Humanoid")
    
    assert(hrp, "No HumanoidRootPart exists on "..root.Name)
    assert(humanoid, "No Humanoid exists on "..root.Name)

    return setmetatable({
        Root = root,

        HumanoidRootPart = hrp,
        Humanoid = humanoid,

        Gyro = Instance.new("BodyGyro"),
        Enabled = false,
    }, BodyGyro)
end

function BodyGyro:Start()
    self:SetGyro(false)
end

function BodyGyro:SetGyro(bool: boolean)
    if bool then
        if self.Gyro == nil then
            self.Gyro = Instance.new("BodyGyro")
        end

        self.Gyro.D = 500
        self.Gyro.MaxTorque = Vector3.new(0, math.huge, 0)
        self.Gyro.P = 5000
        self.Gyro.Parent = self.HumanoidRootPart

        self.Humanoid.AutoRotate = false
    else
        self.Humanoid.AutoRotate = true
        self.Gyro:Destroy()
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

wcs.create_component(BodyGyro)

return BodyGyro