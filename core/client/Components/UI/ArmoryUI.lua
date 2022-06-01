local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))
local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))
local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local WeaponStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local Weapons = Assets:WaitForChild("Weapons")
local UI = Assets:WaitForChild("UI")
local StatsUI = UI:WaitForChild("Stats")
local TypeHeaderButton = UI:WaitForChild("TypeHeaderButton") :: Frame & {
    Button: TextButton,
    TextLabel: TextLabel
}

type Item = Frame & {
    Fill: Frame,
    Button: TextButton,
    TextLabel: TextLabel
}

local ListItem = UI:WaitForChild("ListItem") :: Item

type List = ScrollingFrame & {
    Container: Frame & {
        UIListLayout: UIListLayout
    }
}

local ArmoryList = UI:WaitForChild("ArmoryList") :: List

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type ArmoryUI_T = {
    __index: ArmoryUI_T,
    Name: string,
    Tag: string,
    Root: Frame & {
        WeaponTypes: Frame,
        Equip: Frame & {
            Button: TextButton,
        },
        Stats: Frame & {UIListLayout}
    },

    Cleaner: Cleaner_T
}

local ArmoryUI: ArmoryUI_T = {}
ArmoryUI.__index = ArmoryUI
ArmoryUI.Name = "ArmoryUI"
ArmoryUI.Tag = "ArmoryUI"
ArmoryUI.Ancestor = PlayerGui

function ArmoryUI.new(root: any)
    return setmetatable({
        Root = root,

        Events = {
            AttemptEquip = Signal.new(),
            AttemptPurchase = Signal.new(),
            InspectItem = Signal.new(),
        }
    }, ArmoryUI)
end

function ArmoryUI:Start()
    self.Root.Visible = false
    for _, thing in pairs(self.Root.WeaponTypes:GetChildren()) do
        if not thing:IsA("UIListLayout") then
            thing:Destroy()
        end
    end
    self.Root.List:Destroy()
end

function ArmoryUI:CreateCategory(categoryName: string)
    local categoryFrame = TypeHeaderButton:Clone()
    categoryFrame.Name = categoryName

    local name = ""
    for i = 1, string.len(categoryName) do
        local letter = string.sub(categoryName, i, i)
        name = name .. letter:upper() .. " "
    end
    categoryFrame.TextLabel.Text = name

    categoryFrame.Parent = self.Root.WeaponTypes

    local categoryList = ArmoryList:Clone()
    categoryList.Visible = false
    categoryList.Name = categoryName.."List"
    categoryList.Parent = self.Root
    
    return {Frame = categoryFrame, List = categoryList}
end

function ArmoryUI:DisplayItem(itemName)
    local modelFolder = Weapons[itemName]
    if modelFolder ~= nil then
        if modelFolder:FindFirstChild("Model") then
            local model = modelFolder.Model:Clone()
            -- stuck here trying to think about making all the models fit perfectly
        elseif modelFolder:FindFirstChild("Projectile") then

        end
    end
end

function ArmoryUI:CreateItem(itemName: string, itemInfo, list: List)
    local item = ListItem:Clone()

    item.Name = itemName
    item.LayoutOrder = itemInfo.WeaponCost
    item.TextLabel.Text = itemName

    item.Parent = list.Container

    return item
end

local function getAlphabeticalKey(dictionary: {[string]: any}): string
    local lowestAlphabetical = nil

    for key, _ in pairs(dictionary) do
        if lowestAlphabetical == nil then
            lowestAlphabetical = key
        elseif lowestAlphabetical > key then -- if its higher lexicographically then it is higher in the alphabet
            lowestAlphabetical = key
        end
    end

    return lowestAlphabetical
end

function ArmoryUI:Populate(slot: number)
    for _, thing in pairs(self.Root.WeaponTypes:GetChildren()) do if not thing:IsA("UIListLayout") then thing:Destroy() end end

    local sessionCleaner = Trove.new()
    local currentSelectedSignal = Signal.new()
    local currentlySelected = Player:GetAttribute("EquippedPrimary")
    local previouslySelectedItemComponent = nil
    if slot == 2 then
        currentlySelected = Player:GetAttribute("EquippedSecondary")
    elseif slot == 3 then
        currentlySelected = Player:GetAttribute("EquippedGadget")
    elseif slot == 4 then
        currentlySelected = Player:GetAttribute("EquippedSkill")
    end
    self.Events.InspectItem:Fire(currentlySelected)

    -- initialize categories and items
    local categories: {[string]: {Frame: Item, List: List}} = {}
    for _, weaponInfo in pairs(WeaponStats) do
        if weaponInfo.Slot ~= slot or weaponInfo.Slot == "Misc" or weaponInfo.Locked == nil or weaponInfo.Locked == true then continue end
        if categories[weaponInfo.Category] == nil then
            categories[weaponInfo.Category] = self:CreateCategory(weaponInfo.Category)
        end

        local item = self:CreateItem(weaponInfo.Name, weaponInfo, categories[weaponInfo.Category].List)        
        local listItemComponent = tcs.get_component(item, "ListItem")

        if weaponInfo.Name == currentlySelected then
            listItemComponent:SetSelected(true)
            previouslySelectedItemComponent = listItemComponent
            self:GetStats(weaponInfo.Name)
        end
        
        sessionCleaner:Add(listItemComponent.Events.SelectChanged:Connect(function(selected: boolean)
            if selected then
                currentSelectedSignal:Fire(weaponInfo.Name)
            end
        end))
    end


    -- category handling
    local currentCategory = getAlphabeticalKey(categories)
    local previouslySelectedComponent = nil
    for categoryName, category in pairs(categories) do
        local itemComponent = tcs.get_component(category.Frame, "TypeHeaderButton")
        sessionCleaner:Add(itemComponent.Events.SelectChanged:Connect(function(selected: boolean)
            previouslySelectedComponent:SetSelected(false)
            categories[currentCategory].List.Visible = false
            categories[categoryName].List.Visible = true
            currentCategory = categoryName
            previouslySelectedComponent = itemComponent
        end))

        local children = category.List.Container:GetChildren()
        local numItems = #children - 1 -- subtract one for the UIListLayout
        category.List.CanvasSize = UDim2.new(0, 0, (category.List.Container.UIListLayout.Padding.Scale * numItems), (children[2].AbsoluteSize.Y * numItems))

        if currentCategory == categoryName then
            previouslySelectedComponent = itemComponent
            itemComponent:SetSelected(true)
            category.List.Visible = true
        end
    end

    -- changing the selected item
    sessionCleaner:Add(currentSelectedSignal:Connect(function(itemName)
        if itemName ~= currentlySelected then
            local itemFrame = categories[currentCategory].List.Container:FindFirstChild(itemName)
            local newComponent = tcs.get_component(itemFrame, "ListItem")
            previouslySelectedItemComponent:SetSelected(false)
            previouslySelectedItemComponent = newComponent
            currentlySelected = itemName
            self.Events.InspectItem:Fire(itemName)
            self:GetStats(itemName)
        end
    end))

    local equipSignal = Signal.new()
    sessionCleaner:Add(self.Root.Equip.Button.MouseButton1Click:Connect(function()
        -- need to add equip displaying based off if they own the weapon or not
        equipSignal:Fire(currentlySelected)
        sessionCleaner:Clean()
    end))

    sessionCleaner:Add(self.Root.Back.Button.MouseButton1Click:Connect(function()
        -- need to add equip displaying based off if they own the weapon or not
        equipSignal:Fire(nil)
        sessionCleaner:Clean()
    end))

    self.Root.Visible = true

    sessionCleaner:Add(function()
        self.Root.Visible = false

        for _, category in pairs(categories) do
            category.Frame:Destroy()
            category.List:Destroy()
        end
    end)
    self.Cleaner:Add(sessionCleaner, "Clean")

    return equipSignal
end

local statsToCreate = {
    ["Trigger"] = {type = "string", name = "Trigger", order = 1},
    ["AmmoType"] = {type = "string", name = "Ammo Type", order = 1},
    ["FireMode"] = {type = "string", name = "Fire Mode", order = 1},
    ["BulletType"] = {type = "string", name = "Bullet Type", order = 1},
    ["Damage"] = {type = "number", name = "Damage", outOf = 30, order = 2},
    ["HeadshotMultiplier"] = {type = "number", name = "Multiplier", outOf = 3, order = 2}
}

function ArmoryUI:GetStats(weaponName)
    local weaponStats = WeaponStats[weaponName]
    for _, thing in pairs(self.Root.Stats:GetChildren()) do if not thing:IsA("UIListLayout") then thing:Destroy() end end

    for statName, statTable in pairs(statsToCreate) do
        if statTable.type == "string" then
            local stat = StatsUI.StringStat:Clone()
            stat.StatName.Text = statTable.name

            local value = weaponStats[statName]
            if value == nil then stat:Destroy() continue end
            stat.StatValue.Text = value
            stat.LayoutOrder = statTable.order
            stat.Parent = self.Root.Stats
        elseif statTable.type == "number" then
            local stat = StatsUI.NumberStat:Clone()
            stat.StatName.Text = statTable.name

            local value = weaponStats[statName]
            if value == nil then stat:Destroy() continue end
            if value < 0 and statTable.name == "Damage" then
                statTable.outOf = 100
                value = math.abs(value)
                stat.StatName.Text = "Heals"
            end
            stat.StatValue.Text = value
            stat.Bar.Fill.Size = UDim2.new(math.clamp(value, 0, statTable.outOf) / statTable.outOf, 0, 1, 0)
            stat.LayoutOrder = statTable.order
            stat.Parent = self.Root.Stats
        end
    end
end

function ArmoryUI:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(ArmoryUI)

return ArmoryUI