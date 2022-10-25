local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local WeaponStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))

local IN_POSITION = UDim2.fromScale(0.025, 0.5)
local OUT_POSITION = UDim2.fromScale(0.025, 1.5)

local BATTERY_GREEN = Color3.fromRGB(125, 255, 0)
local BATTERY_RED = Color3.fromRGB(242, 63, 63)

local BAR_NORMAL = Color3.fromRGB(3, 167, 255)
local BAR_OVERHEAT = Color3.fromRGB(255, 59, 0)

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type GunInfoDisplay_T = {
    __index: GunInfoDisplay_T,
    Name: string,
    Tag: string,

    Root: Frame & {
        Bar: Frame & {
            Fill: Frame
        },
        BatteryLifeContainer: Frame & {
            Fill: Frame
        },
        BatteryIcon: ImageLabel,
        ItemName: TextLabel,
        WeaponHeat: TextLabel
    },

    HeatValue: IntValue,
    FireRate: number,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local function calculateCharge(currentHeat: number)
    return math.floor(100 - currentHeat)
end

local GunInfoDisplay: GunInfoDisplay_T = {}
GunInfoDisplay.__index = GunInfoDisplay
GunInfoDisplay.Name = "GunInfoDisplay"
GunInfoDisplay.Tag = "GunInfoDisplay"
GunInfoDisplay.Ancestor = game

function GunInfoDisplay.new(root: any)
    return setmetatable({
        Root = root,
    }, GunInfoDisplay)
end

function GunInfoDisplay:Start()
    self.Root.Position = OUT_POSITION
    self.HeatValue = Instance.new("IntValue")
    self.HeatValue.Parent = self.Root
    self.HeatValue.Value = 100
    self.HeatValue:GetPropertyChangedSignal("Value"):Connect(function()
        self.Root.WeaponHeat.Text = tostring(self.HeatValue.Value) .. "%"
    end)
    self.FireRate = 10
end

function GunInfoDisplay:Open()
    TweenService:Create(self.Root, TweenInfo.new(0.5), {Position = IN_POSITION}):Play()
end

function GunInfoDisplay:Close()
    TweenService:Create(self.Root, TweenInfo.new(0.5), {Position = OUT_POSITION}):Play()
    self:ResetInformation()
end

function GunInfoDisplay:ResetInformation()
    self:SetOverheated(false)
    self:UpdateBattery(100)
    self:UpdateHeat(0)
    self:SetOverheated(false)
end

function GunInfoDisplay:SetInformation(weaponStats: WeaponStats.WeaponStats_T, mutableStats)
    self.Root.ItemName.Text = weaponStats.Name:upper()
    self:UpdateHeat(mutableStats.CurrentHeat)
    self:UpdateBattery(mutableStats.CurrentBattery)
    self:SetOverheated(mutableStats.Overheated)
end

function GunInfoDisplay:UpdateBattery(battery: number)
    TweenService:Create(self.Root.BatteryLifeContainer.Fill, TweenInfo.new(0.2), {
        BackgroundColor3 = if battery > 20 then BATTERY_GREEN else BATTERY_RED,
        Size = UDim2.fromScale(.45, math.clamp((battery / 100) * .75, 0, .75))
    }):Play()
end

function GunInfoDisplay:UpdateHeat(heat: number)
    TweenService:Create(self.HeatValue, TweenInfo.new(1 / self.FireRate), {Value = calculateCharge(heat)}):Play()
    TweenService:Create(self.Root.Bar.Fill, TweenInfo.new(1 / self.FireRate, Enum.EasingStyle.Linear), {Size = UDim2.fromScale(heat / 100, 1)}):Play()
end

function GunInfoDisplay:SetOverheated(bool: boolean)
    TweenService:Create(self.Root.Bar.Fill, TweenInfo.new(0.2), {
        BackgroundColor3 = if bool then BAR_OVERHEAT else BAR_NORMAL
    }):Play()

    TweenService:Create(self.Root.WeaponHeat, TweenInfo.new(0.2), {TextColor3 = if bool then BAR_OVERHEAT else BAR_NORMAL}):Play()
end

function GunInfoDisplay:SetWeapon(weaponStats: WeaponStats.WeaponStats_T, mutableStats)
    if weaponStats == nil then
        self:Close()
    else
        self.FireRate = weaponStats.FireRate
        self:SetInformation(weaponStats, mutableStats)
        self:Open()
    end
end

function GunInfoDisplay:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(GunInfoDisplay)

return GunInfoDisplay