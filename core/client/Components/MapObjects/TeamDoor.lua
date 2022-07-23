-- 07/19/2022/
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WorkspaceService = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type TeamDoor_T = {
    __index: TeamDoor_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local TeamDoor: TeamDoor_T = {}
TeamDoor.__index = TeamDoor
TeamDoor.Name = "TeamDoor"
TeamDoor.Tag = "TeamDoor"
TeamDoor.Ancestor = game

function TeamDoor.new(root: any)
    return setmetatable({
        Root = root,
    }, TeamDoor)
end

function TeamDoor:Start()
    local TeamColor = self.Root:GetAttribute("TeamColor")
    assert(typeof(TeamColor) == "BrickColor", "TeamColor must be a BrickColor attribute")

    local OriginalTransparency = self.Root.Transparency

    if LocalPlayer.TeamColor == TeamColor then
        CollectionService:AddTag(self.Root, "Ignore")
        self.Root.CanCollide = false
        self.Root.Transparency = 1
    end

    self.Cleaner:Add(LocalPlayer:GetPropertyChangedSignal("TeamColor"):Connect(function()
        if LocalPlayer.TeamColor == TeamColor then
            CollectionService:AddTag(self.Root, "Ignore")
            self.Root.CanCollide = false
            self.Root.Transparency = 1
        else
            CollectionService:RemoveTag(self.Root, "Ignore")
            self.Root.CanCollide = true
            self.Root.Transparency = OriginalTransparency
        end
    end))
end

function TeamDoor:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(TeamDoor)

return TeamDoor