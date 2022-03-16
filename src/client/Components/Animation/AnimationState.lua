local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Rosyn = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Rosyn"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))
local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))

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
    local events = {
        SprintChanged = Signal.new(),
        CrouchChanged = Signal.new(),
        ReloadChanged = Signal.new(),
        RollingChanged = Signal.new(),
        EquipChanged = Signal.new(),
        UnequipChanged = Signal.new(),
    }

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
        EquippedWeaponPointer = nil,
    }

    self.State = state
    self.Events = events
end

function AnimationState:EquipWeapon(weapon)
    self.State.Equipping = 1

    self.State.WeaponEquipped = true
    self.State.EquippedWeaponPointer = weapon

    self.Events.EquipChanged:Fire(true)
end

function AnimationState:UnequipWeapon()
    self.State.Equipping = -1

    self.State.WeaponEquipped = false
    -- self.State.EquippedWeaponPointer = nil

    self.Events.UnequipChanged:Fire(false)
end

function AnimationState:SetSprint(bool: boolean)
    self.State.SprintActive = bool

    self.Events.SprintChanged:Fire(bool)
end

function AnimationState:SetCrouch(bool: boolean)
    self.State.CrouchActive = bool

    self.Events.CrouchChanged:Fire(bool)
end

function AnimationState:SetReload(bool: boolean)
    self.State.ReloadActive = bool

    self.Events.ReloadChanged:Fire(bool)
end

function AnimationState:SetGrenade(bool: boolean)
    self.State.GrenadeActive = bool
end

function AnimationState:Destroy()
    self.Cleaner:Clean()
end

Rosyn.Register("Character", {AnimationState}, workspace)

return AnimationState