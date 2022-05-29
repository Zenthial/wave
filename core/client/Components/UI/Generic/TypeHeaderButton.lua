local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))

local FILL_SIZE = UDim2.new(0.96, 0, 0.81, 0)
local FILL_CLOSE = UDim2.new(0, 0, 0.81, 0)

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type TypeHeaderButton_T = {
    __index: TypeHeaderButton_T,
    Name: string,
    Tag: string,
    Root: Frame & {
        UIAspectRatioConstraint: UIAspectRatioConstraint,
        UIStroke: UIStroke,
        Fill: Frame,
        Button: TextButton,
        TextLabel: TextLabel
    },
    Selected: boolean,
    Events: {
        SelectChanged: typeof(Signal)
    },

    Cleaner: Cleaner_T
}

local TypeHeaderButton: TypeHeaderButton_T = {}
TypeHeaderButton.__index = TypeHeaderButton
TypeHeaderButton.Name = "TypeHeaderButton"
TypeHeaderButton.Tag = "TypeHeaderButton"
TypeHeaderButton.Ancestor = game

function TypeHeaderButton.new(root: any)
    return setmetatable({
        Root = root,
        Selected = false,

        Events = {
            SelectChanged = Signal.new()
        }
    }, TypeHeaderButton)
end

function TypeHeaderButton:Start()
    self.Cleaner:Add(self.Root.Button.MouseButton1Click:Connect(function()
        self.Selected = not self.Selected
        self.Events.SelectChanged:Fire(self.Selected)
        self:UpdateAppearance()
    end))

    self:UpdateAppearance()
end

function TypeHeaderButton:SetSelected(selected: boolean)
    self.Selected = selected
    self:UpdateAppearance()
end

function TypeHeaderButton:UpdateAppearance()
    if self.Selected then
        TweenService:Create(self.Root.Fill, TweenInfo.new(0.25), {Size = FILL_SIZE, BackgroundTransparency = 0}):Play()
        TweenService:Create(self.Root.TextLabel, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(35, 35, 35)}):Play()
        TweenService:Create(self.Root.UIStroke, TweenInfo.new(0.25), {Thickness = 4, Color = Color3.fromRGB(255, 255, 255)}):Play()
    else
        TweenService:Create(self.Root.Fill, TweenInfo.new(0.25), {Size = FILL_CLOSE, BackgroundTransparency = 1}):Play()
        TweenService:Create(self.Root.TextLabel, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        TweenService:Create(self.Root.UIStroke, TweenInfo.new(0.25), {Thickness = 2, Color = Color3.fromRGB(175, 175, 175)}):Play()
    end
end

function TypeHeaderButton:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(TypeHeaderButton)

return TypeHeaderButton