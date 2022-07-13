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

type Intro_T = {
    __index: Intro_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local Intro: Intro_T = {}
Intro.__index = Intro
Intro.Name = "Intro"
Intro.Tag = "Intro"
Intro.Ancestor = PlayerGui

function Intro.new(root: ScreenGui)
    return setmetatable({
        Root = root,

        Events = {
            IntroComplete = Signal.new()
        }
    }, Intro)
end

function Intro:Start()
    local Background = self.Root:WaitForChild("Background")
    local BackgroundCreation = tcs.get_component(Background, "UICreation")
    BackgroundCreation:CreateBackground()
end

function Intro:Complete()
    self.Events.IntroComplete:Fire()
end

function Intro:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(Intro)

return Intro