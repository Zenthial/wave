local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))
local Types = require(script.Types)
local Functions = require(script.Functions)

local WeaponStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))
local Trove= require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local SELECTED_FRAME_SIZE = UDim2.new(0.9, 0, 0.1, 0)
local SELECTED_ITEM_SIZE = UDim2.new(0.55, 0, 0.06, 0)

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type ArmoryUI_T = {
    __index: ArmoryUI_T,
    Name: string,
    Tag: string,
    Root: Types.Root,

    PrimaryDisplay: Frame,
    SecondaryDisplay: Frame,
    GadgetDisplay: Frame,
    SkillDisplay: Frame,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local ArmoryUI: ArmoryUI_T = {}
ArmoryUI.__index = ArmoryUI
ArmoryUI.Name = "ArmoryUI"
ArmoryUI.Tag = "ArmoryUI"
ArmoryUI.Ancestor = PlayerGui

function ArmoryUI.new(root: any)
    return setmetatable({
        Root = root,
        SelectedButton = nil,
        SelectedItem = nil,
        ItemDisplayCleaner = Trove.new()
    }, ArmoryUI)
end

function ArmoryUI:Start()
    self:ResetArmoryUI()
    self:HookItemButtons()
    self:HookSearchBar()

    repeat
        task.wait()
    until Player:GetAttribute("ServerSideInventoryLoaded") == true

    self.PrimaryDisplay = self:LoadItems("Primary", true)
    self.SecondaryDisplay = self:LoadItems("Secondary", false)
    self.GadgetDisplay = self:LoadItems("Gadget", false)
    self.SkillDisplay = self:LoadItems("Skill", false)

    self.PrimaryDisplay.Visible = true
    self.ActiveDisplay = self.PrimaryDisplay
    self.Root.ItemDisplay:Destroy()
    self:Close()

    Player:GetAttributeChangedSignal("InArmory"):Connect(function()
        if Player:GetAttribute("InArmory") then
            self:Open()
        else
            self:Close()
        end
    end)
end

function ArmoryUI:Open()
    self.Root.Visible = true
    self.ActiveDisplay.Visible = true
    
    TweenService:Create(self.Root.Details.TopClassDetail, TweenInfo.new(0.5), {Size = self.Root.Details.TopClassDetail:GetAttribute("Out")}):Play()
    TweenService:Create(self.Root.Details.TopClassRightDetail, TweenInfo.new(0.5), {Size = self.Root.Details.TopClassRightDetail:GetAttribute("Out")}):Play()
    TweenService:Create(self.Root.Details.TopClassLeftDetail, TweenInfo.new(0.5), {Size = self.Root.Details.TopClassLeftDetail:GetAttribute("Out")}):Play()
    TweenService:Create(self.Root.Title, TweenInfo.new(0.5), {Position = self.Root.Title:GetAttribute("In")}):Play()
    TweenService:Create(self.Root.ItemSwitcherList, TweenInfo.new(0.5), {Position = self.Root.ItemSwitcherList:GetAttribute("In")}):Play()
    TweenService:Create(self.ActiveDisplay.Details.TopDetail, TweenInfo.new(0.5), {Size = self.ActiveDisplay.Details.TopDetail:GetAttribute("Out")}):Play()
    TweenService:Create(self.ActiveDisplay.Details.BottomDetail, TweenInfo.new(0.5), {Size = self.ActiveDisplay.Details.BottomDetail:GetAttribute("Out")}):Play()
    TweenService:Create(self.Root.ItemInfo.Details.TopDetail, TweenInfo.new(0.5), {Size = self.Root.ItemInfo.Details.TopDetail:GetAttribute("Out")}):Play()

    task.wait(.2)
    TweenService:Create(self.Root.ItemInfo.Title, TweenInfo.new(0.5), {Position = self.Root.ItemInfo.Title:GetAttribute("In")}):Play()
    TweenService:Create(self.Root.ItemInfo.Top, TweenInfo.new(0.5), {Position = self.Root.ItemInfo.Top:GetAttribute("In")}):Play()
    TweenService:Create(self.Root.ItemInfo.Stats, TweenInfo.new(0.5), {Position = self.Root.ItemInfo.Stats:GetAttribute("In")}):Play()
    TweenService:Create(self.Root.Search, TweenInfo.new(0.5), {Position = self.Root.Search:GetAttribute("In")}):Play()

    task.wait(0.015)
    TweenService:Create(self.ActiveDisplay.ScrollingFrame, TweenInfo.new(0.5), {Position = self.ActiveDisplay.ScrollingFrame:GetAttribute("In")}):Play()
    TweenService:Create(self.ActiveDisplay.Title, TweenInfo.new(0.5), {Position = self.ActiveDisplay.Title:GetAttribute("In")}):Play()
end

function ArmoryUI:Close()
    -- this might be slightly confusing upon first read
    -- objects that are tweening their SIZE on close use the "In" value, cause they are tweening into themselves towards 0
    -- objects that are tweening their POSITION on close use the "Out" value, cause they are tweening out from the main viewport
    TweenService:Create(self.Root.Details.TopClassDetail, TweenInfo.new(0.5), {Size = self.Root.Details.TopClassDetail:GetAttribute("In")}):Play()
    TweenService:Create(self.Root.Details.TopClassRightDetail, TweenInfo.new(0.5), {Size = self.Root.Details.TopClassRightDetail:GetAttribute("In")}):Play()
    TweenService:Create(self.Root.Details.TopClassLeftDetail, TweenInfo.new(0.5), {Size = self.Root.Details.TopClassLeftDetail:GetAttribute("In")}):Play()
    TweenService:Create(self.Root.Title, TweenInfo.new(0.5), {Position = self.Root.Title:GetAttribute("Out")}):Play()
    TweenService:Create(self.Root.ItemSwitcherList, TweenInfo.new(0.5), {Position = self.Root.ItemSwitcherList:GetAttribute("Out")}):Play()
    TweenService:Create(self.ActiveDisplay.Details.TopDetail, TweenInfo.new(0.5), {Size = self.ActiveDisplay.Details.TopDetail:GetAttribute("In")}):Play()
    TweenService:Create(self.ActiveDisplay.Details.BottomDetail, TweenInfo.new(0.5), {Size = self.ActiveDisplay.Details.BottomDetail:GetAttribute("In")}):Play()
    TweenService:Create(self.Root.ItemInfo.Details.TopDetail, TweenInfo.new(0.5), {Size = self.Root.ItemInfo.Details.TopDetail:GetAttribute("In")}):Play()

    task.wait(.2)
    
    TweenService:Create(self.Root.ItemInfo.Title, TweenInfo.new(0.5), {Position = self.Root.ItemInfo.Title:GetAttribute("Out")}):Play()
    TweenService:Create(self.Root.ItemInfo.Top, TweenInfo.new(0.5), {Position = self.Root.ItemInfo.Top:GetAttribute("Out")}):Play()
    TweenService:Create(self.Root.ItemInfo.Stats, TweenInfo.new(0.5), {Position = self.Root.ItemInfo.Stats:GetAttribute("Out")}):Play()
    TweenService:Create(self.Root.Search, TweenInfo.new(0.5), {Position = self.Root.Search:GetAttribute("Out")}):Play()
    

    task.wait(0.015)
    TweenService:Create(self.ActiveDisplay.ScrollingFrame, TweenInfo.new(0.5), {Position = self.ActiveDisplay.ScrollingFrame:GetAttribute("Out")}):Play()
    TweenService:Create(self.ActiveDisplay.Title, TweenInfo.new(0.5), {Position = self.ActiveDisplay.Title:GetAttribute("Out")}):Play()

    task.wait(1)
    self.Root.Visible = false
end

function ArmoryUI:LoadItems(itemType: string, activeFrame: boolean)
    local itemDisplayFrame = self.Root.ItemDisplay:Clone()
    itemDisplayFrame.Name = itemType
    itemDisplayFrame.Title.Text = itemType
    if itemType == "Primary" or "Secondary" then
        itemDisplayFrame.Title.Text ..= " Weapons"
    end

    local items = Functions.GetItems(itemType)
    local equippedItem = Player:GetAttribute("Equipped"..itemType)

    itemDisplayFrame.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    for _, itemInfo in items do
        if itemInfo.Locked ~= true then
            task.spawn(function()
                local itemDisplay = Functions.CreateItemDisplay(itemInfo, itemInfo.Name == equippedItem, itemDisplayFrame.ScrollingFrame.Container)
                itemDisplayFrame.ScrollingFrame.CanvasSize += UDim2.new(0, 0, (itemDisplay.Size.Y.Scale + itemDisplayFrame.ScrollingFrame.Container.UIListLayout.Padding.Scale) * 2, 0)
                
                if itemInfo.Name == equippedItem and activeFrame then
                    self.SelectedItem = itemDisplay
                    self:FillSelected(itemInfo)
                end
                
                self.Cleaner:Add(itemDisplay.MainFrame.Button.MouseButton1Click:Connect(function()
                    TweenService:Create(self.SelectedItem.MainFrame, TweenInfo.new(0.5), {BackgroundColor3 = self.SelectedItem.MainFrame:GetAttribute("Default")}):Play()
                    TweenService:Create(self.SelectedItem.Selected, TweenInfo.new(0.5), {BackgroundTransparency = 1, Size = UDim2.new(0, 0, SELECTED_ITEM_SIZE.Y.Scale, 0)}):Play()
                    TweenService:Create(itemDisplay.MainFrame, TweenInfo.new(0.5), {BackgroundColor3 = itemDisplay.MainFrame:GetAttribute("Selected")}):Play()
                    TweenService:Create(itemDisplay.Selected, TweenInfo.new(0.5), {BackgroundTransparency = 0, Size = SELECTED_ITEM_SIZE}):Play()
        
                    self.SelectedItem = itemDisplay
                    self:HandleEquip(self:FillSelected(itemInfo), itemType, itemInfo)
                end))
    
                self.Cleaner:Add(itemDisplay)
            end)
        end
    end

    self.Cleaner:Add(itemDisplayFrame)
    itemDisplayFrame.Parent = self.Root
    itemDisplayFrame.Visible = false
    return itemDisplayFrame
end

function ArmoryUI:HookItemButtons()
    for _, button: Frame in pairs(self.Root.ItemSwitcherList:GetChildren()) do
        if button:IsA("Frame") then
            if button.LayoutOrder == 0 then
                button.SelectedFrame.BackgroundTransparency = 0
                self.SelectedButton = button
            else
                button.SelectedFrame.BackgroundTransparency = 1
                button.SelectedFrame.Size = UDim2.new(0, 0, SELECTED_FRAME_SIZE.Y.Scale, 0)
            end

            self.Cleaner:Add(button.Button.MouseButton1Click:Connect(function()
                local itemType = button.Name:sub(1, button.Name:len() - string.len("Button"))
                self[itemType.."Display"].Visible = true
                self.ActiveDisplay.Visible = false
                self.ActiveDisplay = self[itemType.."Display"]
                
                TweenService:Create(button.SelectedFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0, Size = SELECTED_FRAME_SIZE}):Play()
                TweenService:Create(self.SelectedButton.SelectedFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1, Size = UDim2.new(0, 0, SELECTED_FRAME_SIZE.Y.Scale, 0)}):Play()
                
                self.SelectedButton = button
            end))
        end
    end 
end

function ArmoryUI:HookSearchBar()
    self.Root.Search.Search.ClearTextOnFocus = true
    self.Root.Search.Search.FocusLost:Connect(function()
        local text = string.lower(self.Root.Search.Search.Text)

        local activeDisplayChildren = self.ActiveDisplay.ScrollingFrame.Container:GetChildren()
        for _, frame: Frame in activeDisplayChildren do
            if not frame:IsA("Frame") then continue end
            local nameStr = string.lower(frame.Name)
            local match = string.sub(nameStr, 0, string.len(text)) == text
            frame.Visible = match
        end
    end)
end

function ArmoryUI:ResetArmoryUI() 
    for _, thing in self.Root.ItemDisplay.ScrollingFrame.Container:GetChildren() do
        if not thing:IsA("UIListLayout") and not thing:IsA("UIPadding") then
            thing:Destroy()
        end
    end

    self:ClearBarStats()    
end

function ArmoryUI:ClearBarStats()
    for _, thing in self.Root.ItemInfo.Stats.BarStats:GetChildren() do
        if not thing:IsA("UIListLayout") and not thing:IsA("UIPadding") then
            thing:Destroy()
        end
    end    
end

function ArmoryUI:HandleEquip(equipSignal: RBXScriptSignal, itemType: string, weaponStats)
    self.Cleaner:Add(equipSignal:Connect(function()
        print("Equipping: ", Player:GetAttribute("Equipped"..itemType), weaponStats.Name, not (Player:GetAttribute("Equipped"..itemType) == weaponStats.Name))
        courier:Send("RequestChange", itemType, weaponStats.Name, not (Player:GetAttribute("Equipped"..itemType) == weaponStats.Name))
    end))
end

function ArmoryUI:FillSelected(selectedStats)
    self:ClearBarStats()

    local tier = Functions.GetTier(selectedStats.WeaponCost)
    local tierName = Functions.GetTierName(tier)
    local tierColor = Functions.TIER_COLORS[tier]

    local info = self.Root.ItemInfo
    info.Top.ItemName.Text = selectedStats.Name
    info.Top.RarityName.Text = tierName
    info.Top.RarityName.TextColor3 = tierColor
    info.Top.RarityColor.BackgroundColor3 = tierColor

    local coreStats = info.Stats.CoreStats
    if selectedStats.Damage then
        if selectedStats.Damage < 0 then
            coreStats.Damage.StatName = "HEAL"
        end
        coreStats.Damage.StatValue.Text = tostring(math.abs(selectedStats.Damage))
    else
        coreStats.Damage.StatName.Text = "MIN"
        coreStats.Damage.StatValue.Text = tostring(selectedStats.EnergyMin)
    end

    if selectedStats.FireRate then
        coreStats.FireRate.StatValue.Text = tostring(selectedStats.FireRate)
    else
        coreStats.FireRate.StatName.Text = "REGN"
        coreStats.FireRate.StatValue.Text = tostring(selectedStats.EnergyRegen)
    end

    if selectedStats.HeatRate then
        coreStats.HeatRate.StatValue.Text = tostring(selectedStats.HeatRate)
    else
        coreStats.HeatRate.StatName.Text = "DEPT"
        coreStats.HeatRate.StatValue.Text = tostring(selectedStats.EnergyDeplete)
    end

    if selectedStats.Slot == 1 or selectedStats.Slot == 2 then
        self:FillBar(selectedStats)
    end

    return info.Top.BG.EquipButton.Button.MouseButton1Click
end

local BAR_STATS = {
    HeadshotMultiplier = {Name = "Headshot Multiplier", MaxValue = 3},
    MaxSpread = {Name = "Spread", MaxValue = 5},
    ChargeWait = {Name = "Charge Wait", MaxValue = 1},
    CoolTime = {Name = "Cool Time", MaxValue = 10}
}

function ArmoryUI:FillBar(weaponStats)
    local slot = weaponStats.Slot
    local equippedWeaponStats = WeaponStats[if slot == 1 then Player:GetAttribute("EquippedPrimary") else Player:GetAttribute("EquippedSecondary")]

    for statName, statTable in BAR_STATS do
        local newStatValue = weaponStats[statName]
        local oldStatValue = equippedWeaponStats[statName]

        local bar = Functions.CreateBarStat(statTable.Name, oldStatValue, newStatValue, statTable.MaxValue)
        bar.Parent = self.Root.ItemInfo.Stats.BarStats
    end
end

function ArmoryUI:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(ArmoryUI)

return ArmoryUI
