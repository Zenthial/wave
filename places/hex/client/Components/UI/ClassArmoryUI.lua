local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"):WaitForChild("GenericTypes"))
local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))
local courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))
local WeaponStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local function convertNumberToItemType(number)
    if number == 1 then
        return "Primaries"
    elseif number == 2 then
        return "Secondaries"
    elseif number == 3 then
        return "Gadgets"
    elseif number == 4 then
        return "Skills"
    end
end

type Cleaner_T = types.Cleaner_T

type Courier_T = types.Courier_T

type ClassArmoryUI_T = {
    __index: ClassArmoryUI_T,
    Name: string,
    Tag: string,
    SelectedItem: string | nil,
    Events: {
        InspectItem: typeof(Signal)
    },

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local function createWeaponFrame(name: string)
    local item = Instance.new("Frame")
    item.Name = "Item"
    item.BackgroundColor3 = Color3.fromRGB(39, 39, 39)
    item.BackgroundTransparency = 0.4
    item.BorderSizePixel = 0
    item.Size = UDim2.fromScale(0.9, 0.03)

    local uIStroke = Instance.new("UIStroke")
    uIStroke.Name = "UIStroke"
    uIStroke.Color = Color3.fromRGB(255, 255, 255)
    uIStroke.LineJoinMode = Enum.LineJoinMode.Miter
    uIStroke.Parent = item

    local textLabel = Instance.new("TextButton")
    textLabel.Name = "Button"
    textLabel.FontFace = Font.new("rbxasset://fonts/families/Zekton.json")
    textLabel.Text = name
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextScaled = true
    textLabel.TextSize = 14
    textLabel.TextWrapped = true
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.BackgroundTransparency = 1
    textLabel.BorderSizePixel = 0
    textLabel.Position = UDim2.fromScale(0.04, 0)
    textLabel.Size = UDim2.fromScale(0.95, 1)
    textLabel.Parent = item

    return item
end

local ClassArmoryUI: ClassArmoryUI_T = {}
ClassArmoryUI.__index = ClassArmoryUI
ClassArmoryUI.Name = "ClassArmoryUI"
ClassArmoryUI.Tag = "ClassArmoryUI"
ClassArmoryUI.Ancestor = PlayerGui

function ClassArmoryUI.new(root: any)
    return setmetatable({
        Root = root,
        SelectedItem = nil,
        Events = {
            InspectItem = Signal.new()
        }
    }, ClassArmoryUI)
end

function ClassArmoryUI:Start()
    local sorted = {{},{},{},{}}
    for _, weaponStats in WeaponStats do
        sorted[weaponStats.Slot] = weaponStats
    end

    self.SortedSlots = sorted
    self.Cleaner:Add(self.Root.EquipButton.MouseButton1Click:Connect(function()
        self.Root.EquipButton.Visible = false
        self.Root.UnequipButton.Visible = true
        courier:Send("RequestChange", convertNumberToItemType(self.SelectedItem.Slot), self.SelectedItem.Name, true)
    end))
    
    self.Cleaner:Add(self.Root.UnequipButton.MouseButton1Click:Connect(function()
        self.Root.EquipButton.Visible = true
        self.Root.UnequipButton.Visible = false
        courier:Send("RequestChange", convertNumberToItemType(self.SelectedItem.Slot), self.SelectedItem.Name, false)
    end))

    self.Cleaner:Add(self.Root.Buttons.Primary.MouseButton1Click:Connect(function()
        self:Populate(1)
    end))

    self.Cleaner:Add(self.Root.Buttons.Secondary.MouseButton1Click:Connect(function()
        self:Populate(2)
    end))
    
    self.Cleaner:Add(self.Root.Buttons.Gadgets.MouseButton1Click:Connect(function()
        self:Populate(3)
    end))

    self.Cleaner:Add(self.Root.Buttons.Skills.MouseButton1Click:Connect(function()
        self:Populate(4)
    end))
end

function ClassArmoryUI:HandleButtonVisibility(itemSlot, weaponInfo)
    if LocalPlayer:GetAttribute("Equipped"..convertNumberToItemType(itemSlot)) ~= weaponInfo.Name then
        self.Root.EquipButton.Visible = true
        self.Root.UnequipButton.Visible = false
    else
        self.Root.EquipButton.Visible = false
        self.Root.UnequipButton.Visible = true
    end

    self.SelectedItem = weaponInfo 
end

function ClassArmoryUI:Populate(itemSlot: number)
    local currentClass = LocalPlayer:GetAttribute("CurrentClass")

    local weapons = self.SortedSlots[itemSlot]
    if currentClass ~= "" or currentClass ~= nil then
        weapons = courier:SendFunction("GetClassItems", itemSlot)
    end

    table.sort(weapons, function(a, b)
        return a.WeaponCost < b.WeaponCost
    end)

    self.SelectedItem = nil
    for _, weaponInfo in weapons do
        local weaponFrame = createWeaponFrame(weaponInfo.Name)
        weaponFrame.LayoutOrder = weaponInfo.LayoutOrder
        weaponFrame.WeaponName.Text = weaponInfo.Name

        if self.SelectedItem == nil then
            self:HandleButtonVisibility(itemSlot, weaponInfo)
        end

        self.Cleaner:Add(weaponFrame.Button.MouseButton1Click:Connect(function()
            self:HandleButtonVisibility(itemSlot, weaponInfo)
            self.Events.InspectItem:Fire(weaponInfo)
        end))

        weaponFrame.Parent = self.Root.List.Container
    end
end

function ClassArmoryUI:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(ClassArmoryUI)

return ClassArmoryUI