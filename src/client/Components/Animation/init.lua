-- By Preston(seliso)
-- 1/11/2022
------------------------------------------------------------------------

local Modules = script.Parent.Parent:WaitForChild("Modules", 5)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared", 5)

local Rosyn = require(Shared:WaitForChild("Rosyn", 5))
local Trove = require(Shared:WaitForChild("util", 5):WaitForChild("Trove", 5))
local Input = require(Shared:WaitForChild("util", 5):WaitForChild("Input", 5))

local types = require(script:WaitForChild("Types"))

local Animation = {}
Animation.__index = Animation

------------------------------------------------------------------------

local function findAnimator(root: Model): Animator?
    for _, obj in pairs(root:GetDescendants()) do
        if obj:IsA("Animator") then
            return obj;
        end
    end
    warn("Animator not found in object: ".. root.ClassName.." : ".. root.Name.. " under: "..root.Parent)
    return nil;
end

local function createAnimation(id): Animation
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://"..tostring(id)  
    return animation
end

local function createFolder(parent): Folder
    local folder = Instance.new("Folder")
    folder.Name = "AnimationFolder"
    folder.Parent = parent
    
    return folder
end

------------------------------------------------------------------------

function Animation.new(root: Model)
    return setmetatable({
        Root = root,
        Animator = nil,
        AnimationTracks = {},
        AnimationFolder = createFolder(root),
        Cleaner = Trove.new() :: typeof(Trove),
    }, Animation)
end

function Animation:Initial()
    self.Animator = findAnimator(self.Root)
end

function Animation:Destroy()
    self.Cleaner:Destroy()
end

function Animation:LoadAnimation(data: types.AnimationDataTab)
    local animation = createAnimation(data.TrackId)
    animation.Name = data.Name
    animation.Parent = self.AnimationFolder

    local track = self.Animator:LoadAnimation(animation)
    self.AnimationTracks[data.Name] = track

    for str, func in pairs(data.MarkerSignals) do
        self.Cleaner:Add(track:GetMarkerReachedSignal(str):Connect(func))
    end

    return self
end

function Animation:PlayAnimation(animationName: string)
    if (self.AnimationTracks[animationName]) then 
        warn("Unable to play animation: "..animationName.. " does not exist in this Animation Component!")
        return 
    end
    self.AnimationTracks[animationName]:Play()
end

function Animation:StopAnimation(animationName: string)
    if (self.AnimationTracks[animationName]) then 
        warn("Unable to stop animation: "..animationName.. " does not exist in this Animation Component!")
        return 
    end
    
    if (self.AnimationTracks[animationName].IsPlaying) then
        self.AnimationTracks[animationName]:Stop()
    end
end

return Animation