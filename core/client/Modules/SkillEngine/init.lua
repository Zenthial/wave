local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local WeaponStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))
local Functions = require(script.Functions)

local Player = Players.LocalPlayer

local MAX_ENERGY = 100
local MIN_ENERGY = 0

type SkillStats = {
    SkillName: string,
    SkillModel: Model,
    WeaponStats: typeof(WeaponStats),

    Energy: number,
    Recharging: boolean,
    CanUse: boolean,
}

type Some<T> = {
    Value: T
}

local function falliable(value: (() -> any) | nil)
    if value ~= nil then
        return {Value = value} :: Some<value>
    end
end

local SkillEngine = {}

function SkillEngine.CreateSkill(skillName: string, skillModel: Model)
    local weaponStats = WeaponStats[skillName]
    assert(weaponStats, "No weapon stats for "..skillName)

    return {
        SkillName = skillName,
        SkillModel = skillModel,
        WeaponStats = weaponStats,

        Energy = 100,
        Recharging = false,
        CanUse = true,
    } :: SkillStats
end

function SkillEngine.Use(skillStats: SkillStats)
    if SkillEngine.Character ~= nil and SkillEngine.Character.Humanoid ~= nil and skillStats.Energy >= skillStats.WeaponStats.EnergyMin then
        self.SkillFunction(self, true, LocalPlayer.Character, self.Model)
        -- self.Events.FunctionEnded:Fire()
    end
end

SkillEngine.Character = Player.Character
Player.CharacterAdded:Connect(function(char)
    SkillEngine.Character = char
end)


return SkillEngine