local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local MainHUD = PlayerGui:WaitForChild("MainHUD")
local Overlay = MainHUD:WaitForChild("Overlay") :: Frame
Overlay.Visible = true

local loadText = Overlay:WaitForChild("LoadText") :: TextLabel
loadText.Text = "INITIALIZING wAVE"

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

local function LoadModule(module: ModuleScript)
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

local function Recurse(Root, Operator)
    for _, Item in pairs(Root:GetChildren()) do
        Operator(Item)
        Recurse(Item, Operator)
    end
end

if not game:IsLoaded() then
    game.Loaded:Wait()
end

CollectionService:AddTag(game:GetService("Workspace"), "Workspace")

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
    LoadModule(module)
end

script.Modules.ChildAdded:Connect(LoadModule)

local function characterAdded(character)
    if not CollectionService:HasTag(character, "Character") then
        CollectionService:AddTag(character, "Character")
    end
end

if Player.Character then
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

-- reset bindable
local resetBindable = Instance.new("BindableEvent")
resetBindable.Event:Connect(function()
    courier:Send("DealSelfDamage", 100)
end)
StarterGui:SetCore("ResetButtonCallback", resetBindable)

local PlayerLoaded = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PlayerLoaded") :: RemoteEvent
PlayerLoaded:FireServer()

loadText.Text = "wAVE INITIALIZED"
loadText.Visible = false
task.wait(0.2)
Overlay.Visible = false