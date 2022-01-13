local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rosyn = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Rosyn"))

local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util", 5):WaitForChild("Trove", 5))
local BehaviorTrees = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BehaviorTrees")
local TreeCreator = require(BehaviorTrees.TreeCreator)

local Animation = require(script.Parent.Animation)
local CoreGun = require(script.Parent.Parent.Modules.GunEngine.CoreGun)

local Player = game.Players.LocalPlayer

type ActiveAnimationsStruct = {
    SprintAnimationName: string,
    CrouchAnimationName: string,
    RollAnimationName: string,
    ReloadAnimationName: string
}

type AnimationTreeStruct = {
    SprintActive: boolean,
    SprintPlaying: boolean,

    Rolling: boolean,

    CrouchActive: boolean,
    CrouchPlaying: boolean,

    ReloadActive: boolean,
    ReloadPlaying: boolean,

    WeaponEquipped: boolean,
    EquippedWeaponPointer: typeof(CoreGun),

    Animator: typeof(Animation),

    ActiveAnimations: ActiveAnimationsStruct
}

local AnimationTree = {}
AnimationTree.__index = AnimationTree

function AnimationTree.new(root: any)
    return setmetatable({
        Root = root,

        Cleaner = Trove.new()
    }, AnimationTree)
end

function AnimationTree:Initial()
    local state: AnimationTreeStruct = {
        SprintActive = false,
        SprintPlaying = false,

        Rolling = false,

        CrouchActive = false,
        CrouchPlaying = false,

        ReloadActive = false,
        ReloadPlaying = false,

        WeaponEquipped = false,
        EquippedWeaponPointer = nil,

        ActiveAnimations = {
            SprintAnimationName = nil,
            CrouchAnimationName = nil,
            RollAnimationName = nil,
            ReloadAnimationName = nil
        },

        Animator = Rosyn.AwaitComponentInit(Player.Character or Player.CharacterAdded:Wait(), Animation)
    }

    local cleaner = self.Cleaner :: typeof(Trove)
    cleaner:Add(Player.CharacterAdded:Connect(function(character)
        state.Animator = Rosyn.AwaitComponentInit(character, Animation)
    end))

    self.State = state
    self:StartTree()
end

function AnimationTree:StartTree()
    task.spawn(function()
        local cleaner = self.Cleaner :: typeof(Trove)

        local animationTree = TreeCreator:Create(BehaviorTrees.Trees.AnimationTree)
        -- tree payload to pass possible additional data
        local treePayload = {
            State = self.State
        }

        local treeRunning = false
        local function update(_, _dt)
            if treeRunning then return end
            local result = animationTree:Run(treePayload)
            treeRunning = (result == 3)
        end

        cleaner:Add(RunService.Stepped:Connect(update))
        cleaner:Add(function()
            animationTree:Abort()
        end)
    end)
end

function AnimationTree:Destroy()
    self.Cleaner:Destroy()
end

Rosyn.Register("AnimationTree", {AnimationTree})

return AnimationTree