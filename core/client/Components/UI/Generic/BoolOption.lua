local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))

local TRUE_COLOR = Color3.fromRGB(0, 255, 191)
local TRUE_TRANSPARENCY = 0.25
local FALSE_COLOR = Color3.fromRGB(65, 88, 111)
local FALSE_TRANSPARENCY = 0.5

local TWEEN_TIME = 0.2

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type BoolOption_T = {
    __index: BoolOption_T,
    Name: string,
    Tag: string,
    CurrentState: boolean,
    Events: {
        Changed: {
            Fire: (...any) -> ()
        }
    },

    Cleaner: Cleaner_T
}

local BoolOption: BoolOption_T = {}
BoolOption.__index = BoolOption
BoolOption.Name = "BoolOption"
BoolOption.Tag = "BoolOption"
BoolOption.Ancestor = game

function BoolOption.new(root: any)
    return setmetatable({
        Root = root,

        Events = {
            Changed = Signal.new()
        }
    }, BoolOption)
end

function BoolOption:Start()
    local activeAttribute = self.Root:GetAttribute("Active") :: boolean
    self.CurrentState = activeAttribute


    self.Cleaner:Add(self.Root.Button.Activated:Connect(function()
        self.CurrentState = not self.CurrentState
        self.Events.Changed:Fire(self.CurrentState)
        self:Update()
    end))
end

function BoolOption:SetState(state: boolean)
    self.CurrentState = state
    self:Update()
end

function BoolOption:Update()
    if self.CurrentState then
        TweenService:Create(self.Root.Button, TweenInfo.new(TWEEN_TIME), {BackgroundColor3 = TRUE_COLOR, BackgroundTransparency = TRUE_TRANSPARENCY}):Play()
    else
        TweenService:Create(self.Root.Button, TweenInfo.new(TWEEN_TIME), {BackgroundColor3 = FALSE_COLOR, BackgroundTransparency = FALSE_TRANSPARENCY}):Play()
    end
end

function BoolOption:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(BoolOption)

return BoolOption