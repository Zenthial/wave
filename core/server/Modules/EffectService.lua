local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Particles = Assets:WaitForChild("Particles")
local PoisonParticles = Particles:WaitForChild("PoisonParticles")

local BeamHeal = PoisonParticles:WaitForChild("BeamHeal") :: Beam
local BeamDamage = PoisonParticles:WaitForChild("BeamDamage") :: Beam
local Bits = PoisonParticles:WaitForChild("Bits") :: ParticleEmitter
local Core = PoisonParticles:WaitForChild("Core") :: ParticleEmitter

local EffectService = {}

function EffectService:Start()
    Courier:Listen("EffectEnable"):Connect(function(player: Player, object: ParticleEmitter, bool: boolean)
        if player.Character then
            if player.Character:IsAncestorOf(object) then
                object.Enabled = bool
            end
        end
    end)

    Courier:Listen("MaterialChange"):Connect(function(player: Player, object: Model, material: Enum.Material)
        if player.Character then
            if player.Character:IsAncestorOf(object) then
                object.Material = material
            end
        end
    end)

    Courier:Listen("MakeBeam"):Connect(function(sourcePlayer: Player, beamPlayer: Player)
        if sourcePlayer.Character and beamPlayer.Character then
            local sourcePlayerCharacter = sourcePlayer.Character
            local beamPlayerCharacter = beamPlayer.Character
            local sourcePlayerLeftArm = sourcePlayerCharacter:FindFirstChild("Left Arm")
            local beamPlayerTorso = beamPlayerCharacter:FindFirstChild("Torso")

            if sourcePlayer.TeamColor == beamPlayer.TeamColor then -- this wont run cause pois-n isn't healing currently, but we could have beam healing stuff eventually
                local healBeam = BeamHeal:Clone()
                healBeam.Attachment0 = sourcePlayerLeftArm.LeftGripAttachment
                healBeam.Attachment1 = beamPlayerTorso.BodyFrontAttachment
                healBeam.Name = beamPlayer.Name.."HealBeam"
                healBeam.Parent = sourcePlayerCharacter
            else
                local damageBeam = BeamDamage:Clone()
                damageBeam.Attachment0 = sourcePlayerLeftArm.LeftGripAttachment
                damageBeam.Attachment1 = beamPlayerTorso.BodyFrontAttachment
                damageBeam.Name = beamPlayer.Name.."DamageBeam"
                damageBeam.Parent = sourcePlayerCharacter
            end
        end
    end)

    Courier:Listen("RemoveBeam"):Connect(function(sourcePlayer: Player, beamPlayer: Player)
        if sourcePlayer.Character then
            local sourcePlayerCharacter = sourcePlayer.Character
            local healBeam = sourcePlayerCharacter:FindFirstChild(beamPlayer.Name.."HealBeam")
            local damageBeam = sourcePlayerCharacter:FindFirstChild(beamPlayer.Name.."DamageBeam")

            if healBeam then
                healBeam:Destroy()
            end

            if damageBeam then
                damageBeam:Destroy()
            end
        end
    end)
end

return EffectService