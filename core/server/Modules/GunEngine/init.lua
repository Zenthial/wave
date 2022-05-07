local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local tcs = require(Shared:WaitForChild("tcs"))

local WeaponStats = require(Shared:WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))
local GadgetStats = require(Shared:WaitForChild("Configurations"):WaitForChild("GadgetStats"))
local Trove = require(Shared:WaitForChild("util"):WaitForChild("Trove"))

local ServerComm = require(script.Parent.ServerComm)
local comm = ServerComm.GetServerComm()

local Welder = require(script.Welder)

local DefaultServerPlayerAttributes = require(script.Parent.DefaultServerPlayerAttributes)

local function setupPlayer(player: Player)
    for attributeName, value in pairs(DefaultServerPlayerAttributes) do
        player:SetAttribute(attributeName, value)
    end
end

local drawRaySignal = comm:CreateSignal("DrawRay")
local renderGrenade = comm:CreateSignal("RenderGrenade")

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

-- healthComponentPart is technically a player now
comm:BindFunction("AttemptDealDamage", function(player: Player, healthComponentPart: BasePart, weaponName: string, hitPartName: string)
    local healthComponent = tcs.get_component(healthComponentPart, "Health") --[[:await()]]
    local stats = WeaponStats[weaponName]
    if stats and stats.Damage then
        local damage = stats.Damage

        if hitPartName == "Head" then
            damage *= stats.HeadshotMultiplier
        end
        
        print(damage)
        healthComponent:TakeDamage(damage)
    end
end)

comm:BindFunction("DealSelfDamage", function(player: Player, damage: number)
    damage = math.clamp(damage, 0, 100)
    local healthComponent = tcs.get_component(player, "Health") --[[:await()]]
    healthComponent:TakeDamage(damage)
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

    renderGrenade:Connect(function(player: Player, position: Vector3, direction: Vector3, movementSpeed: Vector3, gadget: string)
        local quantity = player:GetAttribute("GadgetQuantity")
        if quantity > 0 then
            player:SetAttribute("GadgetQuantity", quantity - 1)
            renderGrenade:FireExcept(player, player, position, direction, movementSpeed, gadget)
        end
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