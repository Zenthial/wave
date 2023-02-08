local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local tcs = require(Shared:WaitForChild("tcs"))

local WeaponStats = require(Shared:WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))
local GadgetStats = require(Shared:WaitForChild("Configurations"):WaitForChild("GadgetStats"))
local Trove = require(Shared:WaitForChild("util"):WaitForChild("Trove"))
local radiusDamage = require(Shared:WaitForChild("Modules"):WaitForChild("functions"):WaitForChild("radiusDamage"))

local Welder = require(Shared.Modules.Welder)
local Courier = require(Shared.courier)

local DefaultServerPlayerAttributes = require(script.Parent.DefaultServerPlayerAttributes)

local function setupPlayer(player: Player)
    for attributeName, value in pairs(DefaultServerPlayerAttributes) do
        player:SetAttribute(attributeName, value)
    end
end

local function attemptDealDamage(player: Player, weaponName: string, healthComponentObject: Instance, damage: number, hitPartName: string | nil, headshotMultiplier: number | nil)
    local healthComponent = nil

    if tcs.has_component(healthComponentObject, "Health") then
        healthComponent = tcs.get_component(healthComponentObject, "Health")
    else
        if healthComponentObject:IsA("Player") then
            healthComponent = tcs.get_component(healthComponentObject, "Health") --[[:await()]]
        elseif healthComponentObject:IsA("Model") and healthComponentObject.Name == "APS" then
            healthComponent = tcs.get_component(healthComponentObject, "ObjectHealth")
        elseif healthComponentObject:IsA("Model") and healthComponentObject:GetAttribute("Health") ~= nil then
            healthComponent = tcs.get_component(healthComponentObject, "VehicleHealth")
        end 
    end
    
    assert(healthComponent, "Health component, VehicleHealth component, or ShieldHealth not found on "..healthComponentObject.Name)


    if hitPartName == "Head" and headshotMultiplier then
        damage *= headshotMultiplier
    end
    
    healthComponent.Root:SetAttribute("LastKiller", player.Name)
    healthComponent.Root:SetAttribute("LastKilledWeapon", weaponName)

    if healthComponent.Root:FindFirstChild("DamageFolder") then
        local folder = healthComponent.Root.DamageFolder:FindFirstChild(player.Name)
        if folder == nil then
            folder = Instance.new("Folder")
            folder.Name = player.Name
            folder:SetAttribute("Damage", damage)
            folder:SetAttribute("Hits", 1)

            folder.Parent = healthComponent.Root.DamageFolder
        else
            folder:SetAttribute("Damage", folder:GetAttribute("Damage") + damage)
            folder:SetAttribute("Hits", folder:GetAttribute("Hits") + 1)
        end

        folder:SetAttribute("Time", tick())
    end
    healthComponent:TakeDamage(damage)
end

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

    Courier:Listen("DrawRay"):Connect(function(player: Player, startPosition: Vector3, endPosition: Vector3, weaponName: string)
        -- could be spammed fired to cause people to lag, check some kind of script invocation timer thingy, could make sure that the time between shots isn't shorter than the fire rate
        -- something like LastShot = tick(), if currentShot - LastShot < fireRate then kick, though probably would just want to watch them
        Courier:SendToAllExcept("DrawRay", player, player, startPosition, endPosition, weaponName)
    end)

    Courier:Listen("RenderGrenade"):Connect(function(player: Player, position: Vector3, direction: Vector3, movementSpeed: Vector3, gadget: string)
        local quantity = player:GetAttribute("GadgetQuantity")
        if quantity > 0 then
            player:SetAttribute("GadgetQuantity", quantity - 1)
            Courier:SendToAllExcept("RenderGrenade", player, player, position, direction, movementSpeed, gadget)
        end
    end)

    Courier:Listen("WeldWeapon"):Connect(function(player: Player, weapon: Model, toBack: boolean)
        -- could be abused somehow?
        -- actually probably not because you'd have to weld something that exists on the server and has weapon stats
        -- an intelligent exploiter could possibly give themselves a different cosmetic appearance if someone has a cool weapon, but it wouldn't do much else
        local character = player.Character
        if character == nil then
            return
        end
        Welder:WeldWeapon(character, weapon, toBack)
    end)

    Courier:Listen("AoERadius"):Connect(function(player: Player, part: BasePart, weaponName)
        local stats = GadgetStats[weaponName]
        if stats == nil then
            stats = WeaponStats[weaponName]
        end
    
        assert(stats ~= nil, "No stats exist for "..weaponName)
        local playersToDamage = radiusDamage(stats, part.Position, player, false)
        for _player: Player, damage: number in pairs(playersToDamage) do
            attemptDealDamage(player, weaponName, _player, damage)
        end
    end)

    Courier:Listen("AttemptDealDamage"):Connect(function(player: Player, healthComponentPart: BasePart, weaponName: string, hitPartName: string)
        local stats = WeaponStats[weaponName]
        if stats and stats.Damage then
            attemptDealDamage(player, weaponName, healthComponentPart, stats.Damage, hitPartName, stats.HeadshotMultiplier)
        else
            error(weaponName .. " does not have weapon stats or weapon stats with damage")
        end
    end)

    Courier:Listen("DealSelfDamage"):Connect(function(player: Player, damage: number, sourcePlayer: Player, weaponName: string)
        damage = math.clamp(damage, 0, 100)
    
        player:SetAttribute("LastKiller", if sourcePlayer then sourcePlayer.Name else "")
        player:SetAttribute("LastKilledWeapon", if weaponName then weaponName else "")
        local healthComponent = tcs.get_component(player, "Health")
        healthComponent:TakeDamage(damage)
    end)

    Courier:Listen("H3GRequest"):Connect(function(player: Player)
        assert(player:GetAttribute("EquippedGadget") == "H3G", "Player" .. player.Name.. " is not using the H3G")
        local h3gStats = WeaponStats["H3G"]
        local healthComponent = tcs.get_component(player, "Health")
        healthComponent:Heal(h3gStats.Heal)
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
