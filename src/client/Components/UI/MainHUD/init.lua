local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rosyn = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Rosyn"))

local KeyboardInputPrompt = require(script.Parent.KeyboardInputPrompt)

local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local KeyboardInputPromptObject = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("UI"):WaitForChild("MainHUD"):WaitForChild("KeyboardInputPrompt")

local MainHUD = {}
MainHUD.__index = MainHUD
MainHUD.__Tag = "MainHUD"

function MainHUD.new(root: any)
    return setmetatable({
        Root = root,
        Bottom = root.Bottom,
    }, MainHUD)
end

function MainHUD:Initial()
    
end

function MainHUD:PromptKeyboardInput(inputText: string, inputKey: string?)
    local prevInput = self.Bottom:FindFirstChild("KeyboardInputPrompt")
    if prevInput then
        local prevInputComponent = Rosyn.GetComponent(prevInput, KeyboardInputPrompt) :: typeof(KeyboardInputPrompt)
        prevInputComponent:Destroy()
    end
    local input = KeyboardInputPromptObject:Clone()
    input.PromptText.Text = inputText
    if inputKey then
        input.PromptKey.Text = inputKey:upper()
    end
    input.Parent = self.Bottom
    local inputComponent = Rosyn.AwaitComponent(input, KeyboardInputPrompt)
    return inputComponent
end

function MainHUD:Destroy()

end

Rosyn.Register("MainHUD", {MainHUD}, PlayerGui)

return MainHUD