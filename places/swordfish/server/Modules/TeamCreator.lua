local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

local TeamsConfiguration = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("Teams"))

local TeamCreator = {}

local function playerJoin(player: Player, playerJoinFunctions)
    for teamObject: Team, func in pairs(playerJoinFunctions) do
        if func(player) then
            player.Team = teamObject
        end
    end    
end

function TeamCreator:Start()
    local place = "Swordfish"

    local teamsStats = TeamsConfiguration[place]
    assert(teamsStats, "No stats for "..place)

    local playerJoinFunctions = {}

    for _, team in ipairs(teamsStats) do
        local teamObject = Instance.new("Team")
        teamObject.Name = team.Name
        teamObject.TeamColor = team.Color
        teamObject:SetAttribute("Value", team.Value)
        teamObject.AutoAssignable = team.AutoAssignable
        teamObject.Parent = Teams

        playerJoinFunctions[teamObject] = team.Function
    end

    Players.PlayerAdded:Connect(function(player) playerJoin(player, playerJoinFunctions) end)

    for _, player in pairs(Players:GetPlayers()) do
        playerJoin(player, playerJoinFunctions)
    end
end

return TeamCreator