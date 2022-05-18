local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts
local Players = game:GetService("Players")

if RunService:IsClient() then
    local ClientComm = require(StarterPlayerScripts.Client.Modules.ClientComm)
    local Comm = ClientComm.GetClientComm()
    DealSelfDamage = Comm:GetFunction("DealSelfDamage")

    return function(stats, part: Part, sourceTeam: BrickColor, canTK: boolean)
        local origin = part.Position
        local radius = if stats.NadeRadius > 0 then stats.NadeRadius else part.Size / 2

        local player = Players.LocalPlayer
        local character = player.Character
        local hrp = character.HumanoidRootPart

        local dist = (origin - hrp.Position).Magnitude
        local ignore = CollectionService:GetTagged("Ignore")
            
        local NewRay = Ray.new(origin + Vector3.new(0, 3, 0), (hrp.CFrame.Position - (origin + Vector3.new(0, 3, 0))).Unit * radius)
        local hit, position = workspace:FindPartOnRayWithIgnoreList(NewRay, ignore)
        if hit and hit:IsDescendantOf(character) then
            if not canTK then
                if player.TeamColor == sourceTeam then return end
            end
            DealSelfDamage(stats.CalculateDamage(stats.MaxDamage, dist))
        end
    end
elseif RunService:IsServer() then
    return function(stats, part: Part, sourcePlayer: Player, canTK: boolean)
        local origin = part.Position
        local radius

        if stats.NadeRadius and stats.NadeRadius > 0 then 
            radius = stats.NadeRadius
        elseif stats.BlastRadius and stats.BlastRadius > 0 then
            radius = stats.BlastRadius
        else
            radius = part.Size / 2
        end

        local playersNear = {}
        local maxDamage = stats.MaxDamage or stats.Damage
        for _, player: Player in pairs(Players:GetPlayers()) do
            local character = player.Character
            local hrp = character.HumanoidRootPart

            local dist = (origin - hrp.Position).Magnitude
            local ignore = CollectionService:GetTagged("Ignore")
                
            local NewRay = Ray.new(origin + Vector3.new(0, 3, 0), (hrp.CFrame.Position - (origin + Vector3.new(0, 3, 0))).Unit * radius)
            local hit, _ = workspace:FindPartOnRayWithIgnoreList(NewRay, ignore)

            if hit and hit:IsDescendantOf(character) then
                if stats.Action == "Heal" then
                    if player.TeamColor == sourcePlayer.TeamColor and player ~= sourcePlayer then
                        print(player)
                        playersNear[player] = stats.CalculateDamage(maxDamage, dist)
                    end
                else
                    if not canTK then
                        if player.TeamColor == sourcePlayer.TeamColor then continue end
                    end
                    playersNear[player] = stats.CalculateDamage(maxDamage, dist)
                end
            end
        end

        return playersNear
    end
end