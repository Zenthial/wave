local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type SwordfishPlayer_T = {
    __index: SwordfishPlayer_T,
    Name: string,
    Tag: string,
    Root: Player,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local SwordfishPlayer: SwordfishPlayer_T = {}
SwordfishPlayer.__index = SwordfishPlayer
SwordfishPlayer.Name = "SwordfishPlayer"
SwordfishPlayer.Tag = "Player"
SwordfishPlayer.Ancestor = game

function SwordfishPlayer.new(root: any)
    return setmetatable({
        Root = root,
    }, SwordfishPlayer)
end

function SwordfishPlayer:Start()
    if self.Root:GetAttribute("Loaded") == true then
        self.Root:SetAttribute("InRound", true)
    else
        self.Cleaner:Add(self.Root:GetAttributeChangedSignal("Loaded"):Connect(function()
            self.Root:SetAttribute("InRound", self.Root:GetAttribute("Loaded"))
        end))
    end
end

function SwordfishPlayer:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(SwordfishPlayer)

return SwordfishPlayer