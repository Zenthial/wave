local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local GlobalOptions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("GlobalOptions"))
local tcs = require(ReplicatedStorage.Shared.tcs)

local KeyboardInputPromptObject = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("UI"):WaitForChild("MainHUD"):WaitForChild("KeyboardInputPrompt")

local MainHUD = {}
MainHUD.__index = MainHUD
MainHUD.Name = "MainHUD"
MainHUD.Tag = "MainHUD"
MainHUD.Ancestor = PlayerGui
MainHUD.Needs = {"Cleaner"}

function MainHUD.new(root: any)
    return setmetatable({
        Root = root,
        Bottom = root.Bottom,
    }, MainHUD)
end

function MainHUD:Start()
    self.Root.Enabled = false

    self.GunToolbar = tcs.get_component(self.Bottom:WaitForChild("ApexFrame2"), "ApexDisplay")
    self.InventoryUI = tcs.get_component(self.Bottom:WaitForChild("InventoryToolbar"), "InventoryUI") --[[:await()]]

    local RenderDeathEffect = ReplicatedStorage:WaitForChild("RenderDeathEffect") :: RemoteEvent

    self.Cleaner:Add(Player:GetAttributeChangedSignal("InRound"):Connect(function()
        self.Root.Enabled = Player:GetAttribute("InRound")
    end))

    self.Cleaner:Add(RenderDeathEffect.OnClientEvent:Connect(function(effect, victim, killer, color)
        self:RenderDeathEffect(effect, victim, killer, color)
    end))
end

function MainHUD:UpdateEquippedWeapon(weaponStats, mutableStats, primary)
    local GunToolbar = self.GunToolbar
    if weaponStats == nil and mutableStats == nil then
        GunToolbar:SetWeapon(nil, nil)
    else
        GunToolbar:SetWeapon(weaponStats, mutableStats, primary)
    end
end

function MainHUD:UpdateHeat(heat: number)
    local GunToolbarComponent = self.GunToolbar
    GunToolbarComponent:UpdateHeat(heat)
end

function MainHUD:UpdateBattery(battery: number)
    local GunToolbarComponent = self.GunToolbar
    GunToolbarComponent:UpdateBattery(battery)
end

function MainHUD:SetOverheated(bool: boolean)
    local GunToolbarComponent = self.GunToolbar
    GunToolbarComponent:SetOverheated(bool)
end

function MainHUD:SetSkillActive()
    self.InventoryUI:SetSkillActive()
end

function MainHUD:SkillEnergyChanged(energy: number)
    self.InventoryUI:SetSkillCharge(energy)
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
    local inputComponent = tcs.get_component(input, "KeyboardInputPrompt")
    return inputComponent
end

function MainHUD:RenderDeathEffect(effect, victim, killer, color)
	effect.NotifierGui.Frame.VictimName.Text = string.upper(victim) .. " DOWNED"
	effect.NotifierGui.Frame.VictimName.TextColor3 = color
	if killer then
		effect.NotifierGui.Frame.KillerName.Text = "BY " .. string.upper(killer)
	end

	effect.NotifierGui.Frame:TweenSizeAndPosition(UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "Out", "Quad", .3, true)
	effect.NotifierGui.Frame.GuiPart1:TweenSizeAndPosition(UDim2.new(0, 1, 1, 0), UDim2.new(0, 0, 0, 0), "Out", "Quad", .1, true)
	effect.NotifierGui.Frame.GuiPart2:TweenSizeAndPosition(UDim2.new(0, 1, 1, 0), UDim2.new(1, -1, 0, 0), "Out", "Quad", .1, true)
	
	task.wait(GlobalOptions.DeathNotifierTime - .7)
	
	effect.NotifierGui.Frame:TweenSizeAndPosition(UDim2.new(0, 0, 1, 0), UDim2.new(.5, 0, 0, 0), "Out", "Quad", .3, true)
	task.wait(.2)
	-- Tween error occurs here
	effect.NotifierGui.Frame.GuiPart1:TweenSizeAndPosition(UDim2.new(0, 1, 0, 0), UDim2.new(0, 0, .5, 0), "Out", "Quad", .1, true)
	effect.NotifierGui.Frame.GuiPart2:TweenSizeAndPosition(UDim2.new(0, 1, 0, 0), UDim2.new(1, -1, .5, 0), "Out", "Quad", .1, true)
	
	task.wait(.1)
	effect.NotifierGui.Frame.KillerName.Text = ""
end

function MainHUD:Destroy()

end

tcs.create_component(MainHUD)

return MainHUD