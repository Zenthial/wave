-- 10/27/2022/
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type Prompt_T = {
    __index: Prompt_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local Prompt: Prompt_T = {}
Prompt.__index = Prompt
Prompt.Name = "Prompt"
Prompt.Tag = "Prompt"
Prompt.Ancestor = game

function Prompt.new(root: ProximityPrompt)
    return setmetatable({
        Root = root,
    }, Prompt)
end

function Prompt:Start()
    self.Root.KeyboardKeyCode = Enum.KeyCode[Player.Keybinds:GetAttribute("Interact")]

    Player.Keybinds:GetAttributeChangedSignal("Interact"):Connect(function()
        self.Root.KeyboardKeyCode = Enum.KeyCode[Player.Keybinds:GetAttribute("Interact")]
    end)
end

function Prompt:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(Prompt)

return Prompt