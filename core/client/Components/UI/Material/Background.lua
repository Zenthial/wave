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

type Background_T = {
    __index: Background_T,
    Name: string,
    Tag: string,
    Root: Frame & {
        Background: Frame & {
            UICorner: UICorner,
            UIStroke: UIStroke,

            Shadow: Frame & {
                UICorner: UICorner,
            }
        }
    },
    Theme: number,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local Background: Background_T = {}
Background.__index = Background
Background.Name = "Background"
Background.Tag = "Background"
Background.Ancestor = PlayerGui

function Background.new(root: Frame)
    return setmetatable({
        Root = root,
        Theme = 1
    }, Background)
end

function Background:Start()
    local Theme = tcs.get_component(self.Root, "Theme")
    local UICreation = tcs.get_component(self.Root, "UICreation")

    if not UICreation.Created then
        UICreation.Events.CreatedChanged:Wait()
    end

    self.Cleaner:Add(Theme.Events.ThemeChange:Connect(function(newTheme)
        self:ChangeTheme(newTheme)
    end))

    self:UpdateAppearance()
end

function Background:ChangeTheme(newTheme: number)
    self.Theme = newTheme

    self:UpdateAppearance()
end

function Background:UpdateAppearance()
    self.Root:WaitForChild("Background").BackgroundColor3 = Themes[self.Theme].Background
end

function Background:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(Background)

return Background