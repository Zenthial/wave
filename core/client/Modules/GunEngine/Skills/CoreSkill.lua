local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local LocalPlayer = Players.LocalPlayer

local SkillFunctions = script.Parent.Functions
local Functions = {}
for _, functionModule in pairs(SkillFunctions:GetChildren()) do
    Functions[functionModule.Name] = require(functionModule)
end

local CoreSkill = {}
CoreSkill.__index = CoreSkill

function CoreSkill.new(skillStats, model)
    local self = setmetatable({
        CurrentEnergy = 100;
        MaxEnergy = 100;
        MinEnergy = 0;

        Stats = skillStats;
        Model = model;

        Movement = tcs.get_component(LocalPlayer, "Movement") --[[:await()]];
    }, CoreSkill)
    return self
end

function CoreSkill:Equip()
    local func = Functions[self.Stats.name]
    print(Functions, self.Stats.name, func)
    if func == nil then error("No skill function for " .. self.Stats.name) end
    if LocalPlayer.Character ~= nil and LocalPlayer.Character.Humanoid ~= nil then
        func(self, true, LocalPlayer.Character, self.Movement, self.Model)
    end
end

function CoreSkill:DepleteEnergy(depletionAmount: number)
    self.CurrentEnergy -= depletionAmount
end

function CoreSkill:Destroy()
    
end

return CoreSkill