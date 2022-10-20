local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Weapons = Assets:WaitForChild("Weapons")

local Player = Players.LocalPlayer

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local setViewport = require(script.Parent.Parent.functions.setViewport)

local function calculateCharge(currentHeat: number)
    return math.floor(100 - currentHeat)
end

local GREEN = Color3.fromRGB(102, 189, 108)
local ORANGE = Color3.fromHex("#E1751E")
local RED = Color3.fromHex("#dc5b63")
local STEEL = Color3.fromRGB(57, 90, 134)
local BLACK = Color3.fromRGB(5, 8, 12)
local GREY = Color3.fromRGB(111, 111, 111)

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type ApexDisplay_T = {
    __index: ApexDisplay_T,
    Name: string,
    Tag: string,
    Root: {
        Primary: ImageLabel & {
            TextLabel: TextLabel
        },
        Secondary: ImageLabel & {
            TextLabel: TextLabel
        },
        ItemContainer: ImageLabel & {
            ViewportFrame: ViewportFrame,
            HeatPercentage: TextLabel,
            ItemName: TextLabel,
            ItemNumber: TextLabel
        }
    },

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local ApexDisplay: ApexDisplay_T = {}
ApexDisplay.__index = ApexDisplay
ApexDisplay.Name = "ApexDisplay"
ApexDisplay.Tag = "ApexDisplay"
ApexDisplay.Ancestor = game

function ApexDisplay.new(root: any)
    return setmetatable({
        Root = root,
    }, ApexDisplay)
end

function ApexDisplay:Start()
    self.HeatValue = Instance.new("IntValue")
    self.HeatValue.Parent = self.Root
    self.HeatValue.Value = 100
    self.HeatValue:GetPropertyChangedSignal("Value"):Connect(function()
        self.Root.ItemContainer.HeatPercentage.Text = tostring(self.HeatValue.Value) .. "%"
    end)
    self.FireRate = 10

    self.Cleaner:Add(Player:GetAttributeChangedSignal("EquippedPrimary"):Connect(function()
        self.Root.Primary.TextLabel.Text = Player:GetAttribute("EquippedPrimary"):upper()
    end))

    self.Cleaner:Add(Player:GetAttributeChangedSignal("EquippedSecondary"):Connect(function()
        self.Root.Secondary.TextLabel.Text = Player:GetAttribute("EquippedSecondary"):upper()
    end))

    self:ResetDisplay()
end

function ApexDisplay:UpdateBattery()
    
end

function ApexDisplay:ResetDisplay()
    self.Root.ItemContainer.ItemName.Text = "--"
    self.Root.ItemContainer.HeatPercentage.Text = "000"
    self.Root.ItemContainer.HeatPercentage.TextColor3 = GREY

    self:HandleTools(nil)
    self:CleanupViewport()
end

function ApexDisplay:CleanupViewport()
    self.Root.ItemContainer.ViewportFrame:ClearAllChildren()
end

function ApexDisplay:UpdateHeat(heat: number, overheated: boolean)
    TweenService:Create(self.HeatValue, TweenInfo.new(1 / self.FireRate), {Value = calculateCharge(heat)}):Play()

    if heat > 80 and self.Root.ItemContainer.HeatPercentage.TextColor3 ~= ORANGE and not overheated then
        TweenService:Create(self.Root.ItemContainer.HeatPercentage, TweenInfo.new(0.2), {TextColor3 = ORANGE}):Play()
    elseif not overheated then
        TweenService:Create(self.Root.ItemContainer.HeatPercentage, TweenInfo.new(0.2), {TextColor3 = GREEN}):Play()
    end
end

function ApexDisplay:SetOverheated(bool: boolean)
    TweenService:Create(self.Root.ItemContainer.HeatPercentage, TweenInfo.new(0.2), {TextColor3 = if bool then RED else GREEN}):Play()
end

function ApexDisplay:HandleTools(primary: true | false | nil)
    if primary == true then
        self.Root.Primary.ZIndex = 2
        self.Root.Secondary.ZIndex = 1
        TweenService:Create(self.Root.Primary, TweenInfo.new(0.2), {ImageColor3 = STEEL, ImageTransparency = 0}):Play()
        TweenService:Create(self.Root.Secondary, TweenInfo.new(0.2), {ImageColor3 = BLACK, ImageTransparency = 0.25}):Play()
    elseif primary == false then
        self.Root.Primary.ZIndex = 1
        self.Root.Secondary.ZIndex = 2
        TweenService:Create(self.Root.Secondary, TweenInfo.new(0.2), {ImageColor3 = STEEL, ImageTransparency = 0}):Play()
        TweenService:Create(self.Root.Primary, TweenInfo.new(0.2), {ImageColor3 = BLACK, ImageTransparency = 0.25}):Play()
    elseif primary == nil then
        self.Root.Primary.ZIndex = 1
        self.Root.Secondary.ZIndex = 1
        TweenService:Create(self.Root.Secondary, TweenInfo.new(0.2), {ImageColor3 = BLACK, ImageTransparency = 0.25}):Play()
        TweenService:Create(self.Root.Primary, TweenInfo.new(0.2), {ImageColor3 = BLACK, ImageTransparency = 0.25}):Play()
    end
end

function ApexDisplay:SetInformation(weaponStats, mutableStats)
    self.Root.ItemContainer.HeatPercentage.Text = tostring(calculateCharge(mutableStats.CurrentHeat)) .. "%"
    self.Root.ItemContainer.ItemName.Text = weaponStats.Name:upper()
    self:UpdateHeat(mutableStats.CurrentHeat, mutableStats.Overheated)
end

function ApexDisplay:HandleViewport(weaponModel: Model)
    print(weaponModel)
    self.Root.ItemContainer.ViewportFrame:ClearAllChildren()
    setViewport(self.Root.ItemContainer.ViewportFrame, weaponModel)
end

function ApexDisplay:SetWeapon(weaponStats, mutableStats, primary: true | false | nil)
    if weaponStats ~= nil then
        print(weaponStats.Name)
        self:HandleViewport(Weapons[weaponStats.Name])
        self:SetInformation(weaponStats, mutableStats)
        self:HandleTools(primary)
    else
        self:ResetDisplay()
    end
end

function ApexDisplay:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(ApexDisplay)

return ApexDisplay