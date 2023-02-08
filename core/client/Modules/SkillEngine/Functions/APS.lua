local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))
local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local Player = Players.LocalPlayer

type SkillStats = {
    SkillName: string,
    SkillModel: Model,
    WeaponStats: any,

    Energy: number,
    Recharging: boolean,
	Active: boolean,
}

local cleaner = Trove.new()
return function(skillStats: SkillStats, bool)
    local bodyGyro = tcs.get_component(Player.Character, "BodyGyro")
    if bool and skillStats.SkillModel:GetAttribute("CurrentHealth") > skillStats.WeaponStats.HealthMin then
        skillStats.Active = true
        Player:SetAttribute("APSActive", true)
        courier:Send("MakeAPS", true)
        bodyGyro:SetGyro(true)

        cleaner:Add(skillStats.SkillModel:GetAttributeChangedSignal("CurrentHealth"):Connect(function()
            local health = skillStats.SkillModel:GetAttribute("CurrentHealth")
            skillStats.EnergyChanged:Fire(health, skillStats.WeaponStats.HealthMin)

            if health <= 0 then
                skillStats.Active = false
                Player:SetAttribute("APSActive", false)
                courier:Send("MakeAPS", false)
                bodyGyro:SetGyro(false)
                cleaner:Clean()
            end
        end))
    else
        skillStats.Active = false
        Player:SetAttribute("APSActive", false)
        courier:Send("MakeAPS", false)
        bodyGyro:SetGyro(false)
        cleaner:Clean()
    end
end