local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))

local EffectService = {}

function EffectService:Start()
    Courier:Listen("EffectEnable"):Connect(function(player: Player, object: Model, bool: boolean)
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
end

return EffectService