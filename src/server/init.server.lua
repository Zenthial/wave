-- should be an overarching setup module
-- after the tech demo, this probably won't need to be touched

--Shared
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local Components = script.Components
local CharacterComponents = Components.Character:GetDescendants()

local PLAYER_TAGS = {
    "Player",
    "Health",
    "Nametag"
}

------------------------------------------------------------------------
--Setup

local function playerAdded(player: Player)
    for _, tag in pairs(PLAYER_TAGS) do
        CollectionService:AddTag(player, tag)
    end

    local function characterAdded(character) 
        for _, component in pairs(CharacterComponents) do
            CollectionService:AddTag(character, component.Name)
        end
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
    task.spawn(function()
        if module:IsA("ModuleScript") then
            local m = require(module)
            modules[module.Name] = m
            if typeof(m) == "table" then
                if m["Start"] ~= nil then
                    task.spawn(function()
                        m:Start()
                    end)
                end
            end
        end
    end)
end
