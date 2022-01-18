local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local WeaponStatsModule = require(Shared:WaitForChild("Configurations"):WaitForChild("WeaponStats"))
local HolsterStatsModule = require(Shared:WaitForChild("Configurations"):WaitForChild("HolsterStats"))

-- its inverse because part0 and part1 are reversed
local function inverseWeld(part0: BasePart, part1: BasePart, c0: CFrame?, c1: CFrame?)
    if part0 and part1 then
        local weld = part0:FindChild("HandleWeld") :: ManualWeld
        if not weld then
            weld = Instance.new("ManualWeld")
            weld.Name = "HandleWeld"
        end

        weld.Part0 = part1
        weld.Part1 = part0

        if c0 then
            weld.C0 = c0
        end
        if c1 then
            weld.C1 = c1
        end
        
        weld.Parent = part0
    end
end

local Welder = {}

function Welder:WeldWeapon(player: Player, weapon: Model, toBack: boolean)
    local character = player.Character
    if not character then return end

    local weaponStats = WeaponStatsModule[weapon.Name] :: WeaponStatsModule.WeaponStats
    if weaponStats then
        local holsters = toBack and HolsterStatsModule[weaponStats.Holster] or weaponStats.HandleWelds

        local numHandles = weaponStats.NumHandles

        for i = 1, numHandles do
            local handle = weapon:FindFirstChild("Handle"..tostring((i > 1) and i or ""))
            local limbName = holsters[i].limb
            local limb = character:FindFirstChild(limbName)
            inverseWeld(handle, limb, holsters[i].C0, holsters[i].C1)
        end
    end
end

function Welder:WeldSkill(player: Player, skill: Model)
    self:WeldWeapon(player, skill, true)
end

return Welder