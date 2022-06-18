local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ObjectiveGui = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("UI"):WaitForChild("Objectives"):WaitForChild("ObjectiveGui")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

return function(parent: Instance, name: string)
    local gui = ObjectiveGui:Clone()
    gui.ObjectiveNameFrame.ObjectiveName.Text = name
    gui.Active = true
    gui.Adornee = parent
    gui.Parent = PlayerGui
    gui.GuiPart:TweenSize(UDim2.new(1, 0, 0, 1), "Out", "Linear", .2, true)
    task.delay(.2, function()
        gui.ObjectiveNameFrame.ObjectiveName:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Linear", .2, true)
    end)

    return gui
end