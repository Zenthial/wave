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

type NewComponent_T = {
    __index: NewComponent_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local NewComponent: NewComponent_T = {}
NewComponent.__index = NewComponent
NewComponent.Name = "NewComponent"
NewComponent.Tag = "NewComponent"
NewComponent.Ancestor = game

function NewComponent.new(root: any)
    return setmetatable({
        Root = root,
    }, NewComponent)
end

function NewComponent:Start()
    
end

function NewComponent:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(NewComponent)

return NewComponent