local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))

local FILL_SIZE = UDim2.new(0.955, 0, 0.69, 0)
local FILL_CLOSE = UDim2.new(0, 0, 0.69, 0)

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type ListItem_T = {
    __index: ListItem_T,
    Name: string,
    Tag: string,
    Root: Frame & {
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

local ListItem: ListItem_T = {}
ListItem.__index = ListItem
ListItem.Name = "ListItem"
ListItem.Tag = "ListItem"
ListItem.Ancestor = game

function ListItem.new(root: any)
    return setmetatable({
        Root = root,
        Selected = false,

        Events = {
            SelectChanged = Signal.new()
        }
    }, ListItem)
end

function ListItem:Start()
    self.Cleaner:Add(self.Root.Button.MouseButton1Click:Connect(function()
        if self.Selected == false then
            self.Selected = not self.Selected
            self.Events.SelectChanged:Fire(self.Selected)
            self:UpdateAppearance()
        end
    end))

    self:UpdateAppearance()
end

function ListItem:SetSelected(selected: boolean)
    self.Selected = selected
    self:UpdateAppearance()
end

function ListItem:UpdateAppearance()
    if self.Selected then
        TweenService:Create(self.Root.Fill, TweenInfo.new(0.25), {Size = FILL_SIZE, BackgroundTransparency = 0}):Play()
        TweenService:Create(self.Root.TextLabel, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(35, 35, 35)}):Play()
    else
        TweenService:Create(self.Root.Fill, TweenInfo.new(0.25), {Size = FILL_CLOSE, BackgroundTransparency = 1}):Play()
        TweenService:Create(self.Root.TextLabel, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end
end

function ListItem:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(ListItem)

return ListItem