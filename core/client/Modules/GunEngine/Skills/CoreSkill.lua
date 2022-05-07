local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))

local LocalPlayer = Players.LocalPlayer

local ENERGY_WAIT_TIME = 0.2

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

        Regening = false,

        Stats = skillStats;
        Model = model;

        Movement = tcs.get_component(LocalPlayer, "Movement") --[[:await()]];

        Events = {
            EnergyChanged = Signal.new(),
            FunctionStarted = Signal.new(),
            -- FunctionEnded = Signal.new(),
        }
    }, CoreSkill)
    return self
end

function CoreSkill:Equip()
    local func = Functions[self.Stats.name]
    print(Functions, self.Stats.name, func)
    if func == nil then error("No skill function for " .. self.Stats.name) end
    if LocalPlayer.Character ~= nil and LocalPlayer.Character.Humanoid ~= nil then
        self.Events.FunctionStarted:Fire()
        func(self, true, LocalPlayer.Character, self.Movement, self.Model)
        -- self.Events.FunctionEnded:Fire()
    end
end

function CoreSkill:DepleteEnergy(depletionAmount: number)
    self.CurrentEnergy = math.clamp(self.MinEnergy, self.CurrentEnergy - depletionAmount, self.MaxEnergy)
    self.Events.EnergyChanged:Fire(self.CurrentEnergy)
end

function CoreSkill:RegenEnergy()
    if not self.Regening then
		self.Regening = true
		
		while self.CurrentEnergy < 100 and self.Regening do
			self:DepleteEnergy(-self.Stats.EnergyRegen)
			task.wait(ENERGY_WAIT_TIME)
		end
		
		self.Regening = false
	end
end

function CoreSkill:Destroy()
    self.Regening = false
end

return CoreSkill