-- 07/11/2022/
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type MainMenu_T = {
    __index: MainMenu_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local MainMenu: MainMenu_T = {}
MainMenu.__index = MainMenu
MainMenu.Name = "MainMenu"
MainMenu.Tag = "MainMenu"
MainMenu.Ancestor = game

function MainMenu.new(root: ScreenGui)
    return setmetatable({
        Root = root,
    }, MainMenu)
end

function MainMenu:Start()
    local IntroUI = PlayerGui:WaitForChild("IntroUI")
    local IntroComponent = tcs:get_component(IntroUI, "Intro")

    self.Cleaner:Add(IntroComponent.Events.IntroComplete:Connect(function()
        self.Root.Enabled = true
    end))
end

function MainMenu:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(MainMenu)

return MainMenu