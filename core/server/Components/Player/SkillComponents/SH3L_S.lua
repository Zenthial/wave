local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type SH3L_S_T = {
    __index: SH3L_S_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T
}

local SH3L_S: SH3L_S_T = {}
SH3L_S.__index = SH3L_S
SH3L_S.Name = "SH3L-S"
SH3L_S.Tag = "SH3L-S"
SH3L_S.Ancestor = game

function SH3L_S.new(root: any)
    return setmetatable({
        Root = root,
    }, SH3L_S)
end

function SH3L_S:Start()
    local start, _ = string.find(self.Root.Name, "STAS3N")
    local playerName = self.Root.Name:sub(1, start - 1)
    self.Player = Players:FindFirstChild(playerName) :: Player

    local stationStream = Instance.new("RemoteEvent")
    stationStream.Name = self.Root.Name.."SH3L-SStream"
    stationStream.Parent = ReplicatedStorage

end

function SH3L_S:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(SH3L_S)

return SH3L_S