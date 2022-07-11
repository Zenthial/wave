local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type MainText_T = {
    __index: MainText_T,
    Name: string,
    Tag: string,
    Tween: Tween,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local MainText: MainText_T = {}
MainText.__index = MainText
MainText.Name = "MainText"
MainText.Tag = "MainText"
MainText.Ancestor = game

function MainText.new(root: TextLabel)
    return setmetatable({
        Root = root,
    }, MainText)
end

function MainText:Start()
    self.Tween = TweenService:Create(self.Root, TweenInfo.new(4, Enum.EasingStyle.Bounce, Enum.EasingDirection.In), {Position = UDim2.new(self.Root.Position.X.Scale, self.Root.Position.X.Offset, 0.5, 0)})
end

function MainText:Animate()
    self.Tween:Play()
end

function MainText:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(MainText)

return MainText