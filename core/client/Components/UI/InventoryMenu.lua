local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local bluejay = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("bluejay"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))
local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))
local WeaponStats_V2 = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))
local initializeWeapon = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("functions"):WaitForChild("initializeWeaponViewport"))
local Weapons = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Weapons")
local Skills = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Skills")
local Gadgets = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Gadgets")
local UIAssets = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("UI")
local ShopItem = UIAssets:WaitForChild("ShopItem")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local INVENTORY_COLORS = {
    Color3.fromRGB(55, 255, 0),
    Color3.fromRGB(46, 142, 225),
    Color3.fromRGB(255, 75, 0),
    Color3.fromRGB(164, 16, 255)
}

local function getDetailColor(cost: number)
    if cost < 2000 then
        return INVENTORY_COLORS[1]
    elseif cost < 4000 then
        return INVENTORY_COLORS[2]
    elseif cost < 6000 then
        return INVENTORY_COLORS[3]
    elseif cost >= 6000 then
        return INVENTORY_COLORS[4]
    end
end

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

-- this type is kinda large, sorry for any other readers, just skip down to the code
type InventoryMenu_T = {
    __index: InventoryMenu_T,
    Name: string,
    Tag: string,
    Root: {
        Inventory: Frame & {
            Weapons: Frame & {
                Primary: Frame & {
                    ViewportFrame: ViewportFrame,
                    Detail: Frame,
                    Button: TextButton,
                    Title: TextLabel
                },

                Secondary: Frame & {
                    ViewportFrame: ViewportFrame,
                    Detail: Frame,
                    Button: TextButton,
                    Title: TextLabel
                }
            },

            Utility: Frame & {
                Skill: Frame & {
                    ViewportFrame: ViewportFrame,
                    Detail: Frame,
                    Button: TextButton,
                    Title: TextLabel
                },

                Gadget: Frame & {
                    ViewportFrame: ViewportFrame,
                    Detail: Frame,
                    Button: TextButton,
                    Title: TextLabel
                }
            },
        },

        Shop: Frame & {
            BackButton: TextButton,
            Back: ImageLabel,
            Title: TextLabel,
            Container: ScrollingFrame & {
                UIListLayout: UIListLayout
            }
        }
    },

    State: {
        OpenPanel: Frame,
    },

    Events: {
        Inspect: typeof(Signal)
    },

    Cleaner: Cleaner_T,
    ShopCleaner: Cleaner_T,
}

local InventoryMenu: InventoryMenu_T = {}
InventoryMenu.__index = InventoryMenu
InventoryMenu.Name = "InventoryMenu"
InventoryMenu.Tag = "InventoryMenu"
InventoryMenu.Ancestor = PlayerGui
InventoryMenu.Needs = {"Cleaner"}

function InventoryMenu.new(root: any)
    return setmetatable({
        Root = root,
        Events = {
            Inspect = Signal.new()
        }
    }, InventoryMenu)
end

function InventoryMenu:CreateDependencies()
    return {}
end

function InventoryMenu:Start()
    self.ShopCleaner = Trove.new()

    self:InitializeWeapons()
    self:InitializeUtilities()
end

function InventoryMenu:InitializeWeapons()
    local primary = Player:GetAttribute("EquippedPrimary")
    local secondary = Player:GetAttribute("EquippedSecondary")

    local primaryFrame = self.Root.Inventory.Weapons.Primary
    local secondaryFrame = self.Root.Inventory.Weapons.Secondary

    local primaryStats = WeaponStats_V2[primary]
    local secondaryStats = WeaponStats_V2[secondary]

    primaryFrame.Title.Text = primaryStats.Name
    secondaryFrame.Title.Text = secondaryStats.Name

    primaryFrame.ViewportFrame:ClearAllChildren()
    secondaryFrame.ViewportFrame:ClearAllChildren()

    self.Cleaner:Add(initializeWeapon(primaryFrame.ViewportFrame, Weapons[primary].Model:Clone(), 0.5))
    self.Cleaner:Add(initializeWeapon(secondaryFrame.ViewportFrame, Weapons[secondary].Model:Clone()))

    self.Cleaner:Add(primaryFrame.Button.Activated:Connect(function() self:DisplayShop(1) end))
    self.Cleaner:Add(secondaryFrame.Button.Activated:Connect(function() self:DisplayShop(2) end))
end

function InventoryMenu:InitializeUtilities()
    local skill = Player:GetAttribute("EquippedSkill")
    local gadget = Player:GetAttribute("EquippedGadget")

    local skillFrame = self.Root.Inventory.Utility.Skill
    local gadgetFrame = self.Root.Inventory.Utility.Gadget

    local skillStats = WeaponStats_V2[skill]
    local gadgetStats = WeaponStats_V2[gadget]

    skillFrame.Title.Text = skillStats.Name
    gadgetFrame.Title.Text = gadgetStats.Name

    skillFrame.ViewportFrame:ClearAllChildren()
    gadgetFrame.ViewportFrame:ClearAllChildren()

    self.Cleaner:Add(initializeWeapon(skillFrame.ViewportFrame, Skills[skill]:Clone()))

    local projModel = Instance.new("Model")
    Gadgets[gadget].Projectile:Clone().Parent = projModel

    self.Cleaner:Add(initializeWeapon(gadgetFrame.ViewportFrame, projModel))

    self.Cleaner:Add(gadgetFrame.Button.Activated:Connect(function() self:DisplayShop(3) end))
    self.Cleaner:Add(skillFrame.Button.Activated:Connect(function() self:DisplayShop(4) end))
end

type ShopItem = Frame & {
    ViewportFrame: ViewportFrame,
    Description: Frame & {
        Desc: TextLabel
    },
    Overlay: Frame & {
        Inspect: TextButton,
        Purchase: TextButton
    },
    GunName: TextLabel,
    CostNum: TextLabel,
    Detail: Frame,
    OverlayButton: TextButton
}

function InventoryMenu:DisplayShop(slot: number)
    self:CleanShop()

    local items = {}

    for _, itemStats in pairs(WeaponStats_V2) do
        if itemStats.Slot ~= nil and itemStats.Slot == slot and itemStats.WeaponCost ~= nil and itemStats.QuickDescription ~= nil and itemStats.Locked ~= nil and itemStats.Locked == false then
            table.insert(items, itemStats)
        end
    end

    table.sort(items, function(a, b)
        return a.WeaponCost < b.WeaponCost
    end)

    local newSize = 0
    for _, itemStats in pairs(items) do
        local itemFrame = ShopItem:Clone() :: ShopItem
        itemFrame.Description.Desc.Text = itemStats.QuickDescription
        itemFrame.GunName.Text = itemStats.Name
        itemFrame.CostNum.Text = itemStats.WeaponCost
        itemFrame.Detail.BackgroundColor3 = getDetailColor(itemStats.WeaponCost)
        itemFrame.Overlay.Purchase.Text = string.format("BUY: %d", itemStats.WeaponCost)

        local model
        if slot == 1 or slot == 2 then
            if Weapons:FindFirstChild(itemStats.Name) ~= nil and Weapons[itemStats.Name]:FindFirstChild("Model") ~= nil then
                model = Weapons[itemStats.Name].Model:Clone()
            end
        end

        if model then
            self.ShopCleaner:Add(initializeWeapon(itemFrame.ViewportFrame, model, 1))
            itemFrame.Parent = self.Root.Shop.Container
            newSize += itemFrame.AbsoluteSize.Y

            local cleaner = Trove.new()
            self.ShopCleaner:Add(itemFrame.OverlayButton.MouseEnter:Connect(function()
                itemFrame.Overlay.Visible = true
                
                cleaner:Add(itemFrame.Overlay.Inspect.Activated:Connect(function()
                    self.Events.Inspect:Fire(itemStats.Name, slot)
                end))
            end))

            self.ShopCleaner:Add(itemFrame.OverlayButton.MouseLeave:Connect(function()
                itemFrame.Overlay.Visible = false

                cleaner:Clean()
                cleaner = Trove.new()
            end))
        end
    end

    self.Root.Shop.Container.CanvasSize = UDim2.new(0, 0, 2, newSize)

    self.Root.Shop.Visible = true
    self.Root.Inventory.Visible = false

    self.ShopCleaner:Add(self.Root.Shop.BackButton.Activated:Connect(function()
        self.Root.Shop.Visible = false
        self.Root.Inventory.Visible = true
    end))
end

function InventoryMenu:CleanShop()
    for _, item in pairs(self.Root.Shop.Container:GetChildren()) do
        if not item:IsA("UIListLayout") then
            item:Destroy()
        end
    end

    self.ShopCleaner:Clean()
    self.ShopCleaner = Trove.new()
end

function InventoryMenu:Destroy()
    self.Cleaner:Clean()
    print("cleaned inventory menu")
end

bluejay.create_component(InventoryMenu)

return InventoryMenu