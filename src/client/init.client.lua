local CollectionService = game:GetService("CollectionService")
local Player = game.Players.LocalPlayer

local function characterAdded(character) 
    CollectionService:AddTag(character, "BodyGyro")
end

if (Player.Character) then
    characterAdded(Player.Character)
end

Player.CharacterAdded:Connect(characterAdded)

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

local comm = modules["ClientComm"]
repeat
    comm = modules["ClientComm"]
until comm ~= nil
local ClientComm = comm.GetClientComm()

ClientComm:GetSignal("PlayedLoaded"):Fire()

print("done")