local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Rosyn = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Rosyn"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))
local Input = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Input"))

local MainHUD = require(script.Parent.UI.MainHUD)

local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local ANIMATION_IDS = {
    Fall = 8380919597,
    Idle_Slam = 8380920708,
    Pickup = 8390388861,
    Default = 8396419394
}
local VOICELINES = {
    Welcome = "rbxassetid://8396443461"
}
local PROMPT_DISTANCE = 20
local PICKUP_KEYCODE = Enum.KeyCode.X

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

        Active = false, -- says if the titan is being piloted or not

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

    local mainHUD = PlayerGui:WaitForChild("MainHUD")
    self.mainHUDComponent = Rosyn.GetComponent(mainHUD, MainHUD) :: typeof(MainHUD)

    local nearTitan = false
    local inputComponent = nil
    self.Cleaner:BindToRenderStep("TitanCheckIfNear", 100, function()
        if Player.Character and self.Active == false then
            local char = Player.Character
            local dist = (self.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
            if dist <= PROMPT_DISTANCE then
                if not nearTitan then
                    nearTitan = true
                    inputComponent = self.mainHUDComponent:PromptKeyboardInput("Enter the Arkeframe", PICKUP_KEYCODE.Name)
                end

                if Input.Keyboard:IsKeyDown(PICKUP_KEYCODE) then
                    self:Pickup()
                end
            else
                if nearTitan then
                    nearTitan = false
                    if inputComponent then
                        inputComponent:Destroy()
                    end
                end
            end
        end
    end)
end

function Arkeframe:Pickup()
    self.Active = true
    local camera = workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Scriptable
    TweenService:Create(camera, TweenInfo.new(0.2), {CFrame = self.Root.Camera.CFrame}):Play()
    task.wait(0.2)
    self:StopAnimation("Idle_Slam")
    RunService:BindToRenderStep("TitanPickupCamera", 100, function()
        camera.CFrame = self.Root.Camera.CFrame
    end)
    local t = self:PlayAnimation("Pickup")
    task.wait(t.Length)
    RunService:UnbindFromRenderStep("TitanPickupCamera")
    self:Startup()
end

function Arkeframe:Startup()
    self:PlayLocalSound(VOICELINES.Welcome)
    self:PlayAnimation("Default")
    
    -- local save = Player.Character
    -- save.Parent = ReplicatedStorage
    -- Player.Character = self.Root
    
    -- Player.CameraMode = Enum.CameraMode.LockFirstPerson
    local camera = workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Scriptable
    camera.CFrame = self.Root.Camera.CFrame
end

function Arkeframe:PlayLocalSound(soundId)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Looped = false
    sound.Volume = 10
    sound.Stopped:Connect(function() sound:Destroy() end)
    sound.Parent = game.SoundService
    sound:Play()
end

function Arkeframe:PlayAnimation(Name: string): AnimationTrack
    local track = self.Animations[Name] :: AnimationTrack
    if track ~= nil then
        self.ActiveAnimations[Name] = track
        track:Play()
        return track
    else
        error("Animation "..Name.." does not exist")
    end
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