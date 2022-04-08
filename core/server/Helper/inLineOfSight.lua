local Debris = game:GetService("Debris")

local function visualize(startPos, endPos)
    local part = Instance.new("Part")

    local v = (startPos - endPos)
    part.CFrame = CFrame.new(endPos + 0.5 * v, startPos)
    part.Size = Vector3.new(0.1, 0.1, 0.1)
    part.Transparency = 0.5
    part.Material = Enum.Material.Neon
    part.BrickColor = BrickColor.random()
    part.Anchored = true

    part.Parent = workspace

    Debris:AddItem(part, 0.25)
end

return function(object, target)
    local root = object:WaitForChild("HumanoidRootPart")

	local ignore = {object}
	for _, player in pairs(game.Players:GetChildren()) do
		if player ~= target then
			table.insert(ignore, player.Character)
		end
	end

	for _, part in pairs(target.Character:GetDescendants()) do
		if part:IsA('BasePart') then
			local ray = Ray.new(root.CFrame.Position, (part.CFrame.Position - root.CFrame.Position).Unit * 999)
			local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, ignore, false, false)
            -- visualize(object.HumanoidRootPart.Position, position)
			if hit.Parent == target.Character or hit.Parent.Parent == target.Character then 
				return true
			end
		end
	end

    return false
end