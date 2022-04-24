local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Player = game.Players.LocalPlayer

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

local modules = {}

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

if (not game:IsLoaded()) then
    game.Loaded:Wait()
end

game:GetService("CollectionService"):AddTag(game:GetService("Workspace"), "Workspace")

Recurse(script:WaitForChild("Components"), LoadComponent)
Recurse(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Components"), LoadComponent)

for _, module in pairs(script.Modules:GetChildren()) do
    if module:IsA("ModuleScript") then
        local m = require(module)
        modules[module.Name] = m
        if typeof(m) == "table" then
            if m["Start"] ~= nil and typeof(m["Start"]) == "function" then
                task.spawn(function()
                    m:Start()
                end)
            end
        end
    end
end

local function characterAdded(character)
    if not CollectionService:HasTag(character, "Character") then
        CollectionService:AddTag(character, "Character")
    end
end

if (Player.Character) then
    characterAdded(Player.Character)
end

CollectionService:AddTag(Player, "Inventory")
CollectionService:AddTag(Player, "Movement")
CollectionService:AddTag(Player, "AnimationHandler")
CollectionService:AddTag(Player, "AnimationState")
Player.CharacterAdded:Connect(characterAdded)

for attribute, value in pairs(modules["DefaultLocalPlayerAttributes"]) do
    Player:SetAttribute(attribute, value)
end

local PlayerLoaded = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PlayerLoaded") :: RemoteEvent
PlayerLoaded:FireServer()