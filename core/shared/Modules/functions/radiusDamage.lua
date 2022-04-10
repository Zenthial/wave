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
            if canTK then
                if not player.TeamColor ~= sourceTeam then return end
            end
            DealSelfDamage(stats.CalculateDamage(stats.MaxDamage, dist))
        end
    end
elseif RunService:IsServer() then
    return function()
        
    end
end