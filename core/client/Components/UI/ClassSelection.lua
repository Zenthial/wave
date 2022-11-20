local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"):WaitForChild("GenericTypes"))
local courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))

local ClassFrame = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("UI"):WaitForChild("ClassFrame")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Arsenal = workspace:WaitForChild("Arsenal")

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
ClassSelection.Ancestor = PlayerGui

function ClassSelection.new(root: any)
    return setmetatable({
        Root = root,
    }, ClassSelection)
end

function ClassSelection:Start()
    local ArsenalComponent = tcs.get_component(PlayerGui.Arsenal, "Arsenal")
    self.Arsenal = ArsenalComponent 

    self.Cleaner:Add(LocalPlayer:GetAttributeChangedSignal("InClassSelection"):Connect(function()
        local inClassSelection = LocalPlayer:GetAttribute("InClassSelection")

        if inClassSelection then
            self:Open()
        else
            self:Close()
        end
    end))
end

function ClassSelection:Open()
    Camera.CameraType = Enum.CameraType.Scriptable
    Camera.CFrame = CFrame.new(Arsenal.ClassCameraPart.Position, Arsenal.ClassInspectPart.Position)

    self:LoadClasses()
    self.Root.Visible = true
end

function ClassSelection:Close()
    self.Root.Visible = false
end

function ClassSelection:HandleClassDisplay(className, classInfo)
    self.Root.ClassNameText.Text = className
    self.Root.ClassDetail.Text = classInfo.ClassDetail

    if LocalPlayer:GetAttribute("CurrentClass") == className then 
        self.Root.SelectButton.Visible = false
        self.Root.EditButton.Visible = true
    else
        self.Root.SelectButton.Visible = true
        self.Root.EditButton.Visible = false
    end
end

function ClassSelection:LoadClasses()
    local classes = courier:SendFunction("GetClasses")
    local selectedClass = nil

    for className, classInfo in classes do
        local classFrame = ClassFrame:Clone()
        classFrame.Name = className
        classFrame.ClassNameText.Text = className
        classFrame.LayoutOrder = if classInfo.Default then 1 else string.byte(className:sub(1, 1))

        classFrame.ViewportFrame:ClearAllChildren()

        local hat = classInfo.Hat:Clone()
        hat.Parent = classFrame.ViewportFrame

        local hatPosition = hat:GetBoundingBox().Position

        local viewportCamera = Instance.new("Camera")
        classFrame.ViewportFrame.CurrentCamera = viewportCamera
        viewportCamera.Parent = classFrame.ViewportFrame
        viewportCamera.CFrame = CFrame.new(hatPosition - Vector3.new(0, 0, 2), hatPosition)

        print(className, LocalPlayer:GetAttribute("CurrentClass"))
        if selectedClass == nil and className == LocalPlayer:GetAttribute("CurrentClass") then
            print(className)
            selectedClass = className
            self:HandleClassDisplay(className, classInfo)
        end

        self.Cleaner:Add(classFrame.Button.MouseButton1Click:Connect(function()
            selectedClass = className
            self:HandleClassDisplay(className, classInfo)
        end))

        -- animation entering and leaving
        self.Cleaner:Add(classFrame.Button.MouseEnter:Connect(function()
        
        end))

        self.Cleaner:Add(classFrame.Button.MouseLeave:Connect(function()
            
        end))

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
            LocalPlayer:SetAttribute("InArsenalSelection", true)
            LocalPlayer:SetAttribute("InClassSelection", false)
        end
    end))

    self.Cleaner:Add(self.Root.BackButton.Button.MouseButton1Click:Connect(function()
        Camera.CameraType = Enum.CameraType.Custom
        Camera.CameraSubject = LocalPlayer.Character.Humanoid
        LocalPlayer:SetAttribute("InClassSelection", false)
    end))
end

function ClassSelection:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(ClassSelection)

return ClassSelection