-- 07/18/2022/
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WorkspaceService = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")

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
        local healthFraction = self.Root:GetAttribute("CurrentHealth")/self.Root:GetAttribute("DefaultHealth")
        local transparencyCalc = 1 - healthFraction

        if originalTransparency > 0 then
            transparencyCalc = transparencyCalc * originalTransparency
        end
        self.Root.Transparency = math.clamp(transparencyCalc, 0, 1)
    end))

    self.Cleaner:Add(self.Root:GetPropertyChangedSignal("Transparency"):Connect(function()
        if self.Root.Transparency == 1 then
            self.Root.CanCollide = false
            CollectionService:AddTag(self.Root, "Ignore")
        else
            self.Root.CanCollide = true
            CollectionService:RemoveTag(self.Root, "Ignore") -- Will not throw an error if the tag never existed.
        end
    end))
end

function Barrier:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(Barrier)

return Barrier