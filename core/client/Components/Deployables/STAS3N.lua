local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local WeaponStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))

local LocalPlayer = Players.LocalPlayer

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type STAS3N_T = {
    __index: STAS3N_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T
}

local STAS3N: STAS3N_T = {}
STAS3N.__index = STAS3N
STAS3N.Name = "STAS3N"
STAS3N.Tag = "STAS3N"
STAS3N.Ancestor = game

function STAS3N.new(root: any)
    print("creating component")
    return setmetatable({
        Root = root,
        Active = false,
    }, STAS3N)
end

function STAS3N:Start()
    self.Active = true
    local gadgetStats = WeaponStats["STAS3N"]
    local stream = ReplicatedStorage:WaitForChild(self.Root.Name.."Stream") :: RemoteEvent

    local start, _ = string.find(self.Root.Name, "STAS3N")
    local playerName = self.Root.Name:sub(1, start - 1)
    local localPlayer = Players:FindFirstChild(playerName) :: Player

    if localPlayer ~= LocalPlayer then
        return
    end

	local reactor = self.Root.Reactor
	local origin = reactor.Position
	
	while task.wait(0.25) and self.Active do
        local effect = false

		for _, player in pairs(Players:GetPlayers()) do
            local character = player.Character
            if character == nil then continue end
            
			local hrp = character:FindFirstChild("HumanoidRootPart")
			if hrp and player.TeamColor == localPlayer.TeamColor then
                local totalHealth = player:GetAttribute("Health") + player:GetAttribute("Shields")
                local maxHealth = player:GetAttribute("MaxHealth") + player:GetAttribute("MaxShields")
                local dist = (origin - hrp.Position).magnitude

                if dist <= gadgetStats.BlastRadius and totalHealth > 0 and totalHealth < maxHealth then
                    effect = true
                    
                    stream:FireServer("Heal", player, gadgetStats.Heal)
                end
            end
		end
				
		if effect then
            stream:FireServer("Color", reactor, "Lime green")
            stream:FireServer("Effect", reactor.ParticleEmitter1, true)
            stream:FireServer("Effect", reactor.ParticleEmitter2, true)
        else
            stream:FireServer("Color", reactor, "Black")
            stream:FireServer("Effect", reactor.ParticleEmitter1, false)
            stream:FireServer("Effect", reactor.ParticleEmitter2, false)
        end
    end
end

function STAS3N:Destroy()
    self.Active = false
    self.Cleaner:Clean()
end

tcs.create_component(STAS3N)

return STAS3N