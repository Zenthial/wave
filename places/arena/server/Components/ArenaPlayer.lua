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

type ArenaPlayer_T = {
    __index: ArenaPlayer_T,
    Name: string,
    Tag: string,
    Root: Player,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local ArenaPlayer: ArenaPlayer_T = {}
ArenaPlayer.__index = ArenaPlayer
ArenaPlayer.Name = "ArenaPlayer"
ArenaPlayer.Tag = "Player"
ArenaPlayer.Ancestor = game

function ArenaPlayer.new(root: any)
    return setmetatable({
        Root = root,
    }, ArenaPlayer)
end

function ArenaPlayer:Start()
    if self.Root:GetAttribute("Loaded") == true then
        self.Root:SetAttribute("InRound", true)
    else
        self.Cleaner:Add(self.Root:GetAttributeChangedSignal("Loaded"):Connect(function()
            self.Root:SetAttribute("InRound", self.Root:GetAttribute("Loaded"))
        end))
    end
end

function ArenaPlayer:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(ArenaPlayer)

return ArenaPlayer