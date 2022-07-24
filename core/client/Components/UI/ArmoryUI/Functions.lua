local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ViewportModel = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ViewportModel"))
local Courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))

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
local SELECTED_SIZE = UDim2.new(0.55, 0, 0.06, 0)
local UNSELECTED_SIZE = UDim2.new(0, 0, 0.06, 0)

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

local function fill_viewport(viewport: ViewportFrame, modelFolder: Configuration | Folder)
    local camera = Instance.new("Camera")
    viewport.CurrentCamera = camera
    
    local viewportModel = ViewportModel.new(viewport, camera)
    
    local inspectModel
    if modelFolder:IsA("Configuration") and modelFolder:FindFirstChild("Model") then
        inspectModel = modelFolder.Model:Clone() :: Model
        inspectModel.PrimaryPart = nil
        inspectModel:PivotTo(CFrame.new(Vector3.new(0, 0, 0),  Vector3.new(5, 0, 0)))
    elseif modelFolder:IsA("Configuration") and modelFolder:FindFirstChild("Projectile") then
        local model = Instance.new("Model")
        local proj = modelFolder.Projectile:Clone()
        proj.Parent = model
        inspectModel = model
        inspectModel:PivotTo(CFrame.new(Vector3.new(0, 0, 0)))
    elseif modelFolder:IsA("Model") then -- skill
        inspectModel = modelFolder:Clone()
        inspectModel.PrimaryPart = nil
        inspectModel:PivotTo(CFrame.new(Vector3.new(0, 0, 0), Vector3.new(0, 0, 5)))
    end

    inspectModel.Name = "InspectModel" .. modelFolder.Name
    inspectModel.Parent = viewport

    viewportModel:SetModel(inspectModel)
    viewportModel:Calibrate()
    
    local cF = inspectModel:GetBoundingBox()
    local distance = viewportModel:GetFitDistance(cF.Position)
    camera.CFrame = CFrame.new(cF.Position) * CFrame.new(0, 0, distance)
end

local function get_item(itemName: string)
    local item = Weapons[itemName]
    if item == nil then
        item = Skills[itemName]
    end

    assert(item, "No item in Weapons or Skills for "..itemName)
    return item
end

local function createItemDisplay(weaponStats, selected: boolean)
    local tier = getTier(weaponStats.WeaponCost)

    local points = Player:GetAttribute("Points")
    local pointsRemaining = weaponStats.WeaponCost - points :: number
    local formattedPoints = comma_value(points)
    local stringPoints = get_string(formattedPoints)

    local itemDisplay = ItemDisplay:Clone()
    itemDisplay.MainFrame.ItemName.Text = weaponStats.Name
    itemDisplay.MainFrame.Price.Text = stringPoints
    itemDisplay.MainFrame.BackgroundColor3 = itemDisplay.MainFrame:GetAttribute((selected and "Selected") or "Default")

    itemDisplay.Selected.BackgroundTransparency = 0
    itemDisplay.Selected.Size = (selected and SELECTED_SIZE) or UNSELECTED_SIZE
    
    itemDisplay.Locked.ItemName.Text = weaponStats.Name
    itemDisplay.Locked.Price.Text = tostring(pointsRemaining) .. " Points Remaining"

    itemDisplay.TierFrame.TierRating.Text = string.format(FORMAT, tostring(tier))

    itemDisplay.ViewportFrame.BackgroundColor3 = TIER_COLORS[tier]
    fill_viewport(itemDisplay.ViewportFrame, get_item(weaponStats.Name))

    if pointsRemaining > 0 then
        itemDisplay.Locked.Visible = true
        itemDisplay.MainFrame.Visible = false
    end

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
    TierColors = TIER_COLORS,
    CreateBarStat = createBarStat,
    GetItems = getItems
}