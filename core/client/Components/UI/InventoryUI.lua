local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local WeaponStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))

local Assets = ReplicatedStorage:WaitForChild("Assets")
local ItemFrame = Assets:WaitForChild("UI"):WaitForChild("Item")

local Player = Players.LocalPlayer

type ItemFrame_T = {
    Fill: Frame,
    GadgetAmount: ImageLabel & {TextLabel: TextLabel},
    Icon: ImageLabel,
    Keybind: TextLabel,
    Timer: TextLabel
}

local function getItemIcon(name: string)
    return ""
end

local function make(name: string, weaponStats)
    local frame = ItemFrame:Clone() :: ItemFrame_T
    
    if weaponStats.Slot == 3 then
        frame.Keybind.Text = Player.Keybinds:GetAttribute("Gadget")
        frame.GadgetAmount.Visible = true
        frame.GadgetAmount.TextLabel.Text = "3"
    elseif weaponStats.Slot == 4 then
        frame.Keybind.Text = Player.Keybinds:GetAttribute("Skill")
        frame.GadgetAmount.Visible = false
    end

    frame.Timer.TextTransparency = 1
    frame.Icon.Image = getItemIcon(name)
    frame.Fill.Size = UDim2.new(1, 0, 0, 0)

    return frame
end

local function clearInventoryToolbar(bar)
    for _, thing in pairs(bar:GetChildren()) do
        if thing:IsA("Frame") then
            thing:Destroy()
        end
    end
end

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type InventoryUI_T = {
    __index: InventoryUI_T,
    Name: string,
    Tag: string,
    SkillUI: ItemFrame_T,
    GadgetUI: ItemFrame_T,

    Cleaner: Cleaner_T
}

local InventoryUI: InventoryUI_T = {}
InventoryUI.__index = InventoryUI
InventoryUI.Name = "InventoryUI"
InventoryUI.Tag = "InventoryUI"
InventoryUI.Ancestor = game
InventoryUI.Needs = {"Cleaner"}

function InventoryUI.new(root: any)
    return setmetatable({
        Root = root,
        SkillUI = nil,
        GadgetUI = nil,

        PlacingTween = nil,
    }, InventoryUI)
end

function InventoryUI:CreateDependencies()
    return {}
end

function InventoryUI:Start()
    local equippedSkillSignal = Player:GetAttributeChangedSignal("EquippedSkill")
    local equippedGadgetSignal = Player:GetAttributeChangedSignal("EquippedGadget")
    local gadgetQuantitySignal = Player:GetAttributeChangedSignal("GadgetQuantity")
    local placingDeployableSignal = Player:GetAttributeChangedSignal("PlacingDeployable")
    clearInventoryToolbar(self.Root)

    self.Cleaner:Add(equippedSkillSignal:Connect(function()
        local equippedSkill = Player:GetAttribute("EquippedSkill") or "--" :: string
        if equippedSkill == "" or equippedSkill == "--" then
            self.SkillUI:Destroy()
        else
            self.SkillUI = make(equippedSkill, WeaponStats[equippedSkill])
            self.SkillUI.Parent = self.Root
        end
    end))

    self.Cleaner:Add(equippedGadgetSignal:Connect(function()
        local equippedGadget = Player:GetAttribute("EquippedGadget") or "--" :: string
        if equippedGadget == "" or equippedGadget == "--" then
            self.GadgetUI:Destroy()
        else
            self.GadgetUI = make(equippedGadget, WeaponStats[equippedGadget])
            self.GadgetUI.Parent = self.Root
        end
    end))

    self.Cleaner:Add(gadgetQuantitySignal:Connect(function()
        local quantity = Player:GetAttribute("GadgetQuantity") :: number
        if self.GadgetUI ~= nil then
            if quantity == 0 then
                TweenService:Create(self.GadgetUI.GadgetAmount, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(255, 149, 0)}):Play()
                TweenService:Create(self.GadgetUI.GadgetAmount.TextLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            else
                if self.GadgetUI.GadgetAmount.ImageColor3 == Color3.fromRGB(255, 149, 0) then
                    TweenService:Create(self.GadgetUI.GadgetAmount, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                end

                if self.GadgetUI.GadgetAmount.TextLabel.TextColor3 == Color3.fromRGB(255, 255, 255) then
                    TweenService:Create(self.GadgetUI.GadgetAmount.TextLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(0, 0, 0)}):Play()
                end
            end
            
            self.GadgetUI.GadgetAmount.TextLabel.Text = quantity
        end
    end))

    self.Cleaner:Add(placingDeployableSignal:Connect(function()
        local placing = Player:GetAttribute("PlacingDeployable")

        if placing then
            local equippedGadget = Player:GetAttribute("EquippedGadget")
            local gadgetStats = WeaponStats[equippedGadget]
    
            if gadgetStats then
                local tween = TweenService:Create(self.GadgetUI.Fill, TweenInfo.new(gadgetStats.DeployTime), {Size = UDim2.new(1, 0, 1, 0)})
                tween:Play()
                self.PlacingTween = tween
            end
        else
            if self.PlacingTween ~= nil then
                task.wait(0.05)
                self.PlacingTween:Cancel()
                self.PlacingTween = nil
                TweenService:Create(self.GadgetUI.Fill, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 0)}):Play()
            end
        end        
    end))

    print("inventory UI started")
end

function InventoryUI:SetSkillCharge(charge: number)
    if charge == 100 then
        self.SkillUI.Timer.Text = "0.0"
        TweenService:Create(self.SkillUI.Timer, TweenInfo.new(0.05), {TextTransparency = 1}):Play()
        TweenService:Create(self.SkillUI.Icon, TweenInfo.new(0.05), {ImageTransparency = 0}):Play()
    else
        if self.SkillUI.Timer.TextTransparency ~= 0 then
            TweenService:Create(self.SkillUI.Timer, TweenInfo.new(0.1), {TextTransparency = 0}):Play()
        end

        if self.SkillUI.Icon.ImageTransparency ~= 0.75 then
            TweenService:Create(self.SkillUI.Icon, TweenInfo.new(0.1), {ImageTransparency = 0.75}):Play()
        end
    end

    TweenService:Create(self.SkillUI.Fill, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, (100 - charge)/100, 0)}):Play()
end

function InventoryUI:SetSkillActive()
    TweenService:Create(self.SkillUI.Fill, TweenInfo.new(0.05), {Size = UDim2.new(1, 0, 1, 0)}):Play()
end

function InventoryUI:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(InventoryUI)

return InventoryUI