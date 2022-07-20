local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UiAssets = ReplicatedStorage:WaitForChild("Assets", 5).UI
local _HealthTag = UiAssets:WaitForChild("Tags", 5).HealthTag

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local TweenService = game:GetService("TweenService")
local TweenInfo1 = TweenInfo.new(1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type HealthTag_T = {
    __index: HealthTag_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local HealthTag: HealthTag_T = {}
HealthTag.__index = HealthTag
HealthTag.Name = "HealthTag"
HealthTag.Tag = "HealthTag"
HealthTag.Ancestor = game

function HealthTag.new(root: any)
    return setmetatable({
        Root = root,
        Tag = _HealthTag:Clone()

    }, HealthTag)
end

function HealthTag:Start()
    self.Tag.Parent = self.Root

    local function rootEnable()
        local bool = self.Root:GetAttribute("Enabled")

        if bool then
            self:Enable()
            return
        end

        self:Disable()
    end

    self.Tag.Size = UDim2.new(0, 0, 0, 10)
    self.Cleaner:Add(self.Root:GetAttributeChangedSignal("Enabled"):Connect(rootEnable))
    rootEnable()
end

function HealthTag:ConnectTo(subject : Instance)
    local function healthUpd()
        local totalHealth = (subject:GetAttribute("Health") or 0 ) + (subject:GetAttribute("Shields") or 0)
        local totalMaxHealth = (subject:GetAttribute("MaxHealth") or 0 ) + (subject:GetAttribute("MaxShields") or 0)

        local percent = (totalHealth / totalMaxHealth)

        TweenService:Create(self.Tag.Bar.Frame, TweenInfo1, {Size = UDim2.new(percent, 0, 1, 0),})
    end

    self.Cleaner:Add(subject:GetAttributeChangedSignal("Health"):Connect(healthUpd))

    if subject:GetAttribute("Shields") ~= nil then
        self.Cleaner:Add(subject:GetAttributeChangedSignal("Shields"):Connect(healthUpd))
    end
end

function HealthTag:Enable()
    self.Tag.Bar.UIStroke.Enabled = true
    self.Tag.Bar.BackgroundTransparency = 0
    TweenService:Create(self.Tag, TweenInfo1, { Size = UDim2.new(0, 125, 0, 10) }):Play()
end

function HealthTag:Disable()
    local tween = TweenService:Create(self.Tag, TweenInfo1, {Size = UDim2.new(0, 0, 0, 10),})

    local connection = nil
    connection = tween.Completed:Connect(function()
        connection:Disconnect()
        local newBool = self.Root:GetAttribute("Enabled")
        if newBool then return end

        if not self.Tag then return end
        if not self.Tag:FindFirstChild("Tag") then return end

        self.Tag.Bar.UIStroke.Enabled = false
        --self.Tag.Bar.BackgroundTransparency = 1
    end)

    tween:Play()
    tween.Completed:Wait()
end

function HealthTag:Disconnect()
    self.Cleaner:Clean()
end

function HealthTag:Destroy()
    local tag = self.Tag
    task.spawn(function() 
        self:Disable()
        if tag then tag:Destroy() end
    end)
    self.Cleaner:Clean()
end

tcs.create_component(HealthTag)

return HealthTag