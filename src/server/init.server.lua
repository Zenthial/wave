-- should be an overarching setup module
-- after the tech demo, this probably won't need to be touched

--Shared
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared", 5)
local Util = Shared:WaitForChild("Util", 5)

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local PLAYER_TAG = "Player"

------------------------------------------------------------------------
--Setup

local function playerAdded(player: Player)
    CollectionService:AddTag(player, PLAYER_TAG)

    local function characterAdded(character) 
        CollectionService:AddTag(character, "Sprint")
        CollectionService:AddTag(character, "Animation")
    end
    if (player.Character) then
        characterAdded(player.Character)
    end
    player.CharacterAdded:Connect(characterAdded)
end

for _,player in pairs(game.Players:GetPlayers()) do
    playerAdded(player)
end

Players.PlayerAdded:Connect(playerAdded)

local modules = {}

for _, module in pairs(script:GetDescendants()) do
    if module:IsA("ModuleScript") then
        local m = require(module)
        modules[module.Name] = m
        if m["Start"] ~= nil then
            task.spawn(function()
                m:Start()
            end)
        end
    end
end