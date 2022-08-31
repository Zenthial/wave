local Player = game.Players.LocalPlayer

local Shared = game.ReplicatedStorage:WaitForChild("Shared")
local Mouse = require(Shared:WaitForChild("util", 5):WaitForChild("Input", 5)).Mouse.new()

local function chargeWait(waitTime: number): boolean
    local retVal = true
    local con
   
    task.spawn(function()
        con = Mouse.LeftUp:Connect(function()
            retVal = false
            Player:SetAttribute("Charging", false)
            con:Disconnect()
        end)
    end)
    
    task.wait(waitTime)

    if retVal == false then
        return false
    else
        con:Disconnect()
        return Mouse:IsLeftDown()
    end
end

return chargeWait