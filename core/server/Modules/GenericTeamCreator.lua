-- Designed to replace the specific team creators
-- Will get the placeid, call the placeOptions function, and read the teams from there
-- Should allow us to always have two teams regardless of the place
-- If you need more teams, set it up, by place id, in Teams.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

local PlaceOptions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("PlaceOptions"))

local function shuffleArray(array)
    local counter = #array
    while counter > 1 do
        local index = math.random(counter)
        array[index], array[counter] = array[counter], array[index]
        counter = counter - 1
    end
    return array
end

local GenericTeamCreator = {}

local function playerJoin(player: Player, playerJoinFunctions)
    playerJoinFunctions = shuffleArray(playerJoinFunctions)
    for teamObject: Team, func in pairs(playerJoinFunctions) do
        if --[[teamObject.AutoAssignable == false and ]]func(player) then
            player.Team = teamObject
        end
    end
end

function GenericTeamCreator:Start()
    local placeId = game.PlaceId

    local teamsStats = PlaceOptions(placeId).Teams

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

return GenericTeamCreator