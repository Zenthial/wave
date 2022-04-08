local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rosyn = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Rosyn"))

local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))
local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))
local BehaviorTrees = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BehaviorTrees")
local TreeCreator = require(BehaviorTrees.BehaviorTreeCreator)

local WeaponStatsTable = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats"))

local Player = game.Players.LocalPlayer

type WeaponStats = WeaponStatsTable.WeaponStats_T

type ActiveAnimationsStruct = {
    SprintAnimationName: string,
    CrouchAnimationName: string,
    RollAnimationName: string,
    ReloadAnimationName: string,
    EquipAnimationName: string,
    HoldAnimationName: string
}

type AnimationTreeStruct = {
    Equipping: number, -- 0 = not equipping, 1 = equipping, -1 = unequipping
    
    SprintActive: boolean,
    SprintPlaying: boolean,

    Rolling: boolean,

    CrouchActive: boolean,
    CrouchPlaying: boolean,

    ReloadActive: boolean,
    ReloadPlaying: boolean,

    WeaponEquipped: boolean,
    EquippedWeaponPointer: any, -- CoreGun but cannot define it without recursively requiring

    Animator: typeof(Animation),

    ActiveAnimations: ActiveAnimationsStruct
}

local AnimationTree = {}
AnimationTree.__index = AnimationTree
AnimationTree.__Tag = "AnimationTree"

function AnimationTree.new(root: any)
    return setmetatable({
        Root = root,

        Cleaner = Trove.new(),

        Events = {
            SprintChanged = Signal.new(),

            CrouchChanged = Signal.new(),

            ReloadChanged = Signal.new(),

            RollingChanged = Signal.new(),

            EquipChanged = Signal.new(),
            UnequipChanged = Signal.new(),
        }
    }, AnimationTree)
end

function AnimationTree:Start()
    local State: AnimationTreeStruct = {
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

        ActiveAnimations = {
            SprintAnimationName = nil,
            CrouchAnimationMiddleName = nil,
            CrouchAnimationBottomName = nil,
            RollAnimationName = nil,
            ReloadAnimationName = nil,
            ThrowAnimationName = nil
        },

        Animator = Rosyn.AwaitComponentInit(Player.Character or Player.CharacterAdded:Wait(), Animation)
    }
    
    local cleaner = self.Cleaner :: typeof(Trove)
    
    local movementComponent = Rosyn.AwaitComponentInit(Player, Movement)

    cleaner:Add(movementComponent.Events.SprintChanged:Connect(function(bool)
        State.SprintActive = bool
    end))

    cleaner:Add(movementComponent.Events.CrouchChanged:Connect(function(bool)
        State.CrouchActive = bool
    end))

    self.State = State
    self:InitTree()
end

function AnimationTree:EquipWeapon(weapon)
    self.State.Equipping = 1

    self.State.WeaponEquipped = true
    self.State.EquippedWeaponPointer = weapon

    self.Events.EquipChanged:Fire(true)
end

function AnimationTree:UnequipWeapon()
    self.State.Equipping = -1

    self.State.WeaponEquipped = false
    -- self.State.EquippedWeaponPointer = nil

    self.Events.UnequipChanged:Fire(false)
end

function AnimationTree:SetSprint(bool: boolean)
    self.State.SprintActive = bool

    self.Events.SprintChanged:Fire(bool)
end

function AnimationTree:SetCrouch(bool: boolean)
    self.State.CrouchActive = bool

    self.Events.CrouchChanged:Fire(bool)
end

function AnimationTree:SetReload(bool: boolean)
    self.State.ReloadActive = bool

    self.Events.ReloadChanged:Fire(bool)
end

function AnimationTree:SetGrenade(bool: boolean)
    self.State.GrenadeActive = bool
end

function AnimationTree:InitTree()
    task.spawn(function()
        local cleaner = self.Cleaner :: typeof(Trove)

        -- tree payload to pass possible additional data
        local treeState = {
            Tree = self,
            Blackboard = self.State,
        }

        local animationTree = TreeCreator:Create(BehaviorTrees.Trees.PlayerAnimationTree)

        local treeRunning = false
        local function update(_, _dt)
            if treeRunning then return end
            local result = animationTree:Run(treeState)
            treeRunning = (result == 3)
        end

        cleaner:Add(RunService.Stepped:Connect(update))
        cleaner:Add(function()
            print("aborting")
            animationTree:Abort()
        end)
    end)
end

function AnimationTree:Destroy()
    self.Cleaner:Destroy()
end

Rosyn.Register("Character", {AnimationTree}, workspace)

return AnimationTree