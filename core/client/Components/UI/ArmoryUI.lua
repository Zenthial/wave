local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))
local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local WeaponStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Weapons = Assets:WaitForChild("Weapons")
local UI = Assets:WaitForChild("UI")
local TypeButton = UI:WaitForChild("TypeButton") :: Frame & {
    Button: TextButton,
    TextLabel: TextLabel
}

type Item = Frame & {
    Button: TextButton,
    ViewportFrame: ViewportFrame & {
        ItemName: TextLabel
    }
}

local ArmoryItem = UI:WaitForChild("ArmoryItem") :: Item

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
        WeaponTypes: Frame
    },

    Cleaner: Cleaner_T
}

local ArmoryUI: ArmoryUI_T = {}
ArmoryUI.__index = ArmoryUI
ArmoryUI.Name = "ArmoryUI"
ArmoryUI.Tag = "ArmoryUI"
ArmoryUI.Ancestor = game

function ArmoryUI.new(root: any)
    return setmetatable({
        Root = root,

        Events = {
            AttemptEquip = Signal.new(),
            AttemptPurchase = Signal.new(),
        }
    }, ArmoryUI)
end

function ArmoryUI:CreateCategory(categoryName: string)
    local categoryFrame = TypeButton:Clone()
    categoryFrame.Name = categoryName
    categoryFrame.TextLabel.Text = categoryName

    local categoryList = ArmoryList:Clone()
    categoryList.Name = categoryName.."List"
    
    return {Frame = categoryFrame, List = categoryList}
end

function ArmoryUI:CreateItem(itemName: string, itemInfo, list: List)
    local item = ArmoryItem:Clone()
    item.ViewportFrame.ItemName = itemName

    local modelFolder = Weapons[itemName]
    if modelFolder ~= nil then
        if modelFolder:FindFirstChild("Model") then
            local model = modelFolder.Model:Clone()
            -- stuck here trying to think about making all the models fit perfectly
        elseif modelFolder:FindFirstChild("Projectile") then

        end
    end

    item.Parent = list.Container
end

function ArmoryUI:Populate(slot: number)
    for _, thing in pairs(self.Root.WeaponTypes:GetChildren()) do if not thing:IsA("UIListLayout") then thing:Destroy() end end

    local categories: {[string]: {Frame: Item, List: List}} = {}
    for weaponName, weaponInfo in pairs(WeaponStats) do
        if categories[weaponInfo.Category] == nil then
            categories[weaponInfo.Category] = self:CreateCategory(weaponInfo.Category)
        end

        self:CreateItem(weaponName, weaponInfo, categories[weaponInfo.Category].List)
    end
end

function ArmoryUI:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(ArmoryUI)

return ArmoryUI