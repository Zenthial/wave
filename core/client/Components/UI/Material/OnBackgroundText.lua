local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Themes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("Themes"))
local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type OnBackgroundText_T = {
    __index: OnBackgroundText_T,
    Name: string,
    Tag: string,
    Theme: number,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local OnBackgroundText: OnBackgroundText_T = {}
OnBackgroundText.__index = OnBackgroundText
OnBackgroundText.Name = "OnBackgroundText"
OnBackgroundText.Tag = "OnBackgroundText"
OnBackgroundText.Ancestor = PlayerGui

function OnBackgroundText.new(root: TextLabel | TextButton)
    return setmetatable({
        Root = root,
        Theme = 1,
    }, OnBackgroundText)
end

function OnBackgroundText:Start()
    local Theme = tcs.get_component(self.Root, "Theme")

    self.Cleaner:Add(Theme.Events.ThemeChange:Connect(function(newTheme)
        self:ChangeTheme(newTheme)
    end))

    self:UpdateAppearance()
end

function OnBackgroundText:ChangeTheme(newTheme: number)
    self.Theme = newTheme

    self:UpdateAppearance()
end

function OnBackgroundText:UpdateAppearance()
    self.Root.TextColor3 = Themes[self.Theme].OnBackground
end

function OnBackgroundText:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(OnBackgroundText)

return OnBackgroundText