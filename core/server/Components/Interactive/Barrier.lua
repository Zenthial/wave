-- 07/17/2022/
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WorkspaceService = game:GetService("Workspace")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type Barrier_T = {
    __index: Barrier_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local Barrier: Barrier_T = {}
Barrier.__index = Barrier
Barrier.Name = "Barrier"
Barrier.Tag = "Barrier"
Barrier.Ancestor = WorkspaceService

function Barrier.new(root: BasePart)
    return setmetatable({
        Root = root,
    }, Barrier)
end

function Barrier:Start()
    local defaultHealth = self.Root:GetAttribute("DefaultHealth")
    assert(defaultHealth ~= nil, "DefaultHealth not found!")

    local originalTransparency = self.Root.Transparency

    repeat task.wait(.1)
    until self.Root:GetAttribute("CurrentHealth") ~= nil

    self.Cleaner:Add(self.Root:GetAttributeChangedSignal("CurrentHealth"):Connect(function()
        self.Root.Transparency = (self.Root:GetAttribute("CurrentHealth")*originalTransparency)/self.Root:GetAttribute("DefaultHealth")
    end))
end

function Barrier:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(Barrier)

return Barrier