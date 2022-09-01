local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts

local ClientCom = require(StarterPlayerScripts.Client.Modules.ClientComm)

local EffectEnableRemote = ReplicatedStorage:WaitForChild("EffectEnableRemote") :: RemoteEvent
local LocalPlayer = Players.LocalPlayer
local comm = ClientCom.GetClientComm()

local attemptAoE = comm:GetFunction("AoERadius")

return function(self, bool, character, skillModel)
    if bool then
        self:DepleteEnergy(self.Stats.EnergyDeplete)
        LocalPlayer:SetAttribute("LocalSprinting", false)
		LocalPlayer:SetAttribute("LocalCrouching", false)

        EffectEnableRemote:FireServer(skillModel.Reactor.FieldExplosion, true)
        attemptAoE(skillModel.Reactor, "FIEL-X")
        skillModel.Reactor.FieldExplosionSound:Play()

        LocalPlayer:SetAttribute("FielxActive", true)
		
		task.wait(0.5)
		
        LocalPlayer:SetAttribute("FielxActive", false)
        EffectEnableRemote:FireServer(skillModel.Reactor.FieldExplosion, false)
		
		self:RegenEnergy()
    end
end