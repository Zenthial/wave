local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local Courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))

local CraftingItems = require(ReplicatedStorage:WaitForChild("ArenaShared"):WaitForChild("Configurations"):WaitForChild("ArenaCraftItems"))
local CraftingRequirements = require(ReplicatedStorage:WaitForChild("ArenaShared"):WaitForChild("Configurations"):WaitForChild("ArenaCraftingRequirements"))
local ArenaItems = require(ReplicatedStorage:WaitForChild("ArenaShared"):WaitForChild("Configurations"):WaitForChild("ArenaItems"))

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type ArenaPlayer_T = {
    __index: ArenaPlayer_T,
    Name: string,
    Tag: string,
    Root: Player,
    Credits: number,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local ArenaPlayer: ArenaPlayer_T = {}
ArenaPlayer.__index = ArenaPlayer
ArenaPlayer.Name = "ArenaPlayer"
ArenaPlayer.Tag = "Player"
ArenaPlayer.Ancestor = game

function ArenaPlayer.new(root: any)
    return setmetatable({
        Root = root,

        CraftingItems = {},
        Credits = 0,
        Items = {
            Primary = "",
            Secondary = "",
            Gadgets = "",
            Skills = "",
            Misc = {}
        }
    }, ArenaPlayer)
end

function ArenaPlayer:Start()
    if self.Root:GetAttribute("Loaded") == true then
        self.Root:SetAttribute("InRound", true)
    else
        self.Cleaner:Add(self.Root:GetAttributeChangedSignal("Loaded"):Connect(function()
            self.Root:SetAttribute("InRound", self.Root:GetAttribute("Loaded"))
        end))
    end

    local serverInventoryComponent = tcs.get_component(self.Root, "ServerInventory")
    self.Cleaner:Add(Courier:Listen(self.Root.Name.."CraftingItemPickup"):Connect(function(itemName: string)
        if table.find(CraftingItems, itemName) then
            table.insert(self.CraftingItems, itemName)
        end
    end))

    self.Cleaner:Add(Courier:Listen(self.Root.Name.."CraftingAttempt"):Connect(function(craftableItem: string)
        local requirements = CraftingRequirements[craftableItem]

        local indexes = {}
        for _, requirement in requirements do
            local index = table.find(self.CraftingItems, requirement)
            if index == nil then
                Courier:Send("CraftingAttempt", false)
                break
            else
                table.insert(indexes, index)
            end
        end

        if #indexes == #requirements then
            for _, index in indexes do
                table.remove(self.CraftingItems, index)
            end

            serverInventoryComponent:SetItem("Skill", craftableItem)
            Courier:Send("CraftingAttempt", true)
        end
    end))

    self:ResetCredits()
    self:ResetInventory()
end

function ArenaPlayer:ResetInventory()
    self.Items = {
        Primary = "W17",
        Secondary = "Y14",
        Gadgets = "",
        Skills = "",
        Misc = {}
    }

    self:LoadInventory()
end

function ArenaPlayer:LoadInventory()
    local serverInventoryComponent = tcs.get_component(self.Root, "ServerInventory")
    serverInventoryComponent:LoadServerInventory(self.Items)
end

local function mapItemType(itemType: string)
    if itemType == "Primary" then
        return "Primaries"
    elseif itemType == "Secondary" then
        return "Secondaries"
    else
        return itemType
    end
end

function ArenaPlayer:SetItem(itemType, item, itemPrice)
    if itemType == "Misc" then
        table.insert(self.Items[itemType], item)
    else
        if self.Items[itemType] ~= "" then
            self:RemoveItem(itemType, self.Items[itemType], ArenaItems[mapItemType(itemType)][self.Items[itemType]])
        end
        self.Items[itemType] = item
    end
    self.Credits = math.clamp(self.Credits - itemPrice, 0, self.Credits)
    self.Root:SetAttribute("Credits", self.Credits)
    self:LoadInventory()
end

function ArenaPlayer:RemoveItem(itemType, item, itemPrice)
    if itemType == "Misc" then
        table.remove(self.Items[itemType], table.find(self.Items[itemType], item))
    else
        self.Items[itemType] = ""
    end
    self.Credits += itemPrice
    self.Root:SetAttribute("Credits", self.Credits)
    self:LoadInventory()
end

function ArenaPlayer:HasItem(itemType, itemName)
    if self.Items[itemType] ~= "" then return self.Items[itemType] == itemName else return false end    
end

function ArenaPlayer:ResetCredits()
    self.Credits = 2000
    self.Root:SetAttribute("Credits", self.Credits)
end

function ArenaPlayer:AwardCredits(credits: number)
    self.Credits += credits
    self.Root:SetAttribute("Credits", self.Credits)
end

function ArenaPlayer:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(ArenaPlayer)

return ArenaPlayer