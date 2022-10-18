local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local Courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))
local ArenaItems = require(ReplicatedStorage:WaitForChild("ArenaShared"):WaitForChild("Configurations"):WaitForChild("ArenaItems"))

local Player = Players.LocalPlayer

local function comma_value(n: number) -- credit http://richard.warburton.it
	local left, num, right = string.match(n, '^([^%d]*%d)(%d*)(.-)$')
	return left .. (num:reverse():gsub('(%d%d%d)', '%1,'):reverse()) .. right
end

local function makeItem(name: string, cost: number)
    local item = Instance.new("Frame")
    item.Name = "Item"
    item.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    item.BackgroundTransparency = 1
    item.BorderSizePixel = 0
    item.LayoutOrder = cost
    item.Size = UDim2.fromScale(1, 0.075)

    local textButton = Instance.new("TextButton")
    textButton.Name = "TextButton"
    textButton.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
    textButton.Text = string.format("%s - %dC", name, cost)
    textButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    textButton.TextScaled = true
    textButton.TextSize = 14
    textButton.TextWrapped = true
    textButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    textButton.BorderSizePixel = 0
    textButton.Size = UDim2.fromScale(1, 1)
    textButton.Parent = item

    return item
end

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type ArenaArmoryUI_T = {
    __index: ArenaArmoryUI_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local ArenaArmoryUI: ArenaArmoryUI_T = {}
ArenaArmoryUI.__index = ArenaArmoryUI
ArenaArmoryUI.Name = "ArenaArmoryUI"
ArenaArmoryUI.Tag = "ArenaArmoryUI"
ArenaArmoryUI.Ancestor = game

function ArenaArmoryUI.new(root: any)
    return setmetatable({
        Root = root,
    }, ArenaArmoryUI)
end

function ArenaArmoryUI:Start()
    self.Root.Credits.Amount.Text = comma_value(Player:GetAttribute("Credits"))
    self.Cleaner:Add(Player:GetAttributeChangedSignal("Credits"):Connect(function()
        self.Root.Credits.Amount.Text = comma_value(Player:GetAttribute("Credits"))
    end))

    self.Cleaner:Add(Player:GetAttributeChangedSignal("InArenaArmory"):Connect(function()
        self.Root.Visible = Player:GetAttribute("InArenaArmory")
    end))

    self:LoadItems()
end

function ArenaArmoryUI:HookItemButton(itemType: string, itemName: string, itemButton: TextButton)
    self.Cleaner:Add(itemButton.MouseButton1Click:Connect(function()
        Courier:Send("AttemptPurchase", itemType, itemName)
    end))
end

function ArenaArmoryUI:LoadItems()
    for itemType, items in pairs(ArenaItems) do
        if itemType == "Misc" then continue end
        local itemContainer = self.Root.ItemContainer[itemType]
        for itemName, itemCost in pairs(items) do
            local itemFrame = makeItem(itemName, itemCost)
            self:HookItemButton(itemType, itemName, itemFrame.TextButton)
            itemFrame.Parent = itemContainer
        end
    end
end

function ArenaArmoryUI:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(ArenaArmoryUI)

return ArenaArmoryUI