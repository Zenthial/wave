local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerComm = require(script.Parent.ServerComm)

local GunEngine = {}

function GunEngine:Start()
    local comm = ServerComm.GetServerComm()

    local drawRaySignal = comm:CreateSignal("DrawRay")
    drawRaySignal:Connect(function(player: Player, startPosition: Vector3, endPosition: Vector3, weaponName: string)
        drawRaySignal:FireExcept(player, startPosition, endPosition, weaponName)
    end)

    local bulletFolder = Instance.new("Folder")
    bulletFolder.Name = "Bullets"
    bulletFolder.Parent = workspace
end

return GunEngine