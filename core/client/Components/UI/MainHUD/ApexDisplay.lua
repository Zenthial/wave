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

local function createItem(keybind: string, hasQuantity: boolean, quantity: number | nil)
    local item = Instance.new("Frame")
    item.Name = keybind
    item.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    item.BackgroundTransparency = 1
    item.BorderSizePixel = 0
    item.Size = UDim2.fromScale(0.3, 1)
    item.ZIndex = 3

    local fill = Instance.new("ImageLabel")
    fill.Name = "Fill"
    fill.Image = "rbxassetid://11127664942"
    fill.ImageTransparency = 0.5
    fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    fill.BackgroundTransparency = 1
    fill.BorderSizePixel = 0
    fill.Size = UDim2.fromScale(1, 1)
    fill.ZIndex = 2

    local uIGradient = Instance.new("UIGradient")
    uIGradient.Name = "UIGradient"
    uIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(57, 90, 134)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(57, 90, 134)),
    })
    uIGradient.Offset = Vector2.new(0, -0.5)
    uIGradient.Rotation = 90
    uIGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 1),
        NumberSequenceKeypoint.new(0.501, 0),
        NumberSequenceKeypoint.new(1, 0),
    })
    uIGradient.Parent = fill

    fill.Parent = item

    local black = Instance.new("ImageLabel")
    black.Name = "Black"
    black.Image = "rbxassetid://11126600651"
    black.ImageColor3 = Color3.fromRGB(57, 90, 134)
    black.ImageTransparency = 1
    black.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    black.BackgroundTransparency = 1
    black.BorderSizePixel = 0
    black.Size = UDim2.fromScale(1, 1)
    black.Parent = item

    local outline = Instance.new("ImageLabel")
    outline.Name = "Outline"
    outline.Image = "rbxassetid://11127662312"
    outline.ImageColor3 = Color3.fromRGB(91, 141, 208)
    outline.ImageTransparency = 0.25
    outline.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    outline.BackgroundTransparency = 1
    outline.BorderSizePixel = 0
    outline.Size = UDim2.fromScale(1, 1)
    outline.ZIndex = 99
    outline.Parent = item

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "TextLabel"
    textLabel.FontFace = Font.new(
        "rbxasset://fonts/families/Zekton.json",
        Enum.FontWeight.Bold,
        Enum.FontStyle.Italic
    )
    textLabel.Text = keybind
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextScaled = true
    textLabel.TextSize = 14
    textLabel.TextWrapped = true
    textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    textLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.BackgroundTransparency = 1
    textLabel.Position = UDim2.fromScale(0.451, 0.5)
    textLabel.Size = UDim2.fromScale(0.901, 1)
    textLabel.ZIndex = 99
    textLabel.Parent = item

    local quantityHolder = Instance.new("Frame")
    quantityHolder.Name = "QuantityHolder"
    quantityHolder.AnchorPoint = Vector2.new(1, 1)
    quantityHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    quantityHolder.BackgroundTransparency = 1
    quantityHolder.BorderSizePixel = 0
    quantityHolder.Position = UDim2.fromScale(1, 1)
    quantityHolder.Rotation = 30
    quantityHolder.Size = UDim2.fromScale(0.0563, 1)

    local uIListLayout = Instance.new("UIListLayout")
    uIListLayout.Name = "UIListLayout"
    uIListLayout.Padding = UDim.new(0, 3)
    uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uIListLayout.Parent = quantityHolder

    if hasQuantity then
        for i = 1, quantity do
            local frame = Instance.new("Frame")
            frame.Name = tostring(i)
            frame.BorderSizePixel = 0
            frame.BackgroundTransparency = 0.25
            frame.BackgroundColor3 = Color3.fromRGB(255, 121, 3)
            frame.Size = UDim2.fromScale(1, (1/quantity) - 0.01)

            local uiStroke = Instance.new("UIStroke")
            uiStroke.Color = Color3.fromRGB(255, 121, 3)
            uiStroke.Thickness = 0
            uiStroke.LineJoinMode = Enum.LineJoinMode.Miter
            uiStroke.Transparency = 0.25
            uiStroke.Parent = frame

            frame.Parent = quantityHolder
        end
    end

    quantityHolder.Parent = item

    return item
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
        },
        ItemToolbar: Frame & {
            UIListLayout: UIListLayout,
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

    self.Root.Primary.TextLabel.Text = "1"
    self.Root.Secondary.TextLabel.Text = "2"

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

local ActiveItems = {} :: {[Enum.KeyCode]: typeof(createItem)}
function ApexDisplay:SetItem(keybind: string, hasQuantity: boolean, quantity: number | nil)
    if ActiveItems[keybind] then
        ActiveItems[keybind]:Destroy()
    end

    local item = createItem(keybind, hasQuantity, quantity)
    print(self, self.Root)
    if hasQuantity then
        item.LayoutOrder = 1
    else
        item.LayoutOrder = 2
    end
    item.Parent = self.Root.ItemToolbar

    ActiveItems[keybind] = item
    return item
end

function ApexDisplay:GetItem(keybind: string, hasQuantity: boolean, chargeOrQuantity: number)
    if ActiveItems[keybind] ~= nil then
        return ActiveItems[keybind]
    else
        return self:SetItem(keybind, hasQuantity, chargeOrQuantity)
    end
end

function ApexDisplay:DeleteItem(keybind)
    if ActiveItems[keybind] then
        ActiveItems[keybind]:Destroy()
    end
end

function ApexDisplay:UpdateItem(keybind: string, hasQuantity: boolean, chargeOrQuantity: number)
    local item = self:GetItem(keybind, hasQuantity, chargeOrQuantity)
    if hasQuantity then
        for _, frame in item.QuantityHolder:GetChildren() do
            if frame:IsA("Frame") then
                local number = tonumber(frame.Name)
                if number <= (Player:GetAttribute("MaxGadgetQuantity") - chargeOrQuantity) then
                    frame.BackgroundTransparency = 1
                    frame.UIStroke.Thickness = 1
                else
                    frame.BackgroundTransparency = 0.25
                    frame.UIStroke.Thickness = 0
                end
            end
        end
    else
        local newFill = -((chargeOrQuantity/100) - 0.5) -- goes from 0.5 (empty) -> -0.5 (filled)
        print(chargeOrQuantity, newFill)
        TweenService:Create(item.Fill.UIGradient, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {Offset = Vector2.new(0, newFill)}):Play()
    end
end

function ApexDisplay:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(ApexDisplay)

return ApexDisplay