-- By Preston(seliso)
-- 1/11/2022
------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Configurations = Shared:WaitForChild("Configurations")

local tcs = require(Shared:WaitForChild("tcs"))

local DefaultAnimations = require(Configurations.DefaultAnimations) :: {[string]: Animation}

local AnimationHandler = {}
AnimationHandler.__index = AnimationHandler
AnimationHandler.Name = "AnimationHandler"
AnimationHandler.Tag = "AnimationHandler"
AnimationHandler.Ancestor = game

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
        NumTracks = 0,
        MarkerSignals = {},
        Loaded = false,
    }, AnimationHandler)
end

function AnimationHandler:Start()
    local root = self.Player
    if self.Player:IsA("Player") then
        root = self.Player.Character or self.Player.CharacterAdded:Wait()
    end

    self.Root = root;
    self.AnimationFolder = createFolder(root)
    self.Animator = findAnimator(self.Root)
    if self.Animator == nil then
        local humanoid = self.Root:WaitForChild("Humanoid", 30)
        self.Animator = humanoid:WaitForChild("Animator", 30)
    end

    if self.Player:IsA("Player") then
        for _, animation in pairs(DefaultAnimations) do
            self:Load(animation)
        end
    end
    
    self.Loaded = true
end

function AnimationHandler:Destroy()
    for _, cleaner in pairs(self.MarkerSignals) do
        cleaner:Destroy()
    end
    self.AnimationFolder:Destroy()
end

function AnimationHandler:Load(animation: Animation)
    animation.Parent = self.AnimationFolder

    if self.Animator == nil then
        repeat
            task.wait()
        until self.Animator ~= nil
    end
    local track = self.Animator:LoadAnimation(animation)
    if self.AnimationTracks[animation.Name] then
        self.AnimationTracks[animation.Name]:Stop()
    end
    self.AnimationTracks[animation.Name] = track
    self.NumTracks += 1

    -- print("Loaded ".. animation.Name)

    return self
end

function AnimationHandler:Play(animationName: string): AnimationTrack
    if self.AnimationTracks[animationName] == nil then 
        warn("Unable to play animation: "..animationName.. " does not exist in this Animation Component!")
        return 
    end
    
    if self.AnimationTracks[animationName].IsPlaying == false then
        self.AnimationTracks[animationName]:Play()
        print(string.format("Playing %s", animationName))
    end

    return self.AnimationTracks[animationName]
end

function AnimationHandler:IsPlaying(animationName: string): boolean
    if self.AnimationTracks[animationName] == nil then 
        return false
    end

    return self.AnimationTracks[animationName].IsPlaying
end

function AnimationHandler:Stop(animationName: string)
    if self.AnimationTracks[animationName] == nil then 
        warn("Unable to stop animation: "..animationName.. " does not exist in this Animation Component!")
        return 
    end

    if self.AnimationTracks[animationName].IsPlaying then
        self.AnimationTracks[animationName]:Stop()
        -- print(string.format("Stopping %s", animationName))
    end

    return self
end

function AnimationHandler:DestroyTrack(animationName: string)
    if self.AnimationTracks[animationName] == nil then 
        warn("AnimationHandler: ".. animationName .." has already been removed or never existed!")
        return 
    end

    self.AnimationTracks[animationName]:Destroy()
    self.AnimationTracks[animationName] = nil
    if self.AnimationFolder:FindFirstChild(animationName) then self.AnimationFolder:FindFirstChild(animationName):Destroy() end

    if self.MarkerSignals[animationName.."Signals"] then
        self.MarkerSignals[animationName.."Signals"]:Destroy()
        self.MarkerSignals[animationName.."Signals"] = nil
    end
end

print("creating animation handler")
tcs.create_component(AnimationHandler)

return AnimationHandler