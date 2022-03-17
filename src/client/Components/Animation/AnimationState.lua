local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Rosyn = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Rosyn"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))
local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))
local WeaponStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats"))

local DefaultAnimations = require(script.Parent.DefaultAnimationNames)
local AnimationHandler = require(script.Parent.AnimationHandler)
local AnimationTypes = require(script.Parent.AnimationTypes)

type State_T = AnimationTypes.AnimationTreeStruct

local Player = Players.LocalPlayer

local AnimationState = {}
AnimationState.__index = AnimationState
AnimationState.Tag = "AnimationState"

function AnimationState.new(root: any)
    return setmetatable({
        Root = root,

        Cleaner = Trove.new()
    }, AnimationState)
end

function AnimationState:Initial()
    local cleaner = self.Cleaner :: typeof(Trove)

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

    self.AnimationHandler = Rosyn.AwaitComponentInit(self.Root, AnimationHandler)

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
end

function AnimationState:HandleCrouchChange()
    local state = self.State :: State_T
    local animationHandler = self.AnimationHandler :: typeof(AnimationHandler)
end

function AnimationState:HandleSprintChange()
    local state = self.State :: State_T
    local animationHandler = self.AnimationHandler :: typeof(AnimationHandler)

    if state.SprintActive and not state.SprintPlaying then
        if state.CrouchActive then
            Player:SetAttribute("LocalCrouching", false)
        end

        if state.WeaponEquipped and state.WeaponName ~= "" and not state.Rolling then
            animationHandler:Play(state.WeaponName .. "Sprint")
            table.insert(self.PlayingAnimations, state.WeaponName .. "Sprint")
            state.SprintPlaying = true
        end

    elseif not state.SprintActive and state.SprintPlaying then
        for _, animationName in pairs(self.PlayingAnimations) do
            if string.find(animationName:lower(), "sprint") then -- could optimize by storing every sprint animation playing
                animationHandler:Stop(animationName)
            end
        end

        state.SprintPlaying = false
    end
end

function AnimationState:HandleRollingChange()
    local state = self.State :: State_T
    local animationHandler = self.AnimationHandler :: typeof(AnimationHandler)
    state.SprintActive = false
    self:HandleSprintChange()

    
    Player:SetAttribute("LocalSprinting", false)
    Player:SetAttribute("LocalCrouching", false)
end

function AnimationState:Destroy()
    self.Cleaner:Clean()
end

Rosyn.Register("Character", {AnimationState}, workspace)

return AnimationState