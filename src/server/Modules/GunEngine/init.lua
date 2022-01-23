local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared", 5)
local Rosyn = require(Shared:WaitForChild("Rosyn", 5))

local WeaponStats = require(Shared:WaitForChild("Configurations"):WaitForChild("WeaponStats"))

local Health = require(game.ServerScriptService.Server.Components.Character.Health)

local ServerComm = require(script.Parent.ServerComm)
local comm = ServerComm.GetServerComm()

local Welder = require(script.Welder)

local GunEngine = {}

function GunEngine:Start()
    print("start")
    local bulletFolder = Instance.new("Folder")
    bulletFolder.Name = "Bullets"
    bulletFolder.Parent = workspace

    local drawRaySignal = comm:CreateSignal("DrawRay")
    drawRaySignal:Connect(function(player: Player, startPosition: Vector3, endPosition: Vector3, weaponName: string)
        -- could be spammed fired to cause people to lag, check some kind of script invocation timer thingy, could make sure that the time between shots isn't shorter than the fire rate
        -- something like LastShot = tick(), if currentShot - LastShot < fireRate then kick, though probably would just want to watch them
        drawRaySignal:FireExcept(player, startPosition, endPosition, weaponName)
    end)

    comm:BindFunction("WeldWeapon", function(player: Player, weapon: Model, toBack: boolean)
        -- could be abused somehow?
        -- actually probably not because you'd have to weld something that exists on the server and has weapon stats
        -- an intelligent exploiter could possibly give themselves a different cosmetic appearance if someone has a cool weapon, but it wouldn't do much else
        local result = Welder:WeldWeapon(player, weapon, toBack)
        return result
    end)

    comm:BindFunction("AttemptDealDamage", function(player: Player, healthComponentPart: BasePart, weaponName: string)
        local healthComponent = Rosyn.GetComponent(healthComponentPart, Health) :: typeof(Health)
        local stats = WeaponStats[weaponName]
        if stats and stats.Damage then
            healthComponent:TakeDamage(stats.Damage)
        end
    end)

    print("bound functions")
end

function GunEngine:WeldWeapon(player: Player, weapon: Model, toBack: boolean)
    -- could be abused somehow?
    -- actually probably not because you'd have to weld something that exists on the server and has weapon stats
    -- an intelligent exploiter could possibly give themselves a different cosmetic appearance if someone has a cool weapon, but it wouldn't do much else
    local result = Welder:WeldWeapon(player, weapon, toBack)
    return result
end

return GunEngine