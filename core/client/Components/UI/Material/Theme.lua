local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))
local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type Theme_T = {
    __index: Theme_T,
    Name: string,
    Tag: string,
    ActiveTheme: number,
    Root: Frame,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local Theme: Theme_T = {}
Theme.__index = Theme
Theme.Name = "Theme"
Theme.Tag = "Theme"
Theme.Ancestor = PlayerGui

function Theme.new(root: Frame)
    return setmetatable({
        Root = root,
        ActiveTheme = 1,

        Events = {
            ThemeChange = Signal.new()
        }
    }, Theme)
end

function Theme:Start()
    self:ChangeTheme(Player:GetAttribute("UITheme"))

    local UIThemeSignal = Player:GetAttributeChangedSignal("UITheme")
    self.Cleaner:Add(UIThemeSignal:Connect(function()
        self:ChangeTheme(Player:GetAttribute("UITheme"))
    end))
end

function Theme:GetTheme()
    return self.ActiveTheme
end

function Theme:ChangeTheme(newTheme: number)
    self.ActiveTheme = Player:GetAttribute("UITheme")

    self.Events.ThemeChange:Fire(self.ActiveTheme)
end

function Theme:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(Theme)

return Theme