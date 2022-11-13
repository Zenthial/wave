-- Need to migrate functionality from SkillHandler component to here
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))

local WeaponStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Skills = Assets:WaitForChild("Skills")

local SkillService = {}

function SkillService:Start()
    courier:Listen("SiphonDamage"):Connect(function(sourcePlayer: Player, playersNear: {Player})
        if sourcePlayer:GetAttribute("EquippedSkill") ~= "SIPH-N" then return end
        local siphonStats = WeaponStats["SIPH-N"]
        local totalDamage = 0
        for _, player in playersNear do
            local healthComponent = tcs.get_component(player, "Health")

            if player.TeamColor ~= sourcePlayer.TeamColor then
                healthComponent:TakeDamage(siphonStats.Damage)
                totalDamage += siphonStats.Damage
            end
        end

        local sourceHealthComponent = tcs.get_component(sourcePlayer, "Health")
        sourceHealthComponent:Heal(totalDamage * siphonStats.HealFactor)
    end)

    courier:Listen("MakeAPS"):Connect(function(sourcePlayer: Player, shouldMake: boolean)
        if sourcePlayer:GetAttribute("EquippedSkill") ~= "APS" then return end

        local character = sourcePlayer.Character or sourcePlayer.CharacterAdded:Wait()
        local aps = character:FindFirstChild("APS")
        assert(aps, "No aps model found on the character")
        if shouldMake then
            TweenService:Create(aps.BarrierEffect, TweenInfo.new(0.25), {Size = Vector3.new(9, 0.15, 7), Transparency = 0}):Play()
            TweenService:Create(aps.Handle.BarrierEffect, TweenInfo.new(0.25), {C0 = CFrame.new(Vector3.new(-0.026, 0.019, 2)) * CFrame.Angles(math.rad(90), 0, 0)}):Play()
        else
            TweenService:Create(aps.BarrierEffect, TweenInfo.new(0.25), {Size = Vector3.new(4, 0.15, 0), Transparency = 1}):Play()
            TweenService:Create(aps.Handle.BarrierEffect, TweenInfo.new(0.25), {C0 = CFrame.new(Vector3.new(-0.026, 0.019, 0.769)) * CFrame.Angles(math.rad(90), 0, 0)}):Play()
        end
    end)
end

return SkillService