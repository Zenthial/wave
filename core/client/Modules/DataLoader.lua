local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local Player = Players.LocalPlayer

local DataLoader = {}

function DataLoader:Start()
    local OptionSyncRemote = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("OptionSyncRemote") :: RemoteEvent

    -- this cleaner is never actually cleaned, so its technically not necessary.
    -- its just created to keep track of potential memory leaks in case we decide to care about them
    local dataCleaner = Trove.new()

    -- this entire section of code is just looking for local option changes and syncing them to the server
    for attributeName, attributeValue in pairs(Player:GetAttributes()) do
        if string.find(attributeName, "Option") ~= nil then
            local oldAttributeValue = attributeValue
            dataCleaner:Add(Player:GetAttributeChangedSignal(attributeName):Connect(function()
                -- if we made a local change to an option, sync that to the server
                local newVal = Player:GetAttribute(attributeName)
                if newVal ~= oldAttributeValue then
                    oldAttributeValue = newVal
                    OptionSyncRemote:FireServer(attributeName, newVal)
                end
            end))
        end
    end
end

return DataLoader