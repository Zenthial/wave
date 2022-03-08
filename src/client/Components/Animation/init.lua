-- By Preston(seliso)
-- 1/11/2022
------------------------------------------------------------------------

local Modules = script.Parent.Parent:WaitForChild("Modules")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Configurations = Shared:WaitForChild("Configurations")

local Rosyn = require(Shared:WaitForChild("Rosyn"))
local Trove = require(Shared:WaitForChild("util"):WaitForChild("Trove"))
local Types = require(Shared:WaitForChild("Types"))

local DefaultAnimations = require(Configurations.DefaultAnimations) :: {[string]: Types.AnimationData}

local Animation = {}
Animation.__index = Animation
Animation.__Tag = "Animation"

------------------------------------------------------------------------

local function findAnimator(root: Model): Animator?
    for _, obj in pairs(root:GetDescendants()) do
        if obj:IsA("Animator") then
            return obj;
        end
    end
    warn("Animator not found in object: ".. root.ClassName.." : ".. root.Name.. " under: "..root.Parent.Name)
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

-------------------------------------------------------------------------

function Animation.new(root: Model)
    return setmetatable({
        Root = root :: Model,
        Animator = nil :: Animator,
        AnimationTracks = {},
        AnimationFolder = createFolder(root),
        MarkerSignals = {},
    }, Animation)
end

function Animation:Initial()
    self.Animator = findAnimator(self.Root)
    if self.Animator == nil then
        local humanoid = self.Root:WaitForChild("Humanoid", 30)
        self.Animator = humanoid:WaitForChild("Animator", 30)
    end

    for _, animationData in pairs(DefaultAnimations) do
        self:Load(animationData)
    end
end

function Animation:Destroy()
    for _, cleaner in pairs(self.MarkerSignals) do
        cleaner:Destroy()
    end
    self.AnimationFolder:Destroy()
end

function Animation:Load(data: Types.AnimationData)
    local animation = createAnimation(data.TrackId)
    animation.Name = data.Name
    animation.Parent = self.AnimationFolder

    local track = self.Animator:LoadAnimation(animation)
    self.AnimationTracks[data.Name] = track

    -- print("Loaded ".. data.Name)

    if (#data.MarkerSignals <= 0 ) then return self end

    self.MarkerSignals[data.Name.."Signals"] = Trove.new()
    for str, func in pairs(data.MarkerSignals) do
        self.MarkerSignals[data.Name.."Signals"]:Add(track:GetMarkerReachedSignal(str):Connect(func))
    end

    return self
end

function Animation:Play(animationName: string): AnimationTrack
    if (self.AnimationTracks[animationName] == nil) then 
        warn("Unable to play animation: "..animationName.. " does not exist in this Animation Component!")
        return 
    end
    
    if (not self.AnimationTracks[animationName].IsPlaying == true) then
        self.AnimationTracks[animationName]:Play()
        print(string.format("Playing %s", animationName))
    end

    return self.AnimationTracks[animationName]
end

function Animation:Stop(animationName: string)
    if (self.AnimationTracks[animationName] == nil) then 
        warn("Unable to stop animation: "..animationName.. " does not exist in this Animation Component!")
        return 
    end

    if (self.AnimationTracks[animationName].IsPlaying) then
        self.AnimationTracks[animationName]:Stop()
        print(string.format("Stopping %s", animationName))
    end

    return self
end

function Animation:DestroyTrack(animationName: string)
    if (self.AnimationTracks[animationName] == nil) then 
        warn("Animation: ".. animationName .." has already been removed or never existed!")
        return 
    end

    self.AnimationTracks[animationName]:Destroy()
    self.AnimationTracks[animationName] = nil
    if (self.AnimationFolder:FindFirstChild(animationName)) then self.AnimationFolder:FindFirstChild(animationName):Destroy() end

    if (self.MarkerSignals[animationName.."Signals"]) then
        self.MarkerSignals[animationName.."Signals"]:Destroy()
        self.MarkerSignals[animationName.."Signals"] = nil
    end
end

Rosyn.Register("Character", {Animation}, workspace)

return Animation