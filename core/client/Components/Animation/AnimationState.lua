local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local tcs = require(ReplicatedStorage.Shared.tcs)
local WeaponStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))

local DefaultAnimations = require(script.Parent.DefaultAnimationNames)

export type State_T = {
    Equipping: number, -- 0 = not equipping, 1 = equipping, -1 = unequipping
    
    SprintActive: boolean,
    SprintPlaying: boolean,

    Rolling: boolean,

    CrouchActive: boolean,
    CrouchPlaying: boolean,

    ReloadActive: boolean,
    ReloadPlaying: boolean,

    GrenadeActive: boolean,
    GrenadePlaying: boolean,

    FielxActive: boolean,
    FielxPlaying: boolean,

    DeployableActive: boolean,
    DeployablePlaying: boolean,

    WeaponEquipped: boolean,
    WeaponName: string
}

local Player = Players.LocalPlayer

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type AnimationHandler_T = {
    Play: (AnimationHandler_T, string) -> AnimationTrack,
    Stop: (AnimationHandler_T, string) -> (),
}

type AnimationState_T = {
    __index: AnimationState_T,
    Name: string,
    Tag: string,

    State: State_T,
    Cleaner: Cleaner_T,
    AnimationHandler: AnimationHandler_T,    
}

local AnimationState: AnimationState_T = {}
AnimationState.__index = AnimationState
AnimationState.Name = "AnimationState"
AnimationState.Tag = "AnimationState"
AnimationState.Ancestor = Players
AnimationState.Needs = {"Cleaner"}

function AnimationState.new(root: any)
    return setmetatable({
        Root = root,
    }, AnimationState)
end

function AnimationState:Start()
    local cleaner = self.Cleaner

    self.AnimationHandler = tcs.get_component(self.Root, "AnimationHandler") --[[:await()]]

    local state: State_T = {
        Equipping = 0,

        SprintActive = false,
        SprintPlaying = false,

        Rolling = false,

        CrouchActive = false,
        CrouchPlaying = false,

        ReloadActive = false,
        ReloadPlaying = false,

        GrenadeActive = false,
        GrenadePlaying = false,

        FielxActive = false,
        FielxPlaying = false,

        DeployableActive = false,
        DeployablePlaying = false,

        WeaponEquipped = false,
        WeaponName = "",

        PlayingAnimations = {}
    }

    self.State = state

    local SprintChangedSignal = Player:GetAttributeChangedSignal("LocalSprinting")
    local CrouchChangedSignal = Player:GetAttributeChangedSignal("LocalCrouching")
    local RollingChangedSignal = Player:GetAttributeChangedSignal("LocalRolling")
    local EquippedWeaponChangedSignal = Player:GetAttributeChangedSignal("EquippedWeapon") -- string
    local ReloadingChangedSignal = Player:GetAttributeChangedSignal("Reloading")
    local ThrowingChangedSignal = Player:GetAttributeChangedSignal("Throwing")
    local PlacingDeployableChangedSignal = Player:GetAttributeChangedSignal("PlacingDeployable")
    local FielxPunchSignal = Player:GetAttributeChangedSignal("FielxActive")

    cleaner:Add(SprintChangedSignal:Connect(function()
        state.SprintActive = Player:GetAttribute("LocalSprinting")
        
        self:HandleSprintChange()
    end))

    cleaner:Add(CrouchChangedSignal:Connect(function()
        state.CrouchActive = Player:GetAttribute("LocalCrouching")
        
        self:HandleCrouchChange()
    end))

    cleaner:Add(RollingChangedSignal:Connect(function()
        state.Rolling = Player:GetAttribute("LocalRolling")
        
        self:HandleRollingChange()
    end))

    cleaner:Add(ThrowingChangedSignal:Connect(function()
        state.GrenadeActive = Player:GetAttribute("Throwing")

        self:HandleThrowingChange()
    end))

    cleaner:Add(EquippedWeaponChangedSignal:Connect(function()
        self:HandleWeaponChange()
    end))

    cleaner:Add(FielxPunchSignal:Connect(function()
        state.FielxActive = Player:GetAttribute("FielxActive")

        self:HandleFielxChange()
    end))

    cleaner:Add(PlacingDeployableChangedSignal:Connect(function()
        state.DeployableActive = Player:GetAttribute("PlacingDeployable")

        self:HandleDeployableChange()
    end))
end

function AnimationState:HandleCrouchChange()
    local state = self.State
    local animationHandler = self.AnimationHandler

    if state.CrouchActive and not state.CrouchPlaying then
        for _, animationName in pairs(DefaultAnimations.Crouch) do
            animationHandler:Play(animationName)
            table.insert(self.State.PlayingAnimations, animationName)
        end

        state.CrouchPlaying = true
    elseif not state.CrouchActive and state.CrouchPlaying then
        for _, animationName in pairs(self.State.PlayingAnimations) do
            if string.find(animationName:lower(), "crouch") then -- could optimize by storing every sprint animation playing
                animationHandler:Stop(animationName)
            end
        end

        state.CrouchPlaying = false
    end
end

function AnimationState:HandleSprintChange()
    local state = self.State
    local animationHandler = self.AnimationHandler

    if state.SprintActive and not state.SprintPlaying then
        if state.CrouchActive then
            Player:SetAttribute("LocalCrouching", false)
        end

        if state.WeaponEquipped and state.WeaponName ~= "" and not state.Rolling then
            animationHandler:Play(state.WeaponName .. "sprintingMiddle")
            animationHandler:Play(state.WeaponName .. "sprintingTop")
            self.AnimationHandler:Stop(state.WeaponName.."equipMiddle")
            self.AnimationHandler:Stop(state.WeaponName.."equipTop")
            table.insert(self.State.PlayingAnimations, state.WeaponName .. "sprintingMiddle")
            table.insert(self.State.PlayingAnimations, state.WeaponName .. "sprintingTop")
            state.SprintPlaying = true
        end

    elseif not state.SprintActive and state.SprintPlaying then
        for _, animationName in pairs(self.State.PlayingAnimations) do
            if string.find(animationName:lower(), "sprinting") then -- could optimize by storing every sprint animation playing
                animationHandler:Stop(animationName)
            end
        end

        if state.WeaponEquipped and state.WeaponName ~= "" and not state.Rolling then
            self.AnimationHandler:Play(state.WeaponName.."equipMiddle")
            self.AnimationHandler:Play(state.WeaponName.."equipTop")
        end

        state.SprintPlaying = false
    end
end

function AnimationState:HandleRollingChange()
    local state = self.State
    local animationHandler = self.AnimationHandler
    state.SprintActive = false
    self:HandleSprintChange()


    local rollAnimation = animationHandler:Play(DefaultAnimations.Rolling)
    rollAnimation.Stopped:Wait()
    state.Rolling = false

    if state.WeaponEquipped and state.WeaponName ~= "" and not state.Rolling then
        self.AnimationHandler:Play(state.WeaponName.."equipMiddle")
        self.AnimationHandler:Play(state.WeaponName.."equipTop")
    end
end

function AnimationState:HandleThrowingChange()
    local state = self.State
    local animationHandler = self.AnimationHandler

    if state.GrenadeActive == true and not state.GrenadePlaying then
        local animation = animationHandler:Play(DefaultAnimations.Throw)
        state.GrenadePlaying = true
        animation.Stopped:Wait()
        Player:SetAttribute("Throwing", false)
        state.GrenadeActive = false
        state.GrenadePlaying = false
    end
    
end

function AnimationState:HandleWeaponChange()
    local newWeaponName = Player:GetAttribute("EquippedWeapon")
    local oldWeaponName = self.State.WeaponName

    local newWeaponStats = WeaponStats[newWeaponName]
    local oldWeaponStats = WeaponStats[oldWeaponName]

    if newWeaponName == self.State.WeaponName then return end
    
    if newWeaponName ~= self.State.WeaponName then
        if newWeaponName == "" then
            self.State.WeaponEquipped = false
        else
            self.State.WeaponEquipped = true
        end

        self.State.WeaponName = newWeaponName
    end

    if self.State.WeaponEquipped then
        self.AnimationHandler:Play(newWeaponName.."equippingArm")
        task.wait(0.3) -- equip time
        self.AnimationHandler:Stop(newWeaponName.."equippingArm")

        if self.State.SprintActive then
            self.AnimationHandler:Play(newWeaponName .. "sprintingMiddle")
            self.AnimationHandler:Play(newWeaponName .. "sprintingTop")
            self.State.SprintPlaying = true
        else
            self.AnimationHandler:Play(newWeaponName.."equipMiddle")
            self.AnimationHandler:Play(newWeaponName.."equipTop")
        end
    else
        for _, animationName in pairs(self.State.PlayingAnimations) do
            if string.find(animationName:lower(), "sprinting") then -- could optimize by storing every sprint animation playing
                self.AnimationHandler:Stop(animationName)
            end
        end

        self.AnimationHandler:Stop(oldWeaponName.."equipMiddle")
        self.AnimationHandler:Stop(oldWeaponName.."equipTop")

        if oldWeaponStats.Slot == 1 then
            self.AnimationHandler:Play(oldWeaponName.."equippingArm")
            task.wait(0.3) -- equip time
            self.AnimationHandler:Stop(oldWeaponName.."equippingArm")
        end
    end
end

function AnimationState:HandleFielxChange()
    if self.State.FielxActive and not self.State.FielxPlaying then
        self.AnimationHandler:Play("globalfdBottom")
		self.AnimationHandler:Play("globalfdMiddle")
		self.AnimationHandler:Play("globalfdTop")

        self.State.FielxPlaying = true
    elseif not self.State.FielxActive and self.State.FielxPlaying then
        self.AnimationHandler:Stop("globalfdBottom")
		self.AnimationHandler:Stop("globalfdMiddle")
		self.AnimationHandler:Stop("globalfdTop")

        self.State.FielxPlaying = false
    end
end

function AnimationState:HandleDeployableChange()
    if self.State.DeployableActive and not self.State.DeployablePlaying then
        self.AnimationHandler:Play("globaldeployableBottom")
        self.AnimationHandler:Play("globaldeployableMiddle")
        self.AnimationHandler:Play("globaldeployableTop")

        self.State.DeployablePlaying = true
    elseif not self.State.DeployableActive and self.State.DeployablePlaying then
        self.AnimationHandler:Stop("globaldeployableBottom")
        self.AnimationHandler:Stop("globaldeployableMiddle")
        self.AnimationHandler:Stop("globaldeployableTop")

        self.State.DeployablePlaying = false
    end
end

function AnimationState:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(AnimationState)

return AnimationState