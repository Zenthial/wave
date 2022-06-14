local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local ObjectiveSignal = ReplicatedStorage:WaitForChild("ObjectiveSignal")

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type ObjectiveUI_T = {
    __index: ObjectiveUI_T,
    Name: string,
    Tag: string,
    Root: Frame & {
        Blue: Frame & {
            Fill: Frame,
            Score: TextLabel
        },
        Red: Frame & {
            Fill: Frame,
            Score: TextLabel
        },
        Container: Frame & {UIListLayout: UIListLayout},
        Timer: TextLabel
    },

    Cleaner: Cleaner_T
}

local ObjectiveUI: ObjectiveUI_T = {}
ObjectiveUI.__index = ObjectiveUI
ObjectiveUI.Name = "ObjectiveUI"
ObjectiveUI.Tag = "ObjectiveUI"
ObjectiveUI.Ancestor = game

function ObjectiveUI.new(root: any)
    return setmetatable({
        Root = root,
    }, ObjectiveUI)
end

function ObjectiveUI:Start()
end

function ObjectiveUI:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(ObjectiveUI)

return ObjectiveUI