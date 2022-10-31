local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local ArenaPlayerAttributes = require(script.Modules.ArenaPlayerAttributes)

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

CollectionService:AddTag(game:GetService("Workspace"), "Workspace")

local function inject(component_instance)
	component_instance.Cleaner = Trove.new() -- create a cleaner and throw it into the component_instance
    component_instance.Courier = courier
end

tcs.set_inject_function(inject)

Recurse(script:WaitForChild("Components"), LoadComponent)
Recurse(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Components"), LoadComponent)

-- tcs.start().sync()

function LoadModule(module: ModuleScript)
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

for _, module in pairs(script.Modules:GetChildren()) do
   LoadModule(module)
end

script.Modules.ChildAdded:Connect(LoadModule)

Players.PlayerAdded:Connect(function(player: Player)
    for attributeName, attributeValue in ArenaPlayerAttributes do
        player:SetAttribute(attributeName, attributeValue)
    end
end)
