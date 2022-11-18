local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"):WaitForChild("GenericTypes"))
local courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))

local setViewport = require(script.Parent.functions.SetViewport)

local ClassFrame = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("UI"):WaitForChild("ClassFrame")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Camera = workspace.CurrentCamera

type Cleaner_T = types.Cleaner_T

type Courier_T = types.Courier_T

type ClassSelection_T = {
    __index: ClassSelection_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local ClassSelection: ClassSelection_T = {}
ClassSelection.__index = ClassSelection
ClassSelection.Name = "ClassSelection"
ClassSelection.Tag = "ClassSelection"
ClassSelection.Ancestor = game

function ClassSelection.new(root: any)
    return setmetatable({
        Root = root,
    }, ClassSelection)
end

function ClassSelection:Start()
    local Arsenal = tcs.get_component(PlayerGui, "Arsenal")
    self.Arsenal = Arsenal

    self.Cleaner:Add(LocalPlayer:GetAttributeChangedSignal("InClassSelection"):Connect(function()
        local inClassSelection = LocalPlayer:GetAttribute("InClassSelection")

        if inClassSelection then
            self:Open()
        else

        end
    end))
end

function ClassSelection:Open()
    Camera.CameraType = Enum.CameraType.Scriptable
    Camera.CFrame = CFrame.new(InventoryPlayer.HumanoidRootPart.Position + Vector3.new(12, 0, 0), InventoryPlayer.HumanoidRootPart.Position)
end

function ClassSelection:LoadClasses()
    local classes = courier:SendFunction("GetClasses")
    local selectedClass = nil

    for className, classInfo in classes do
        local classFrame = ClassFrame:Clone()
        classFrame.Name = className
        classFrame.ClassName.Text = className
        setViewport(classFrame.ViewportFrame, classInfo.Hat)

        if selectedClass == nil then
            selectedClass = className
        end

        self.Cleaner:Add(classFrame.Button:Connect(function()
            selectedClass = className
        end))

        self.Cleaner:Add()
        
        classFrame.Parent = self.Root.Container
    end

    self.Cleaner:Add(self.Root.SelectButton.Button.MouseButton1Click:Connect(function()
        local currentClass = LocalPlayer:GetAttribute("CurrentClass")

        if currentClass ~= selectedClass then
            local result = courier:SendFunction("RequestClassChange")
            if result then
                self.Root.SelectButton.Visible = false
                self.Root.EditButton.Visible = true
            else
                self.Root.LockedNotification.Visible = true
                self.Root.SelectButton.Visible = false
                task.delay(1, function()
                    self.Root.LockedNotification.Visible = false
                    self.Root.SelectButton.Visible = true
                end)
            end
        end
    end))

    self.Cleaner:Add(self.Root.EditButton.Button.MouseButton1Click:Connect(function()
        local currentClass = LocalPlayer:GetAttribute("CurrentClass")

        if currentClass == selectedClass then
            LocalPlayer:SetAttribute("InClassSelection", true)
        end
    end))
end

function ClassSelection:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(ClassSelection)

return ClassSelection