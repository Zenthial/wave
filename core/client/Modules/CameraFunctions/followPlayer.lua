local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GlobalOptions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("GlobalOptions"))

local Camera = workspace.CurrentCamera

return function(playerToFollow: Player | Vector3)
    if typeof(playerToFollow) == "Instance" and playerToFollow:IsA("Player") then
        local characterToFollow = playerToFollow.Character or playerToFollow.CharacterAdded:Wait()
        local humanoidToFollow = characterToFollow:WaitForChild("Humanoid")
        Camera.CameraSubject = humanoidToFollow
    else
        Camera.CameraType = Enum.CameraType.Scriptable
        Camera.CFrame = CFrame.new(playerToFollow)
    end
    

    task.delay(GlobalOptions.RespawnTime - 0.5, function()
        Camera.CameraType = Enum.CameraType.Custom
        Camera.CameraSubject = Players.LocalPlayer.Character.Humanoid
    end)
end