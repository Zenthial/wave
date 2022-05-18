local EffectEnableRemote = Instance.new("RemoteEvent")
EffectEnableRemote.Name = "EffectEnableRemote"
EffectEnableRemote.Parent = game.ReplicatedStorage

local MaterialChangeRemote = Instance.new("RemoteEvent")
MaterialChangeRemote.Name = "MaterialChangeRemote"
MaterialChangeRemote.Parent = game.ReplicatedStorage

local EffectService = {}

function EffectService:Start()
    EffectEnableRemote.OnServerEvent:Connect(function(player: Player, object: Model, bool: boolean)
        if player.Character then
            if player.Character:IsAncestorOf(object) then
                object.Enabled = bool
            end
        end
    end)

    MaterialChangeRemote.OnServerEvent:Connect(function(player: Player, object: Model, material: Enum.Material)
        if player.Character then
            if player.Character:IsAncestorOf(object) then
                object.Material = material
            end
        end
    end)
end

return EffectService