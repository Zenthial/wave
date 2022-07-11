local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local createBackground = require(script.Parent:WaitForChild("createBackground"))
local createTextButton = require(script.Parent:WaitForChild("createTextButton"))
local createSurface = require(script.Parent:WaitForChild("createSurface"))

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

type UICreation_T = {
    __index: UICreation_T,
    Name: string,
    Tag: string,
    Created: boolean,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local UICreation: UICreation_T = {}
UICreation.__index = UICreation
UICreation.Name = "UICreation"
UICreation.Tag = "UICreation"
UICreation.Ancestor = PlayerGui

function UICreation.new(root: any)
    return setmetatable({
        Root = root,
        Created = false,

        Events = {
            CreatedChanged = Signal.new()
        }
    }, UICreation)
end

function UICreation:Start()

end

function UICreation:CreateUI()
    self.Created = true
    self.Events.CreatedChanged:Fire()
end

function UICreation:CreateBackground()
    createBackground(self.Root)
    self:CreateUI()
end

function UICreation:CreateTextButton(buttonLabel: string)
    createTextButton(self.Root, buttonLabel)
    self:CreateUI()
end

function UICreation:CreateSurface()
    createSurface(self.Root)
    self:CreateUI()
end

function UICreation:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(UICreation)

return UICreation