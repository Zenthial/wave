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
    local func = Functions[skillStats.Name]
    if func == nil then error("No skill function for " .. skillStats.Name) end

    local self = setmetatable({
        CurrentEnergy = 100;
        MaxEnergy = 100;
        MinEnergy = 0;

        Regening = false,

        Stats = skillStats;
        Model = model;

        SkillFunction = func;

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
    print(LocalPlayer.Character ~= nil and LocalPlayer.Character.Humanoid ~= nil and self.CurrentEnergy >= self.Stats.EnergyMin)
    if LocalPlayer.Character ~= nil and LocalPlayer.Character.Humanoid ~= nil and self.CurrentEnergy >= self.Stats.EnergyMin then
        self.Events.FunctionStarted:Fire()
        print("calling skill function")
        self.SkillFunction(self, true, LocalPlayer.Character, self.Model)
        -- self.Events.FunctionEnded:Fire()
    end
end

function CoreSkill:DepleteEnergy(depletionAmount: number)
    self.CurrentEnergy = math.clamp(self.CurrentEnergy - depletionAmount, self.MinEnergy, self.MaxEnergy)
    
    if self.CurrentEnergy <= self.Stats.EnergyMin then
        if LocalPlayer.Character ~= nil and LocalPlayer.Character.Humanoid ~= nil and self.CurrentEnergy >= self.Stats.EnergyMin then
            self.Regening = false
            self.Events.FunctionStarted:Fire()
            self.SkillFunction(self, false, LocalPlayer.Character, self.Model)
            -- self.Events.FunctionEnded:Fire()
        end
    end
    
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