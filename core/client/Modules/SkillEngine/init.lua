local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local WeaponStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))
local FunctionsFolder = script.Functions

local Functions = {}

for _, functionModule in FunctionsFolder:GetChildren() do
    Functions[functionModule.Name] = require(functionModule)
end

local Player = Players.LocalPlayer

local MAX_ENERGY = 100
local MIN_ENERGY = 0
local ENERGY_WAIT_TIME = 0.2

type SkillStats = {
    SkillName: string,
    SkillModel: Model,
    WeaponStats: typeof(WeaponStats),

    Energy: number,
    Recharging: boolean,
    Active: boolean
}

type Some<T> = {
    Value: T
}

local function functor(f: (SkillStats, boolean, (SkillStats) -> any, (SkillStats, number) -> any) -> any)
    if f == nil then
        error("functor is nil")
    end
    return f
end

local SkillEngine = {}

function SkillEngine.CreateSkill(skillName: string, skillModel: Model)
    local weaponStats = WeaponStats[skillName]
    assert(weaponStats, "No weapon stats for "..skillName)

    return setmetatable({
        SkillName = skillName,
        SkillModel = skillModel,
        WeaponStats = weaponStats,

        Energy = 100,
        Recharging = false,
        Active = false,
    }, weaponStats) :: SkillStats
end

function SkillEngine.Use(skillStats: SkillStats, bool: boolean)
    if SkillEngine.Character ~= nil and SkillEngine.Character.Humanoid ~= nil and
       skillStats.Energy >= skillStats.WeaponStats.EnergyMin
    then
        print(skillStats.SkillName, Functions)
        functor(Functions[skillStats.SkillName])(skillStats, bool, SkillEngine.RegenEnergy, SkillEngine.DepleteEnergy)
    end
end

function SkillEngine.DepleteEnergy(skillStats: SkillStats, depletionAmount: number)
    skillStats.Energy = math.clamp(skillStats.Energy - depletionAmount, MIN_ENERGY, MAX_ENERGY)

    if skillStats.Energy <= MIN_ENERGY then
        if SkillEngine.Character ~= nil and SkillEngine.Character.Humanoid ~= nil and skillStats.Energy >= MIN_ENERGY then
            skillStats.Recharging = false
            SkillEngine.Use(skillStats, false)
        end
    end
end

function SkillEngine.RegenEnergy(skillStats: SkillStats)
    if skillStats.Recharging == false then
        skillStats.Recharging = true

        while skillStats.Energy < 100 and skillStats.Recharging do
            SkillEngine.DepleteEnergy(skillStats, -skillStats.WeaponStats.EnergyRegen)
            task.wait(ENERGY_WAIT_TIME)
        end

        skillStats.Recharging = false
    end
end

SkillEngine.Character = Player.Character
Player.CharacterAdded:Connect(function(char)
    SkillEngine.Character = char
end)


return SkillEngine