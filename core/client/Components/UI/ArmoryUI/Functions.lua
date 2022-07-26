local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ViewportModel = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ViewportModel"))
local Courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))
local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local WeaponStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))

type ItemDisplay = Frame & {
    ViewportFrame: ViewportFrame,
    Locked: Frame & {
        ItemName: TextLabel,
        Price: TextLabel
    },
    MainFrame: Frame & {
        Button: TextButton,
        ItemName: TextLabel,
        Price: TextLabel
    },
    Selected: Frame,
    TierFrame: Frame & {
        TierName: TextLabel,
        TierRating: TextLabel
    }
}

type BarStat = Frame & {
    StatName: TextLabel,
    Bar: Frame & {
        GreenFill: Frame,
        RedFill: Frame,
        Tick: Frame,
        WhiteFrame: Frame
    }
}

local Player = Players.LocalPlayer

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Weapons = Assets:WaitForChild("Weapons")
local Skills = Assets:WaitForChild("Skills")
local Gadgets = Assets:WaitForChild("Gadgets")
local ArmoryUIAssets = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("UI"):WaitForChild("Armory")
local ItemDisplay = ArmoryUIAssets:WaitForChild("ItemDisplay") :: ItemDisplay
local BarStat = ArmoryUIAssets:WaitForChild("BarStat") :: BarStat

local TIER_COLORS = {
    Color3.fromRGB(21, 216, 70),
    Color3.fromRGB(61, 148, 255),
    Color3.fromRGB(255, 21, 244),
    Color3.fromRGB(255, 185, 43)
}

local FORMAT = "<font color=\"rgb(255, 255, 255)\">%s</font>"

local function getItems(itemType: string)
    local currentClass = Player:GetAttribute("CurrentClass")
    if currentClass ~= nil then
        return Courier:SendFunction("GetClassItems", currentClass, itemType)
    end

    local slot = 1
    if itemType == "Secondary" then
        slot = 2
    elseif itemType == "Gadget" then
        slot = 3
    elseif itemType == "Skill" then
        slot = 4
    end

    local items = {}
    for _, itemInfo in pairs(WeaponStats) do
        if itemInfo.Slot == slot then
            table.insert(items, itemInfo)
        end
    end

    return items
end

local function comma_value(n: number) -- credit http://richard.warburton.it
	local left, num, right = string.match(n, '^([^%d]*%d)(%d*)(.-)$')
	return left .. (num:reverse():gsub('(%d%d%d)', '%1,'):reverse()) .. right
end

local function get_string(str: string)
    return str .. " Points"

    if str:len() == 6 then
        return string.format(FORMAT, str).." Points"
    elseif str:len() == 5 then
        return "0"..string.format(FORMAT, str).." Points"
    elseif str:len() == 3 then
        return "00,"..string.format(FORMAT, str).." Points"
    elseif str:len() == 2 then
        return "00,0"..string.format(FORMAT, str).." Points"
    elseif str:len() == 1 then
        return "00,00"..string.format(FORMAT, str).." Points"
    end
end

local function getTier(cost)
    if cost < 1000 then
        return 1
    elseif cost < 2500 then
        return 2
    elseif cost < 5000 then
        return 3
    else
        return 4
    end
end

local function getTierName(tier: number)
    if tier == 1 then
        return "Standard"
    elseif tier == 2 then
        return "Specialized"
    elseif tier == 3 then
        return "Superior"
    else
        return "Legendary"
    end
end

local function get_item(itemName: string)
    local item = Weapons:FindFirstChild(itemName)
    if item == nil then
        item = Skills:FindFirstChild(itemName)

        if item == nil then
            item = Gadgets:FindFirstChild(itemName)
        end
    end

    assert(item, "No item in Weapons or Skills for "..itemName)
    return item
end

local function createItemDisplay(weaponStats, selected: boolean, parent: Instance)
    local itemDisplay = ItemDisplay:Clone()
    CollectionService:AddTag(itemDisplay, "ItemDisplay")
    itemDisplay.LayoutOrder = weaponStats.WeaponCost
    itemDisplay.Parent = parent

    local displayComponent = tcs.get_component(itemDisplay, "ItemDisplay")
    displayComponent:SetWeapon(weaponStats, selected)
    
    return itemDisplay
end

local function createBarStat(statName: string, oldValue: number, newValue: number, maxValue: number)
    local bar = BarStat:Clone()

    bar.StatName.Text = statName
    bar.Bar.RedFill.Size = UDim2.new(math.clamp(oldValue, 0, maxValue)/maxValue, 0, 1, 0)
    
    if newValue > oldValue then
        bar.Bar.GreenFill.Size = UDim2.new(math.clamp(newValue, 0, maxValue)/maxValue, 0, 1, 0)
        bar.Bar.WhiteFill.Size = UDim2.new(math.clamp(oldValue, 0, maxValue)/maxValue, 0, 1, 0)
        bar.Bar.Tick.Position = UDim2.new(math.clamp(newValue, 0, maxValue)/maxValue, 0, 1, 0)
    else
        bar.Bar.Tick.Position = UDim2.new(math.clamp(oldValue, 0, maxValue)/maxValue, 0, 1, 0)
        bar.Bar.WhiteFill.Size = UDim2.new(math.clamp(newValue, 0, maxValue)/maxValue, 0, 1, 0)
        bar.Bar.GreenFill.Size = UDim2.new(0, 0, 1, 0)
    end

    return bar
end

return {
    CreateItemDisplay = createItemDisplay,
    GetTier = getTier,
    GetTierName = getTierName,
    TIER_COLORS = TIER_COLORS,
    CommaValue = comma_value,
    GetString = get_string,
    CreateBarStat = createBarStat,
    GetItems = getItems,
    GetItem = get_item,
    FORMAT = FORMAT
}
