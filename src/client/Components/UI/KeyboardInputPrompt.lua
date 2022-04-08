local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local bluejay = require(ReplicatedStorage.Shared.bluejay)

local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local DIV_GOAL = UDim2.new(0.9, 0, 0.02, 0)
local DIV_START = UDim2.new(0, 0, 0.02, 0)
local TWEEN_TIME = 0.25

local KeyboardInputPrompt = {}
KeyboardInputPrompt.__index = KeyboardInputPrompt
KeyboardInputPrompt.Name = "KeyboardInputPrompt"
KeyboardInputPrompt.Tag = "KeyboardInputPrompt"
KeyboardInputPrompt.Ancestor = PlayerGui

function KeyboardInputPrompt.new(root: any)
    return setmetatable({
        Root = root,
    }, KeyboardInputPrompt)
end

function KeyboardInputPrompt:Start()
    self.Root.PromptText.TextTransparency = 1
    self.Root.PromptKey.TextTransparency = 1
    self.Root.Divider.Size = DIV_START

    TweenService:Create(self.Root.PromptText, TweenInfo.new(TWEEN_TIME), {TextTransparency = 0}):Play()
    TweenService:Create(self.Root.PromptKey, TweenInfo.new(TWEEN_TIME), {TextTransparency = 0}):Play()
    TweenService:Create(self.Root.Divider, TweenInfo.new(TWEEN_TIME), {Size = DIV_GOAL}):Play()
end

function KeyboardInputPrompt:Destroy()
    TweenService:Create(self.Root.PromptText, TweenInfo.new(TWEEN_TIME), {TextTransparency = 1}):Play()
    TweenService:Create(self.Root.PromptKey, TweenInfo.new(TWEEN_TIME), {TextTransparency = 1}):Play()
    local t = TweenService:Create(self.Root.Divider, TweenInfo.new(TWEEN_TIME), {Size = DIV_START})
    t:Play()
    t.Completed:Wait()
    self.Root:Destroy()
end

bluejay.create_component(KeyboardInputPrompt)

return KeyboardInputPrompt