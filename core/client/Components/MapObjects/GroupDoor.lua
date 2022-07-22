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

type GroupDoor_T = {
    __index: GroupDoor_T,
    Name: string,
    Tag: string,
    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local GroupDoor: GroupDoor_T = {}
GroupDoor.__index = GroupDoor
GroupDoor.Name = "GroupDoor"
GroupDoor.Tag = "GroupDoor"
GroupDoor.Ancestor = WorkspaceService

function GroupDoor.new(root: BasePart)
    return setmetatable({
        Root = root,
    }, GroupDoor)
end

function GroupDoor:Start()
    local GroupId = self.Root:GetAttribute("GroupId")
    assert(typeof(GroupId) == "number", "GroupId must be a number")

    if LocalPlayer:IsInGroup(GroupId) then -- Caches data in the game, so even if a player joins the group, they won't be able to use it unless the server restarts.
        CollectionService:AddTag(self.Root, "Ignore")
        self.Root.CanCollide = false
        self.Root.Transparency = 1
    end
end

function GroupDoor:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(GroupDoor)

return GroupDoor