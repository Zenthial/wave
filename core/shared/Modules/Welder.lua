local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local WeaponStatsModule = require(Shared:WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))
local SkillStatsModule = require(Shared:WaitForChild("Configurations"):WaitForChild("SkillStats"))
local HolsterStatsModule = require(Shared:WaitForChild("Configurations"):WaitForChild("HolsterStats"))

-- its inverse because part0 and part1 are reversed
local function inverseWeld(part0: BasePart, part1: BasePart, c0: CFrame?, c1: CFrame?)
    assert(part0, "Part0 does not exist")
    assert(part1, "Part1 does not exist")
    local weld = part0:FindFirstChild("HandleWeld") :: ManualWeld
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

local Welder = {}

function Welder:WeldWeapon(character: Model, weapon: Model, toBack: boolean)
    -- print(character, weapon)
    if not character then return false end

    local weaponStats = WeaponStatsModule[weapon.Name] :: WeaponStatsModule.WeaponStats_T
    if weaponStats == nil then weaponStats = SkillStatsModule[weapon.Name] end
    -- print(weaponStats)
    if weaponStats then
        local holsters = toBack and HolsterStatsModule[weaponStats.Holster] or weaponStats.HandleWelds

        local numHandles = weaponStats.NumHandles or 1

        for i = 1, numHandles do
            local handle = weapon:FindFirstChild("Handle"..tostring((i > 1) and i or ""))
            local limbName = holsters[i].limb
            local limb = character:FindFirstChild(limbName)
            inverseWeld(handle, limb, holsters[i].C0, holsters[i].C1)
        end
    else 
        return false
    end

    return true
end

function Welder:WeldArtifact(character: Model, artifact: Model & { Handle: BasePart })
    if not character then return false end
    local holsters = HolsterStatsModule["Back"]

    local handle = artifact:FindFirstChild("Handle")
    local limbName = holsters[1].limb
    local limb = character:FindFirstChild(limbName)
    inverseWeld(handle, limb, holsters[1].C0, holsters[1].C1)
end

function Welder:WeldSkill(player: Model, skill: Model)
    self:WeldWeapon(player, skill, true)
end

return Welder