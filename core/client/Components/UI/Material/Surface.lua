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

type Surface_T = {
    __index: Surface_T,
    Name: string,
    Tag: string,
    Theme: number,
    Root: Frame & {
        Surface: Frame & {
            UICorner: UICorner,
            UIStroke: UIStroke,
            Shadow: Frame & {
                UICorner: UICorner,
            }
        }
    },

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local Surface: Surface_T = {}
Surface.__index = Surface
Surface.Name = "MaterialUI"
Surface.Tag = "Surface"
Surface.Ancestor = PlayerGui

function Surface.new(root: any)
    return setmetatable({
        Root = root,
        Theme = 1
    }, Surface)
end

function Surface:Start()
    local Theme = tcs.get_component(self.Root, "Theme")

    self.Cleaner:Add(Theme.Events.ThemeChange:Connect(function(newTheme)
        self:ChangeTheme(newTheme)
    end))
end

function Surface:ChangeTheme(newTheme: number)
    self.Theme = newTheme

    self:UpdateAppearance()
end

function Surface:UpdateAppearance()
    self.Root.Surface.BackgroundColor3 = Themes[self.Theme].Surface
end

function Surface:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(Surface)

return Surface