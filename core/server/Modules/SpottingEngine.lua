local ReplicatedStorage = game:GetService("ReplicatedStorage")

local courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))
local GlobalOptions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("GlobalOptions"))

local SpottingEngine = {}

function SpottingEngine:Start()
    courier:Listen("Spot", function(player: Player)
        if player:GetAttribute("Spotted") == false then
            player:SetAttribute("Spotted", true)
            task.delay(GlobalOptions.SpottedDuration, function()
                player:SetAttribute("Spotted", false)
            end)
        end
    end)
end

return SpottingEngine