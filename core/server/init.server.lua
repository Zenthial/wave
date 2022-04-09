-- should be an overarching setup module
-- after the tech demo, this probably won't need to be touched

--Shared
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

------------------------------------------------------------------------
--Setup

for _, module in pairs(script.Modules:GetChildren()) do
    task.spawn(function()
        if module:IsA("ModuleScript") then
            local m = require(module)
            if typeof(m) == "table" then
                if m["Start"] ~= nil then
                    m:Start()
                end
            end
        end
    end)
end

local function LoadComponent(Item)
    if (not Item:IsA("ModuleScript")) then
        return
    end

    if (Item.Name:sub(1, 1) == "_") then
        -- Skip scripts prefixed with this
        return
    end

    require(Item)
end

local function Recurse(Root, Operator)
    for _, Item in pairs(Root:GetChildren()) do
        Operator(Item)
        Recurse(Item, Operator)
    end
end

game:GetService("CollectionService"):AddTag(game:GetService("Workspace"), "Workspace")

Recurse(script:WaitForChild("Components"), LoadComponent)
Recurse(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Components"), LoadComponent)

local function playerAdded(player: Player)
    CollectionService:AddTag(player, "Player")
    CollectionService:AddTag(player, "Health")

    local function characterAdded(character) 
        CollectionService:AddTag(character, "Character")
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