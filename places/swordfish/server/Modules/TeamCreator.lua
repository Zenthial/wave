local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local TeamsConfiguration = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations")):WaitForChild("Teams")

local TeamCreator = {}

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

        table.insert(playerJoinFunctions, team.Function)
    end

    Players.PlayerAdded:Connect(function(player)
        for _, func in ipairs(playerJoinFunctions) do
            if func(player) then
                                
            end
        end
    end)
end

return TeamCreator