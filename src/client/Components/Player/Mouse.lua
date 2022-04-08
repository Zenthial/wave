local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local bluejay = require(Shared.bluejay)

local WeaponStatsModule = require(Shared:WaitForChild("Configurations"):WaitForChild("WeaponStats"))
type WeaponStats = WeaponStatsModule.WeaponStats_T

local RAYCAST_MAX_DISTANCE = 2000
local DEFAULT_AIMBUFF = 3
local DEFAULT_RECOIL = 0

local Mouse = {}
Mouse.__index = Mouse
Mouse.Name = "Mouse"
Mouse.Tag = "Player"
Mouse.Needs = {"Cleaner"}
Mouse.Ancestor = Players

function Mouse.new(Player: Player)
    return setmetatable({
        Player = Player,

        MouseObject = Player:GetMouse(),
    }, Mouse)
end

function Mouse:Start()
    local mouseObject = self.MouseObject :: Mouse
    self.Cleaner:Add(mouseObject.Move:Connect(function()
        -- mouse move
    end))

    print("mouse initialized")
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

function Mouse:Raycast(raycastStart: Vector3, weaponStats: WeaponStats, aiming: boolean, currentRecoil: number?, aimBuff: number?): (BasePart, Vector3)
    local character = self.Player.Character
    if not character then return end
    local head = character:FindFirstChild("Head") :: BasePart
    if not head then return end

    local mouseObject = self.MouseObject :: Mouse
    local mousePosition = mouseObject.Hit.Position
    local preDistance = (raycastStart - mousePosition).Magnitude

    if currentRecoil == nil then currentRecoil = DEFAULT_RECOIL end
    if aimBuff == nil then aimBuff = DEFAULT_AIMBUFF end

    local aim = mouseObject.Hit.Position + self:Spread(preDistance, weaponStats.MinSpread, weaponStats.MaxSpread, aiming, currentRecoil, aimBuff)
    local start = head.Position
    
    local collectionServiceIgnore = CollectionService:GetTagged("Ignore")
    local ignore = {}
    for _, thing in pairs(collectionServiceIgnore) do table.insert(ignore, thing) end
    for _, thing in pairs(character:GetChildren()) do table.insert(ignore, thing) end

    local raycast = Ray.new(start, (aim - start).Unit * RAYCAST_MAX_DISTANCE)
    local hit, position = workspace:FindPartOnRayWithIgnoreList(raycast, ignore)

    return hit, position
end

function Mouse:Destroy()
    self.Cleaner:Destroy()
end

bluejay.create_component(Mouse)

return Mouse