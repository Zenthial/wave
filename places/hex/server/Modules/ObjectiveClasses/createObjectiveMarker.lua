local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ObjectiveGui = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("UI"):WaitForChild("Objectives"):WaitForChild("ObjectiveGui")

return function(parent: Frame, name: string)
    local gui = ObjectiveGui:Clone()
    gui.Parent = parent
    gui.ObjectiveNameFrame.ObjectiveName.Text = name
    gui.Active = true
    gui.Adornee = parent

    return gui
end