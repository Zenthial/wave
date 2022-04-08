-- By Preston(seliso)
-- 1/11/2022
------------------------------------------------------------------------

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Configurations = Shared:WaitForChild("Configurations")

local bluejay = require(Shared:WaitForChild("bluejay"))
local Trove = require(Shared:WaitForChild("util"):WaitForChild("Trove"))
local Types = require(Shared:WaitForChild("Types"))

local DefaultAnimations = require(Configurations.DefaultAnimations) :: {[string]: Types.AnimationData}

local AnimationHandler = {}
AnimationHandler.__index = AnimationHandler
AnimationHandler.Name = "AnimationHandler"
AnimationHandler.Tag = "AnimationHandler"
AnimationHandler.Ancestor = Players

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

function AnimationHandler.new(player: Player)
    return setmetatable({
        Player = player,
        Animator = nil :: Animator,
        AnimationTracks = {},
        MarkerSignals = {},
        Loaded = false,
    }, AnimationHandler)
end

function AnimationHandler:Start()
    local root = self.Player.Character or self.Player.CharacterAdded:Wait()
    self.Root = root;
    self.AnimationFolder = createFolder(root)
    self.Animator = findAnimator(self.Root)
    if self.Animator == nil then
        local humanoid = self.Root:WaitForChild("Humanoid", 30)
        self.Animator = humanoid:WaitForChild("Animator", 30)
    end

    for _, animationData in pairs(DefaultAnimations) do
        self:Load(animationData)
    end
    
    self.Loaded = true
end

function AnimationHandler:Destroy()
    for _, cleaner in pairs(self.MarkerSignals) do
        cleaner:Destroy()
    end
    self.AnimationFolder:Destroy()
end

function AnimationHandler:Load(data: Types.AnimationData)
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

function AnimationHandler:Play(animationName: string): AnimationTrack
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

function AnimationHandler:Stop(animationName: string)
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

function AnimationHandler:DestroyTrack(animationName: string)
    if (self.AnimationTracks[animationName] == nil) then 
        warn("AnimationHandler: ".. animationName .." has already been removed or never existed!")
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

print("creating animation handler")
bluejay.create_component(AnimationHandler)

return AnimationHandler