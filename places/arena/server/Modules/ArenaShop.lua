local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local Courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))
local ArenaItems = require(ReplicatedStorage:WaitForChild("ArenaShared"):WaitForChild("Configurations"):WaitForChild("ArenaItems"))

local ArenaShop = {}

function ArenaShop:Start()
    Courier:Listen("AttemptPurchase"):Connect(function(player: Player, itemType: string, item: string)
        local playerComponent = tcs.get_component(player, "ArenaPlayer")
        local itemPrice = ArenaItems[itemType][item]

        if itemPrice ~= nil and playerComponent.Credits >= itemPrice then
            if playerComponent:HasItem(itemType, item) then
                playerComponent:RemoveItem(itemType, item, itemPrice)
            else
                playerComponent:SetItem(itemType, item, itemPrice)
            end
        end
    end)
end

return ArenaShop