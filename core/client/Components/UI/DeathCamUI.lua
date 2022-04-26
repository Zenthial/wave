local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local bluejay = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("bluejay"))

local GlobalOptions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("GlobalOptions"))

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type DeathCamUI_T = {
    __index: DeathCamUI_T,
    Name: string,
    Tag: string,
    CountDown1: Sound,
    CountDown2: Sound,
    CurrentDeathTween: Tween | nil,
    Blur: BlurEffect | nil,

    Cleaner: Cleaner_T
}

local DeathCamUI: DeathCamUI_T = {}
DeathCamUI.__index = DeathCamUI
DeathCamUI.Name = "DeathCamUI"
DeathCamUI.Tag = "DeathCamUI"
DeathCamUI.Ancestor = game
DeathCamUI.Needs = {"Cleaner"}

function DeathCamUI.new(root: any)
    return setmetatable({
        Root = root,
    }, DeathCamUI)
end

function DeathCamUI:Start()
    local countDown = Instance.new("Sound")
    countDown.SoundId = "rbxassetid://166400843"
    countDown.Parent = self.Root.Parent
    self.CountDown1 = countDown

    local countDown2 = Instance.new("Sound")
    countDown2.SoundId = "rbxassetid://166400857"
    countDown2.Parent = self.Root.Parent

    self.CountDown2 = countDown2

	local deathSignal = Players.LocalPlayer:GetAttributeChangedSignal("Died")
    self.Cleaner:Add(deathSignal:Connect(function()
        local death = Players.LocalPlayer:GetAttribute("Died")
        if death then
            self:ToggleDeathCam()
        else
            self:RemoveOverlay()
        end
    end))
end

function DeathCamUI:ToggleDeathCam()
    if self.Blur then
        self.Blur:Destroy()
        self.Blur = nil
    end

    local blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Parent = Lighting
    TweenService:Create(blur, Instance.new(0.15), {Size = 20}):Play()


    local killer = Players.LocalPlayer:GetAttribute("LastKiller")
    local weapon = Players.LocalPlayer:GetAttribute("LastKilledWeapon")

    if killer ~= "" and weapon ~= "" then
        self.Root.KillerName.Text = "ELIMINATED BY " .. string.upper(killer)
        self.Root.WeaponName.Text = "WITH THEIR " .. string.upper(weapon)
        self.Root.GuiPart:TweenSizeAndPosition(UDim2.new(1, -200, 0, 1), UDim2.new(0, 100, 0.5, 0), "Out", "Quad", .5, true)
        self.Root.WeaponName:TweenPosition(UDim2.new(0, 0, 0, 30), "Out", "Quad", .5, true)
        self.Root.KillerName:TweenPosition(UDim2.new(0, 0, 0, 10), "Out", "Quad", .5, true)
    else
        self.Root.KillerName.Text = "ELIMINATED BY THE VOID"
        self.Root.KillerName:TweenPosition(UDim2.new(0, 0, 0, 10), "Out", "Quad", .5, true)
    end

    task.delay(GlobalOptions.RespawnTime - 3, function()
        self.Root.RespawnTime:TweenPosition(UDim2.new(0, 0, 0, 250), "Out", "Quad", .3, true)
        self.Root.RespawnTime.Text = "RESPAWNING IN 3"
        self.CountDown1:Play()
        task.wait(1)
        self.Root.RespawnTime.Text = "RESPAWNING IN 2"
        self.CountDown1:Play()
        task.wait(1)
        self.Root.RespawnTime.Text = "RESPAWNING IN 1"
        self.CountDown1:Play()
        
        task.wait(1)
        self.Root.RespawnTime:TweenPosition(UDim2.new(0, 0, 0, 1000), "Out", "Quad", .3, true)
        self.Countdown2:Play()
    end)

    self:Hide()
end

function DeathCamUI:Hide()
    self.Root.Top:TweenPosition(UDim2.new(0, 0, 0, -30), "Out", "Quad", .5, true)
	self.Root.Bottom:TweenPosition(UDim2.new(0, 0, .5, 0), "Out", "Quad", .5, true)
	self.Root.KillCam.GuiPart:TweenSizeAndPosition(UDim2.new(0, 0, 0, 1), UDim2.new(.5, 0, .5, 0), "Out", "Quad", .5, true)
	self.Root.KillCam.WeaponName:TweenPosition(UDim2.new(0, 0, 0, 2000), "Out", "Quad", 1, true)
	self.Root.KillCam.KillerName:TweenPosition(UDim2.new(0, 0, 0, -2000), "Out", "Quad", 1, true)

    self.CurrentDeathTween = TweenService:Create(self.Root.Parent.Overlay, TweenInfo.new(.1), {BackgroundTransparency = 0})
    self.CurrentDeathTween:Play()
    self.CurrentDeathTween.Completed:Wait()
    self.CurrentDeathTween = nil
end

function DeathCamUI:RemoveOverlay()
    if self.CurrentDeathTween ~= nil then
        self.CurrentDeathTween:Pause()
        self.CurrentDeathTween:Destroy()
        self.CurrentDeathTween = nil
    end
    
    if self.Blur then
        local tween = TweenService:Create(self.Blur, TweenInfo.new(.15), {Size = 0})
        tween:Play()
        
        local con
        con = tween.Completed:Connect(function()
            self.Blur:Destroy()
            self.Blur = nil
            con:Disconnect()
        end)
    end

    self.CurrentDeathTween = TweenService:Create(self.Root.Parent.Overlay, TweenInfo.new(.1), {BackgroundTransparency = 1})
    self.CurrentDeathTween:Play()
    self.CurrentDeathTween.Completed:Wait()
    self.CurrentDeathTween = nil
end

function DeathCamUI:Destroy()
    self.Cleaner:Clean()
end

bluejay.create_component(DeathCamUI)

return DeathCamUI