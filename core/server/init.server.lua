-- should be an overarching setup module
-- after the tech demo, this probably won't need to be touched

--Shared
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

------------------------------------------------------------------------
--Setup

local function LoadComponent(Item)
    if not Item:IsA("ModuleScript") then
        return
    end

    if Item.Name:sub(1, 1) == "_" then
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

local function inject(component_instance)
	component_instance.Cleaner = Trove.new() -- create a cleaner and throw it into the component_instance
end

tcs.set_inject_function(inject)

Recurse(script:WaitForChild("Components"), LoadComponent)
Recurse(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Components"), LoadComponent)

-- tcs.start().sync()

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

local function playerAdded(player: Player)
    task.wait(.1) -- this is to avoid double collectionservice firing
    if not CollectionService:HasTag(player, "Player") then
        CollectionService:AddTag(player, "Player")
    end

    if not CollectionService:HasTag(player, "Health") then
        CollectionService:AddTag(player, "Health")
    end

    local function characterAdded(character) 
        CollectionService:AddTag(character, "Character")

        player.CharacterAppearanceLoaded:Wait()
        for _, thing in pairs(character:GetDescendants()) do
            if thing.Name == "Handle" and thing.Parent:IsA("Accessory") then
                CollectionService:AddTag(thing, "Ignore")
            end
        end
    end

    if player.Character then
        characterAdded(player.Character)
    end
    
    player.CharacterAdded:Connect(characterAdded)
end

for _,player in pairs(game.Players:GetPlayers()) do
    task.spawn(playerAdded, player)
end

Players.PlayerAdded:Connect(playerAdded)