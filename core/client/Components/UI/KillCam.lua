local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local GlobalOptions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("GlobalOptions"))

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type KillCam_T = {
    __index: KillCam_T,
    Name: string,
    Tag: string,
    CountDown1: Sound,
    CountDown2: Sound,
    CurrentDeathTween: Tween | nil,
    Blur: BlurEffect | nil,

    Cleaner: Cleaner_T
}

local KillCam: KillCam_T = {}
KillCam.__index = KillCam
KillCam.Name = "KillCam"
KillCam.Tag = "KillCam"
KillCam.Ancestor = PlayerGui

function KillCam.new(root: any)
    return setmetatable({
        Root = root,
    }, KillCam)
end

function KillCam:Start()
    local countDown = Instance.new("Sound")
    countDown.SoundId = "rbxassetid://166400843"
    countDown.Parent = self.Root.Parent
    self.CountDown1 = countDown

    local countDown2 = Instance.new("Sound")
    countDown2.SoundId = "rbxassetid://166400857"
    countDown2.Parent = self.Root.Parent

    self.CountDown2 = countDown2

	local deathSignal = Player:GetAttributeChangedSignal("Dead")
    self.Cleaner:Add(deathSignal:Connect(function()
        local death = Player:GetAttribute("Dead")
        if death then
            self:ToggleDeathCam()
        else
            self:RemoveOverlay()
        end
    end))

    self.Root.GuiPart:TweenSizeAndPosition(UDim2.new(0, 0, 0, 0.004), UDim2.new(.5, 0, .5, 0), "Out", "Quad", .5, true)
	self.Root.WeaponName:TweenPosition(UDim2.new(2, 0, 0, 0), "Out", "Quad", 1, true)
	self.Root.KillerName:TweenPosition(UDim2.new(-2, 0, 0, 0), "Out", "Quad", 1, true)
    self.Root.RespawnTime:TweenPosition(UDim2.new(0, 0, 1.6, 0), "Out", "Quad", .3, true)
end

function KillCam:ToggleDeathCam()
    if self.Blur then
        self.Blur:Destroy()
        self.Blur = nil
    end

    local blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Parent = Lighting
    self.Blur = blur
    TweenService:Create(blur, TweenInfo.new(0.15), {Size = 20}):Play()

    local killer = Player:GetAttribute("LastKiller")
    local weapon = Player:GetAttribute("LastKilledWeapon")

    self.Root.Visible = true
    if killer ~= "" and weapon ~= "" then
        self.Root.KillerName.Text = "ELIMINATED BY " .. string.upper(killer)
        self.Root.WeaponName.Text = "WITH THEIR " .. string.upper(weapon)
        self.Root.GuiPart:TweenSizeAndPosition(UDim2.new(.85, 0, 0.004, 0), UDim2.new(0.081, 0, 0.5, 0), "Out", "Quad", .5, true)
        self.Root.WeaponName:TweenPosition(UDim2.new(0, 0, 0.515, 0), "Out", "Quad", .5, true)
        self.Root.KillerName:TweenPosition(UDim2.new(0, 0, 0.475, 0), "Out", "Quad", .5, true)
    else
        self.Root.KillerName.Text = "ELIMINATED BY THE VOID"
        self.Root.GuiPart:TweenSizeAndPosition(UDim2.new(.85, 0, 0.004, 0), UDim2.new(0.081, 0, 0.5, 0), "Out", "Quad", .5, true)
        self.Root.KillerName:TweenPosition(UDim2.new(0, 0, 0.46, 0), "Out", "Quad", .5, true)
    end

    task.delay(GlobalOptions.RespawnTime - 3, function()
        self.Root.RespawnTime:TweenPosition(UDim2.new(0, 0, 0.6, 0), "Out", "Quad", .3, true)
        self.Root.RespawnTime.Text = "RESPAWNING IN 3"
        self.CountDown1:Play()
        task.wait(1)
        self.Root.RespawnTime.Text = "RESPAWNING IN 2"
        self.CountDown1:Play()
        task.wait(1)
        self.Root.RespawnTime.Text = "RESPAWNING IN 1"
        self.CountDown1:Play()
        
        task.wait(1)
        self.Root.RespawnTime:TweenPosition(UDim2.new(0, 0, 1.6, 0), "Out", "Quad", .3, true)
        self.CountDown2:Play()
    end)

    task.wait(GlobalOptions.RespawnTime - 1)
    self:Hide()
end

function KillCam:Hide()
    -- self.Root.Top:TweenPosition(UDim2.new(0, 0, 0, -30), "Out", "Quad", .5, true)
	-- self.Root.Bottom:TweenPosition(UDim2.new(0, 0, .5, 0), "Out", "Quad", .5, true)
	self.Root.GuiPart:TweenSizeAndPosition(UDim2.new(0, 0, 0, 0.004), UDim2.new(.5, 0, .5, 0), "Out", "Quad", .5, true)
	self.Root.WeaponName:TweenPosition(UDim2.new(2, 0, 0, 0), "Out", "Quad", 1, true)
	self.Root.KillerName:TweenPosition(UDim2.new(-2, 0, 0, 0), "Out", "Quad", 1, true)

    self.Root.Parent.Overlay.BackgroundTransparency = 1
    self.Root.Parent.Overlay.Visible = true
    self.CurrentDeathTween = TweenService:Create(self.Root.Parent.Overlay, TweenInfo.new(.1), {BackgroundTransparency = 0})
    self.CurrentDeathTween:Play()
    self.CurrentDeathTween.Completed:Wait()
    self.CurrentDeathTween = nil
end

function KillCam:RemoveOverlay()
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
    self.Root.Parent.Overlay.Visible = false
end

function KillCam:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(KillCam)

return KillCam