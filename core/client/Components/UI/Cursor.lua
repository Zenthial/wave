local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local bluejay = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("bluejay"))

local Player = Players.LocalPlayer

local ICON_TWEEN = 0.1
local ICON_SIZE = UDim2.fromOffset(15, 15)
local ICON_CLOSED_SIZE = UDim2.fromOffset(0, 0)

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Cursor_T = {
    __index: Cursor_T,
    Name: string,
    Tag: string,

    Expand: (Cursor_T) -> (),

    Cleaner: Cleaner_T
}

local Cursor: Cursor_T = {}
Cursor.__index = Cursor
Cursor.Name = "Cursor"
Cursor.Tag = "Cursor"
Cursor.Ancestor = game
Cursor.Needs = {"Cleaner"}

function Cursor.new(root: any)
    return setmetatable({
        Root = root,
    }, Cursor)
end

function Cursor:CreateDependencies()
    return {}
end

function Cursor:Start()
    self.Root.Visible = true
    self:WordForNotExpand()

    UserInputService.MouseIconEnabled = false
    self.Cleaner:Add(UserInputService.InputChanged:Connect(function(inputObject)
        if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
            self.Root.Position = UDim2.fromOffset(inputObject.Position.X, inputObject.Position.Y)
        end
    end))

    local EquippedWeaponChangedSignal = Player:GetAttributeChangedSignal("EquippedWeapon")
    self.Cleaner:Add(EquippedWeaponChangedSignal:Connect(function()
        if Player:GetAttribute("EquippedWeapon") == "" then
            self:WordForNotExpand()
        else
            self:Expand()
        end
    end))
end

function Cursor:Expand()
    TweenService:Create(self.Root.Icon, TweenInfo.new(ICON_TWEEN), {Size = ICON_SIZE}):Play()
end

function Cursor:WordForNotExpand()
    TweenService:Create(self.Root.Icon, TweenInfo.new(ICON_TWEEN), {Size = ICON_CLOSED_SIZE}):Play()
end

function Cursor:Destroy()
    self.Cleaner:Clean()
end

bluejay.create_component(Cursor)

return Cursor