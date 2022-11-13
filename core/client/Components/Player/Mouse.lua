local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local tcs = require(Shared.tcs)

local WeaponStatsModule = require(Shared:WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))
type WeaponStats = WeaponStatsModule.WeaponStats_T

local RAYCAST_MAX_DISTANCE = 2000
local DEFAULT_AIMBUFF = 3
local DEFAULT_RECOIL = 0

local Mouse = {}
Mouse.__index = Mouse
Mouse.Name = "Mouse"
Mouse.Tag = "Player"
Mouse.Ancestor = Players

function Mouse.new(Player: Player)
    return setmetatable({
        Player = Player,
    }, Mouse)
end

function Mouse:Start()
    self.MouseObject = self.Player:GetMouse()

    self:BodyGyroHooks()
    print("mouse initialized")
end

function Mouse:BodyGyroHooks()
    local character = self.Player.Character or self.Player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid") :: Humanoid
    local bodyGyro = tcs.get_component(character, "BodyGyro")

    local moveConnection = nil
    self.Cleaner:Add(humanoid.Changed:Connect(function(prop)
        if prop == "AutoRotate" then
            if humanoid.AutoRotate == false then
                moveConnection = self.MouseObject.Move:Connect(function()
                    bodyGyro:SetRotationTarget(self.MouseObject.Hit.Position)
                end)
            else
                if moveConnection then
                    moveConnection:Disconnect()
                end
            end
        end
    end))
end

function Mouse:Spread(dist: number, minSpread: number, maxSpread: number, aiming: boolean, currentRecoil: number?, aimBuff: number?): Vector3
    if aiming then
        assert(aimBuff, "AimBuff not provided")
        minSpread /= aimBuff
        maxSpread /= aimBuff
    end

    local spread = 2
    if currentRecoil then
        spread = maxSpread * (currentRecoil/100) + minSpread
    end

    math.randomseed(tick())
    local x = math.random(-(spread/10) * dist, (spread/10) * dist)/10
	local y = math.random(-(spread/10) * dist, (spread/10) * dist)/10
	local z = math.random(-(spread/10) * dist, (spread/10) * dist)/10
	return Vector3.new(x,y,z)
end

function Mouse:GetPosition()
    return self.MouseObject.Hit.Position    
end

function Mouse:Raycast(raycastStart: Vector3, weaponStats: WeaponStats?, aiming: boolean?, currentRecoil: number?, aimBuff: number?): (BasePart, Vector3)
    local character = self.Player.Character
    if not character then return end
    local head = character:FindFirstChild("Head") :: BasePart
    if not head then return end

    if weaponStats == nil then weaponStats = {} end

    local mouseObject = self.MouseObject :: Mouse
    local mousePosition = mouseObject.Hit.Position
    local preDistance = (raycastStart - mousePosition).Magnitude

    if currentRecoil == nil then currentRecoil = DEFAULT_RECOIL end
    if aimBuff == nil then aimBuff = DEFAULT_AIMBUFF end

    local aim = mouseObject.Hit.Position + self:Spread(preDistance, weaponStats.MinSpread or 0, weaponStats.MaxSpread or 0, aiming or false, currentRecoil, aimBuff)
    local start = head.Position

    local raycast = Ray.new(start, (aim - start).Unit * RAYCAST_MAX_DISTANCE)
    local hit, position = workspace:FindPartOnRayWithIgnoreList(raycast, CollectionService:GetTagged("Ignore"))

    return hit, position
end

function Mouse:Destroy()
    self.Cleaner:Destroy()
end

tcs.create_component(Mouse)

return Mouse
