local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Rosyn = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Rosyn"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))
local Shake = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Shake"))

local Arkeframe = require(script.Parent.Parent.Components.Arkeframe)

local Player = game.Players.LocalPlayer

local Camera = game.Workspace.CurrentCamera
local ArkeframeModel = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Arkeframe")
local ImpactParticles = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Particles"):WaitForChild("ImpactParticles")
local Explosion = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Particles"):WaitForChild("Explosion2")
local Smoke = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Particles"):WaitForChild("Smoke")
local Light = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Particles"):WaitForChild("Light")

local TWEEN_LENGTH = 3
local HEIGHT = 300
local EXPLOSIONS = 17

local function emit(p)
    for _, emitter in pairs(p:GetChildren()) do
        if emitter:IsA("ParticleEmitter") then
            emitter:Emit()
        end
    end
end

local function add(part)
    for _, particle in pairs(ImpactParticles:GetChildren()) do
        particle:Clone().Parent = part
    end
end

local function lightAnimation(position)
    local light = Light:Clone()
    light.Position = position

    local entry = Instance.new("Sound")
    entry.SoundId = "rbxassetid://337163436"
    entry.Volume = 3
    entry.Parent = light
    entry:Play()

    light.Parent = workspace

    local t1 = TweenService:Create(light.ParticleEmitter, TweenInfo.new(2), {Rate = 20})
    t1:Play()
    t1.Completed:Wait()

    local t2 = TweenService:Create(light.ParticleEmitter, TweenInfo.new(2), {Rate = 80})
    t2:Play()
    t2.Completed:Wait()

    task.spawn(function()
        TweenService:Create(light.ParticleEmitter, TweenInfo.new(1), {Rate = 0}):Play()
        TweenService:Create(light.ParticleEmitter2, TweenInfo.new(1), {Rate = 0}):Play()
        local t3 = TweenService:Create(light.ParticleEmitter2, TweenInfo.new(1), {Rate = 0})
        t3:Play()
        t3.Completed:Wait()
        light:Destroy()
    end)
end

local function createFrame(cframe: CFrame)
    local internalCleaner = Trove.new()

    local c = (cframe + Vector3.new(60, HEIGHT, 0)) * CFrame.Angles(0, math.pi, 0)
    local frame = ArkeframeModel:Clone() :: Model
    frame:SetPrimaryPartCFrame(c)
    frame.HumanoidRootPart.Anchored = false

    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://6555423202"
    sound.Volume = 11
    sound.Parent = frame.HumanoidRootPart
    sound:Stop()

    local entry = Instance.new("Sound")
    entry.SoundId = "rbxassetid://337163436"
    entry.Volume = 5
    entry.Parent = frame.HumanoidRootPart
    entry:Play()

    local explosionSound = Instance.new("Sound")
    explosionSound.SoundId = "rbxassetid://335657174"
    explosionSound.Parent = frame.HumanoidRootPart
    explosionSound.Volume = 5
    explosionSound:Stop()

    internalCleaner:Add(entry)
    internalCleaner:Add(explosionSound)

    task.spawn(function()
        add(frame.LeftKnee)
        add(frame.RightKnee)
        add(frame.RightUpperPalm)
    end)

    lightAnimation(c.Position)

    frame.Parent = workspace

    local frameComponent = Rosyn.AwaitComponentInit(frame, Arkeframe) :: typeof(Arkeframe)
    frameComponent:PlayAnimation("Fall")

    -- Camera.CameraType = Enum.CameraType.Scriptable
    -- Camera.CFrame = Camera.CFrame + Vector3.new(0, 10, 0)
    -- internalCleaner:BindToRenderStep("FrameCameraAnimation", 100, function(dt)
    --     Camera.CFrame = CFrame.new(Camera.CFrame.Position, frame.HumanoidRootPart.Position)
    -- end)

    -- internalCleaner:Add(function()
    --     task.wait(0.2)
    --     Camera.CameraType = Enum.CameraType.Custom
    -- end)

    local gyro = Instance.new("BodyGyro")
    gyro.P = 10000
    gyro.MaxTorque = Vector3.new(10000, 10000, 10000)
    gyro.D = 100
    gyro.Parent = frame.HumanoidRootPart
    internalCleaner:BindToRenderStep("TitanLookAt", 100, function(dt)
        -- this line could break if the player dies while summoning
        gyro.CFrame = CFrame.new(Vector3.new(Player.Character.HumanoidRootPart.Position.X, 0, Player.Character.HumanoidRootPart.Position.Z))
    end)

    local t = TweenService:Create(frame.HumanoidRootPart, TweenInfo.new(TWEEN_LENGTH, Enum.EasingStyle.Circular, Enum.EasingDirection.In), {CFrame = c - Vector3.new(0, HEIGHT-13, 0)})
    t:Play()

    task.spawn(function()
        Explosion:Clone().Parent = frame.LeftBackFoot
        Smoke:Clone().Parent = frame.LeftBackFoot
        Explosion:Clone().Parent = frame.RightBackFoot
        Smoke:Clone().Parent = frame.RightBackFoot
        task.wait(1)
        for i = 0, EXPLOSIONS do
            task.wait(0.1)
            explosionSound:Stop()
            emit(frame.RightBackFoot)
            emit(frame.LeftBackFoot)
            explosionSound:Play()
        end
    end)

    task.delay(TWEEN_LENGTH - 0.2, function()
        frameComponent:StopAnimation("Fall")
        frameComponent:PlayAnimation("Idle_Slam")

        frame.HumanoidRootPart.Anchored = true
    end)
    
    t.Completed:Wait()
    
    task.spawn(function()
        emit(frame.LeftKnee)
        emit(frame.RightKnee)
        emit(frame.RightUpperPalm)
    end)

    sound:Play()
    sound.Stopped:Connect(function()
        sound:Destroy()
    end)
    entry:Stop()

    internalCleaner:Clean()

    local priority = Enum.RenderPriority.Last.Value

    if (frame.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude < 150 then
        local camStart = Camera.CFrame

        local shake = Shake.new()
        shake.FadeInTime = 0
        shake.FadeOutTime = .75
        shake.Frequency = 0.075
        shake.Amplitude = 4
        shake.RotationInfluence = Vector3.new(0.15, 0.15, 0.15)

        shake:Start()
        shake:BindToRenderStep(Shake.NextRenderName(), priority, function(pos, rot, isDone)
            local distance = (frame.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude / 150
            rot = Shake.InverseSquare(rot, distance)
            pos = Shake.InverseSquare(pos, distance)
            Camera.CFrame *= CFrame.new(pos) * CFrame.Angles(rot.X, rot.Y, rot.Z)

            -- if isDone then
            --     Camera.CFrame = camStart
            -- end
        end)
    end   
end

return createFrame