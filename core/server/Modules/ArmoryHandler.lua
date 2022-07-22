local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local Courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Courier"))
local GunEngine = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("GunEngine"))
local WeaponStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))
local SkillStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("SkillStats"))
local GadgetStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("GadgetStats"))
local GenericClassHandler = require(script.Parent.GenericClassHandler)

local function getItemStats(itemKey: string, itemName: string)
    if itemKey == "Gadget" then
        return GadgetStats[itemName]
    elseif itemKey == "Skill" then
        return SkillStats[itemName]
    else
        return WeaponStats[itemName]
    end
end

local ArmoryHandler = {}

function ArmoryHandler:Start()
    -- equip here can be true to equip, and false to unequip, like with running only one primary
    -- on an equip request, the unequip code will always run unless the player does not have a weapon
    Courier:Listen("RequestChange"):Connect(function(player: Player, itemType: string, itemName: string, equip: boolean)
        local serverInventory = tcs.get_component(player, "ServerInventory")
        local points = player:GetAttribute("Points") or 0
        local itemStats = getItemStats(itemName)

        if points < itemStats.Cost then return end -- how did they even equip it???
        
        local currentClass = player:GetAttribute("CurrentClass")
        if currentClass ~= nil then
            local inClass = GenericClassHandler:IsItemInClass(currentClass, itemType, itemName)
            if not inClass then return end
        end

        if equip then
            serverInventory:UnequipItem(itemType)
            serverInventory:SetItem(itemType, itemName)
        else
            serverInventory:UnequipItem(itemType)
        end
    end)

    Courier:Listen("RequestSkin"):Connect(function(player: Player, itemName: string, skinName: string)

    end)
end

return ArmoryHandler

