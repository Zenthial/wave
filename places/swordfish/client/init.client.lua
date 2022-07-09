local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local Player = game.Players.LocalPlayer

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

local modules = {}

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

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local function inject(component_instance)
	component_instance.Cleaner = Trove.new() -- create a cleaner and throw it into the component_instance
    component_instance.Courier = courier
end

tcs.set_inject_function(inject)

repeat
    task.wait()
until Player:GetAttribute("DataLoaded") == true

Recurse(script:WaitForChild("Components"), LoadComponent)
Recurse(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Components"), LoadComponent)

-- tcs.start().sync()

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