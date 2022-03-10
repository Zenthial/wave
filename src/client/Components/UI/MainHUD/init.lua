local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rosyn = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Rosyn"))

local KeyboardInputPrompt = require(script.Parent.KeyboardInputPrompt)
local HeatUI = require(script.Parent.HeatUI)

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
    self.HeatUIComponent = Rosyn.AwaitComponentInit(self.Bottom:WaitForChild("HeatContainer"), HeatUI)
end

function MainHUD:UpdateEquippedWeapon(weapon)
    local HeatUIComponent = self.HeatUIComponent :: typeof(HeatUI)
    if weapon == nil then
        HeatUIComponent:SetName(nil)
        HeatUIComponent:SetHeat(0)
        -- HeatUIComponent:SetKeybind("")
        HeatUIComponent:TriggerBar(0.01)
    else
        HeatUIComponent:SetName(weapon.WeaponStats.Name)
        HeatUIComponent:SetHeat(0)
        HeatUIComponent:SetKeybind("1")
    end
end

function MainHUD:UpdateHeat(heat: number)
    local HeatUIComponent = self.HeatUIComponent :: typeof(HeatUI)
    HeatUIComponent:SetHeat(heat)
end

function MainHUD:UpdateTriggerBar(trigDelay: number)
    local HeatUIComponent = self.HeatUIComponent :: typeof(HeatUI)
    HeatUIComponent:TriggerBar(trigDelay)
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