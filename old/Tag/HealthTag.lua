local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UiAssets = ReplicatedStorage:WaitForChild("Assets", 5).UI
local _HealthTag = UiAssets:WaitForChild("Tags", 5).HealthTag

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local TweenService = game:GetService("TweenService")
local TweenInfo1 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TweenInfo2 = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

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
    local _tag = _HealthTag:Clone()
    return setmetatable({
        Root = root,
        Tag = _tag,
        Bar = _tag.Bar
    }, HealthTag)
end

function HealthTag:Start()
    self.Tag.Parent = self.Root
    self.Bar.Position = UDim2.new(-1, 0, 0.5, 0)

    local function rootEnable()
        local bool = self.Root:GetAttribute("Enabled")

        if bool then
            self:Enable()
            return
        end

        self:Disable()
    end

    self.Cleaner:Add(self.Root:GetAttributeChangedSignal("Enabled"):Connect(rootEnable))
    rootEnable()
end

function HealthTag:ConnectTo(subject : Instance)
    local lastTotalHealth = (subject:GetAttribute("Health") or 0) + (subject:GetAttribute("Shields") or 0)

    local function healthUpd()
        local totalHealth = (subject:GetAttribute("Health") or 0) + (subject:GetAttribute("Shields") or 0)
        local totalMaxHealth = (subject:GetAttribute("MaxHealth") or 0) + (subject:GetAttribute("MaxShields") or 0)

        local percentage = totalHealth/totalMaxHealth
        local percentageSize = 1 - (totalHealth/lastTotalHealth)

        self.Bar.Frame.Size = UDim2.new(percentage,0,1,0)

        local clFrame = self.Bar.Frame:Clone()
        clFrame.Size = UDim2.new(percentageSize,0,1,0)
        clFrame.Position = UDim2.new(percentage,0,0.5,0)
        clFrame.BackgroundColor3 = Color3.fromRGB(255, 89, 89)
        clFrame.Parent = self.Bar.Frame

        local tween = TweenService:Create(clFrame, TweenInfo1, { Size = UDim2.new(percentageSize, 0, 3, 0) })

        local tweenEndEvent
        tweenEndEvent = tween.Completed:Connect(function() 
            tweenEndEvent:Disconnect()
            clFrame:Destroy()
        end)
        tween:Play()

        lastTotalHealth = totalHealth
    end

    self.Cleaner:Add(subject:GetAttributeChangedSignal("Health"):Connect(healthUpd))

    if subject:GetAttribute("Shields") ~= nil then
        self.Cleaner:Add(subject:GetAttributeChangedSignal("Shields"):Connect(healthUpd))
    end
end

function HealthTag:Enable()
    TweenService:Create(self.Bar, TweenInfo1, { Position = UDim2.new(0, 0, 0.5, 0) }):Play()
end

function HealthTag:Disable()
    TweenService:Create(self.Bar, TweenInfo1, { Position = UDim2.new(-1, 0, 0.5, 0) }):Play()
end

function HealthTag:Disconnect()
    self.Cleaner:Clean()
end

function HealthTag:Destroy()
    self:Disable()
    self.Cleaner:Clean()
    task.delay(0.5, function() 
        self.Tag:Destroy()
    end)
end

tcs.create_component(HealthTag)

return HealthTag