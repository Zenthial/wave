local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"):WaitForChild("GenericTypes"))
local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))
local courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))
local WeaponStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))

local WeaponFrame = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("UI"):WaitForChild("WeaponFrame") :: Frame & {}

local LocalPlayer = Players.LocalPlayer

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
        ItemSelected: typeof(Signal)
    },

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local ClassArmoryUI: ClassArmoryUI_T = {}
ClassArmoryUI.__index = ClassArmoryUI
ClassArmoryUI.Name = "ClassArmoryUI"
ClassArmoryUI.Tag = "ClassArmoryUI"
ClassArmoryUI.Ancestor = game

function ClassArmoryUI.new(root: any)
    return setmetatable({
        Root = root,
        SelectedItem = nil,
        Events = {
            ItemSelected = Signal.new()
        }
    }, ClassArmoryUI)
end

function ClassArmoryUI:Start()
    local sorted = {{},{},{},{}}
    for _, weaponStats in WeaponStats do
        sorted[weaponStats.Slot] = table.insert(weaponStats)
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
end

function ClassArmoryUI:Populate(itemSlot: number)
    local currentClass = LocalPlayer:GetAttribute("CurrentClass")

    local weapons = self.SortedSlots[itemSlot]
    if currentClass ~= "" or currentClass ~= nil then
        weapons = courier:SendFunction("GetClassItems", itemSlot)
    end

    for _, weaponInfo in weapons do
        local weaponFrame = WeaponFrame:Clone()
        weaponFrame.WeaponName.Text = weaponInfo.Name
        self.Cleaner:Add(weaponFrame.Button.MouseButton1Click:Connect(function()
            if LocalPlayer:GetAttribute("Equipped"..convertNumberToItemType(itemSlot)) ~= weaponInfo.Name then
                self.Root.EquipButton.Visible = true
                self.Root.UnequipButton.Visible = false
            else
                self.Root.EquipButton.Visible = false
                self.Root.UnequipButton.Visible = true
            end

            self.SelectedItem = weaponInfo
            self.Events.ItemSelected:Fire(weaponInfo)
        end))
    end
end

function ClassArmoryUI:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(ClassArmoryUI)

return ClassArmoryUI