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
    local PlacingChangedSignal = Player:GetAttributeChangedSignal("Placing")

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

    print(state)
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
    
    Player:SetAttribute("LocalSprinting", false)
    Player:SetAttribute("LocalCrouching", false)
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
        task.wait(newWeaponStats.EquipTime)
        self.AnimationHandler:Stop(newWeaponName.."equippingArm")

        self.AnimationHandler:Play(newWeaponName.."equipMiddle")
        self.AnimationHandler:Play(newWeaponName.."equipTop")
    else
        self.AnimationHandler:Stop(oldWeaponName.."equipMiddle")
        self.AnimationHandler:Stop(oldWeaponName.."equipTop")

        if oldWeaponStats.Slot == 1 then
            self.AnimationHandler:Play(oldWeaponName.."equippingArm")
            task.wait(oldWeaponStats.EquipTime)
            self.AnimationHandler:Stop(oldWeaponName.."equippingArm")
        end
    end
end

function AnimationState:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(AnimationState)

return AnimationState