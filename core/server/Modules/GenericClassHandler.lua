local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local Courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))

local GenericClassHandler = {
    PlayersPoints = {},
    Classes = {}
}

local function convertNumberToItemType(number)
    if number == 1 then
        return "Primaries"
    elseif number == 2 then
        return "Secondaries"
    elseif number == 3 then
        return "Gadgets"
    elseif number == 4 then
        return "Skills"
    end
end

function GenericClassHandler:Start()
    Courier:ListenFunction("GetClassItems", function(player: Player, itemType: number)
        return self:GetClassItems(player, convertNumberToItemType(itemType))
    end)

    Courier:ListenFunction("GetClasses", function()
        return self.Classes
    end)

    Courier:ListenFunction("CanJoin", function(player: Player, className: string)
        return self:CanJoin(className)
    end)

    Courier:ListenFunction("RequestChangeClass", function(player: Player, className: string)
        if self:CanJoin(className) then
            self:ChangeClass(player, className, self.Classes[className])
            return true
        end

        return false
    end)
end

function GenericClassHandler:RegisterClass(className, classInfo)
    if classInfo.PlayerLimit == nil then
        classInfo.PlayerLimit = 999
    end

    classInfo.MaxPlayers = classInfo.PlayerLimit
    classInfo.NumPlayers = 0

    self.Classes[className] = classInfo
end

function GenericClassHandler:CanJoin(className: string)
    return self.Classes[className].NumPlayers < self.Classes[className].MaxPlayers
end

function GenericClassHandler:NumClasses()
    return #self.Classes
end

function GenericClassHandler:IsItemInClass(className: string, itemType: string, itemName: string)
    return table.find(self.Classes[className][itemType], itemName) ~= nil
end

function GenericClassHandler:ChangeClass(player: Player, newClass: string, classInfo)
    local serverInventory = tcs.get_component(player, "ServerInventory")

    local defaultPrimary = classInfo.Primaries[1]
    local defaultSecondary = classInfo.Secondaries[1]

    serverInventory:UnequipItem("Primary", player:GetAttribute("EquippedPrimary"))
    serverInventory:SetItem("Primary", defaultPrimary)
    serverInventory:UnequipItem("Secondary", player:GetAttribute("EquippedSecondary"))
    serverInventory:SetItem("Secondary", defaultSecondary)
    serverInventory:UnequipItem("Gadget", player:GetAttribute("EquippedGadget"))
    serverInventory:UnequipItem("Skill", player:GetAttribute("EquippedSKill"))

    player:SetAttribute("CurrentClass", newClass)
    local currentPoints = player:GetAttribute("Points")
    self.PlayersPoints[player.Name][newClass] = currentPoints

    local classPoints = self.PlayersPoints[player.Name][newClass] or 0
    player:SetAttribute("Points", classPoints)
end

function GenericClassHandler:GetClassItems(player: Player, itemType: string)
    local currentClass = player:GetAttribute("CurrentClass")

    return self.Classes[currentClass][itemType]
end

return GenericClassHandler
