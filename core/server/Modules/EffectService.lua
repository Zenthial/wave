local EffectRemote = Instance.new("RemoteEvent")
EffectRemote.Name = "EffectRemote"
EffectRemote.Parent = game.ReplicatedStorage

local EffectService = {}

function EffectService:Start()
    EffectRemote.OnServerEvent:Connect(function(player: Player, object: Model, bool: boolean)
        if player.Character then
            if player.Character:IsAncestorOf(object) then
                object.Enabled = bool
            end
        end
    end)
end

return EffectService