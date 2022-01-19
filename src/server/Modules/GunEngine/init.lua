local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerComm = require(script.Parent.ServerComm)

local Welder = require(script.Welder)

local GunEngine = {}

function GunEngine:Start()
    local comm = ServerComm.GetServerComm()

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

    local bulletFolder = Instance.new("Folder")
    bulletFolder.Name = "Bullets"
    bulletFolder.Parent = workspace
end

return GunEngine