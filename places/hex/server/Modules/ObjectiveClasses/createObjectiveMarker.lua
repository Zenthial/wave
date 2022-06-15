local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ObjectiveGui = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("UI"):WaitForChild("Objectives"):WaitForChild("ObjectiveGui")

return function(parent: Frame, name: string)
    local gui = ObjectiveGui:Clone()
    gui.ObjectiveNameFrame.ObjectiveName.Text = name
    gui.Parent = parent

    return gui
end