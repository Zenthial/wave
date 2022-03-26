local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local wcs = require(ReplicatedStorage.Shared.wcs)

local KeyboardInputPromptObject = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("UI"):WaitForChild("MainHUD"):WaitForChild("KeyboardInputPrompt")

local MainHUD = {}
MainHUD.__index = MainHUD
MainHUD.Name = "MainHUD"
MainHUD.Tag = "MainHUD"
MainHUD.Ancestor = PlayerGui

function MainHUD.new(root: any)
    return setmetatable({
        Root = root,
        Bottom = root.Bottom,
    }, MainHUD)
end

function MainHUD:CreateDependencies()
    return {
        ["HeatUI"] = self.Bottom:WaitForChild("HeatContainer")
    }
end

function MainHUD:Start()

end

function MainHUD:UpdateEquippedWeapon(weapon)
    local HeatUIComponent = self.HeatUI
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
    local HeatUIComponent = self.HeatUI
    HeatUIComponent:SetHeat(heat)
end

function MainHUD:UpdateTriggerBar(trigDelay: number)
    local HeatUIComponent = self.HeatUI
    HeatUIComponent:TriggerBar(trigDelay)
end

function MainHUD:PromptKeyboardInput(inputText: string, inputKey: string?)
    local prevInput = self.Bottom:FindFirstChild("KeyboardInputPrompt")
    if prevInput then
        CollectionService:RemoveTag(prevInput, "KeyboardInputPrompt")
    end
    local input = KeyboardInputPromptObject:Clone()
    input.PromptText.Text = inputText
    if inputKey then
        input.PromptKey.Text = inputKey:upper()
    end
    input.Parent = self.Bottom
    local inputComponent = wcs.get_component(input, "KeyboardInputPrompt")
    return inputComponent
end

function MainHUD:Destroy()

end

wcs.create_component(MainHUD)

return MainHUD