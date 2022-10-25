local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local Courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))
local ArenaItems = require(ReplicatedStorage:WaitForChild("ArenaShared"):WaitForChild("Configurations"):WaitForChild("ArenaItems"))

local function mapItemType(itemType: string)
    if itemType == "Primaries" then
        return "Primary"
    elseif itemType == "Secondaries" then
        return "Secondary"
    else
        return itemType
    end
end

local ArenaShop = {}

function ArenaShop:Start()
    Courier:Listen("AttemptPurchase"):Connect(function(player: Player, itemType: string, item: string)
        local playerComponent = tcs.get_component(player, "ArenaPlayer")
        local itemPrice = ArenaItems[itemType][item]

        if itemPrice ~= nil then
            if playerComponent:HasItem(mapItemType(itemType), item) then
                playerComponent:RemoveItem(mapItemType(itemType), item, itemPrice)
            else
                if playerComponent.Credits >= itemPrice then
                    playerComponent:SetItem(mapItemType(itemType), item, itemPrice)
                end
            end
        end
    end)
end

return ArenaShop