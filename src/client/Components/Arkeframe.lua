local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Rosyn = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Rosyn"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))
local Input = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Input"))

local ANIMATION_IDS = {
    Fall = 8380919597,
    Idle_Slam = 8380920708
}

local function createAnimation(id): Animation
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://"..tostring(id)
    
    return animation
end

local Arkeframe = {}
Arkeframe.__index = Arkeframe

function Arkeframe.new(root: Model)
    return setmetatable({
        Root = root,

        HumanoidRootPart = root:WaitForChild("HumanoidRootPart"),
        Humanoid = root:WaitForChild("Humanoid") :: Humanoid,
        Animator = root.Humanoid:WaitForChild("Animator") :: Animator,
        Torso = root:WaitForChild("Torso"),

        Animations = {} :: {AnimationTrack},
        ActiveAnimations = {} :: {[string]: AnimationTrack},

        Cleaner = Trove.new() :: typeof(Trove)
    }, Arkeframe)
end

function Arkeframe:Initial()
    local animator = self.Animator :: Animator
    for key, val in pairs(ANIMATION_IDS) do
        self.Animations[key] = animator:LoadAnimation(createAnimation(val))
    end

    self:PlayAnimation("Fall")
    task.wait(1)
    self:PlayAnimation("Idle_Slam")
    self:StopAnimation("Fall")
end

function Arkeframe:PlayAnimation(Name: string)
    local track = self.Animations[Name] :: AnimationTrack
    self.ActiveAnimations[Name] = track
    track:Play()
end

function Arkeframe:StopAnimation(Name: string)
    local track = self.ActiveAnimations[Name] :: AnimationTrack
    if track ~= nil then
        track:Stop()
        self.ActiveAnimations[Name] = nil
    end
end

function Arkeframe:Destroy()
    self.Cleaner:Destroy()
end

Rosyn.Register("Arkeframe", {Arkeframe}, workspace)

return Arkeframe