local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared", 5)
local Rosyn = require(Shared:WaitForChild("Rosyn", 5))

local WeaponStats = require(Shared:WaitForChild("Configurations"):WaitForChild("WeaponStats"))
local Trove = require(Shared:WaitForChild("util"):WaitForChild("Trove"))

local Health = require(game.ServerScriptService.Server.Components.Player.Health)

local ServerComm = require(script.Parent.ServerComm)
local comm = ServerComm.GetServerComm()

local Welder = require(script.Welder)

local GUN_ENGINE_ATTRIBUTES = {
    NumWeaponsEquipped = 0,
    HasPrimaryWeapon = false,
    Spotted = false,
    Restrained = false,
    PlacingDeployable = false,
}

local function setupPlayer(player: Player)
    for attributeName, value in pairs(GUN_ENGINE_ATTRIBUTES) do
        player:SetAttribute(attributeName, value)
    end
end

local drawRaySignal = comm:CreateSignal("DrawRay")

comm:BindFunction("WeldWeapon", function(player: Player, weapon: Model, toBack: boolean)
    -- could be abused somehow?
    -- actually probably not because you'd have to weld something that exists on the server and has weapon stats
    -- an intelligent exploiter could possibly give themselves a different cosmetic appearance if someone has a cool weapon, but it wouldn't do much else
    local character = player.Character
    if character == nil then
        return false
    end
    local result = Welder:WeldWeapon(character, weapon, toBack)
    return result
end)

comm:BindFunction("AttemptDealDamage", function(player: Player, healthComponentPart: BasePart, weaponName: string)
    local healthComponent = Rosyn.GetComponent(healthComponentPart, Health) :: typeof(Health)
    local stats = WeaponStats[weaponName]
    if stats and stats.Damage then
        healthComponent:TakeDamage(stats.Damage)
    end
end)


local GunEngine = {}

function GunEngine:Start()
    for _, player in pairs(Players:GetPlayers()) do
        setupPlayer(player)
    end

    local cleaner = Trove.new()
    cleaner:Add(Players.PlayerAdded:Connect(setupPlayer))

    local bulletFolder = Instance.new("Folder")
    bulletFolder.Name = "Bullets"
    bulletFolder.Parent = workspace

    drawRaySignal:Connect(function(player: Player, startPosition: Vector3, endPosition: Vector3, weaponName: string)
        -- could be spammed fired to cause people to lag, check some kind of script invocation timer thingy, could make sure that the time between shots isn't shorter than the fire rate
        -- something like LastShot = tick(), if currentShot - LastShot < fireRate then kick, though probably would just want to watch them
        drawRaySignal:FireExcept(player, startPosition, endPosition, weaponName)
    end)
end

function GunEngine:WeldWeapon(character: Model, weapon: Model, toBack: boolean)
    -- could be abused somehow?
    -- actually probably not because you'd have to weld something that exists on the server and has weapon stats
    -- an intelligent exploiter could possibly give themselves a different cosmetic appearance if someone has a cool weapon, but it wouldn't do much else
    local result = Welder:WeldWeapon(character, weapon, toBack)
    return result
end

return GunEngine