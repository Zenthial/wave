local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local RayParams = RaycastParams.new()
RayParams.FilterDescendantsInstances = {Character, CollectionService:GetTagged("Ignore")}
RayParams.FilterType = Enum.RaycastFilterType.Blacklist
RayParams.IgnoreWater = false

return function(origin: Vector3, radius: number)
    local playersNear = {}

    for _, player: Player in pairs(Players:GetPlayers()) do
        if player == Players.LocalPlayer then continue end
        local character = player.Character
        local hrp = character.HumanoidRootPart

        local result = workspace:Raycast(origin, (hrp.Position - origin).Unit * radius, RayParams)

        if result and result.Instance and result.Instance:IsDescendantOf(character) then
            table.insert(playersNear, player)
        end
    end

    return playersNear
end