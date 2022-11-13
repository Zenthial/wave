local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))

local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = {character}
raycastParams.IgnoreWater = true

type SkillStats = {
    SkillName: string,
    SkillModel: Model,

    Energy: number,
    Recharging: boolean,
	Active: boolean,
}

return function(skillStats: SkillStats, bool, regenEnergy, depleteEnergy)
	if bool then
		skillStats.Active = true
		depleteEnergy(skillStats, skillStats.WeaponStats.EnergyDeplete) -- replace this line with hardcoded d0dg-p energy depletion stats
		LocalPlayer:SetAttribute("LocalSprinting", false)
		LocalPlayer:SetAttribute("LocalCrouching", false)
		
		local raycastResult = workspace:Raycast(character.HumanoidRootPart.Position, character.HumanoidRootPart.CFrame.LookVector * skillStats.WeaponStats.Distance, raycastParams)
		if raycastResult and raycastResult.Position then
			character:PivotTo(CFrame.new(raycastResult.Position:Lerp(character.PrimaryPart.Position, .2), character.PrimaryPart.Orientation))
		else
			character:PivotTo(character.PrimaryPart.CFrame + (character.HumanoidRootPart.CFrame.LookVector * skillStats.WeaponStats.Distance))
		end

		skillStats.Active = false
		regenEnergy(skillStats)
	end
end