
local Players = game.Players
local Teams = game:GetService("Teams")

local StrikeTeamNames = require(script.StrikeTeamNames)

----------------------------------------------------------------------------------------------------

local function playerAdded(player)
    local randomStrikeTeam = math.random(1, #StrikeTeamNames)

    --player:SetAttribute("StrikeTeam", StrikeTeamNames[randomStrikeTeam])
    player:SetAttribute("StrikeTeam", "Alpha")
end

----------------------------------------------------------------------------------------------------

local StrikeTeamSystem = {}

function StrikeTeamSystem:Start()

    for _, player in pairs(Players:GetPlayers()) do
        playerAdded(player)
    end
    Players.PlayerAdded:Connect(playerAdded)
end

return StrikeTeamSystem