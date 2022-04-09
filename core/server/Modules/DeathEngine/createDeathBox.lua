return function()
    local spawnBox = Instance.new("Model")
    spawnBox.Name = "spawnBox"
    spawnBox.WorldPivot = CFrame.new(5254.65039, 50.1750069, 131.75, 1, 0, 0, 0, 1, 0, 0, 0, 1)

    local part = Instance.new("Part")
    part.Name = "part"
    part.Anchored = true
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.CFrame = CFrame.new(5205.6001, 50.3500023, 131.75, 0, -1, 0, 1, 0, 0, 0, 0, 1)
    part.Orientation = Vector3.new(0, 0, 90)
    part.Position = Vector3.new(5.21e+03, 50.4, 132)
    part.Rotation = Vector3.new(0, 0, 90)
    part.Size = Vector3.new(100, 1, 100)
    part.TopSurface = Enum.SurfaceType.Smooth
    part.Parent = spawnBox

    local part1 = Instance.new("Part")
    part1.Name = "part1"
    part1.Anchored = true
    part1.BottomSurface = Enum.SurfaceType.Smooth
    part1.CFrame = CFrame.new(5304.3501, 50.3500023, 131.75, 0, -1, 0, 1, 0, 0, 0, 0, 1)
    part1.Orientation = Vector3.new(0, 0, 90)
    part1.Position = Vector3.new(5.3e+03, 50.4, 132)
    part1.Rotation = Vector3.new(0, 0, 90)
    part1.Size = Vector3.new(100, 1, 100)
    part1.TopSurface = Enum.SurfaceType.Smooth
    part1.Parent = spawnBox

    local part2 = Instance.new("Part")
    part2.Name = "part2"
    part2.Anchored = true
    part2.BottomSurface = Enum.SurfaceType.Smooth
    part2.CFrame = CFrame.new(5254.25, 50.3500023, 82.3999939, 0, 0, -1, 1, 0, 0, 0, -1, 0)
    part2.Orientation = Vector3.new(0, -90, 90)
    part2.Position = Vector3.new(5.25e+03, 50.4, 82.4)
    part2.Rotation = Vector3.new(-90, -90, 0)
    part2.Size = Vector3.new(100, 1, 100)
    part2.TopSurface = Enum.SurfaceType.Smooth
    part2.Parent = spawnBox

    local part3 = Instance.new("Part")
    part3.Name = "part3"
    part3.Anchored = true
    part3.BottomSurface = Enum.SurfaceType.Smooth
    part3.CFrame = CFrame.new(5254.25, 50.3500023, 179.75, 0, 0, -1, 1, 0, 0, 0, -1, 0)
    part3.Orientation = Vector3.new(0, -90, 90)
    part3.Position = Vector3.new(5.25e+03, 50.4, 180)
    part3.Rotation = Vector3.new(-90, -90, 0)
    part3.Size = Vector3.new(100, 1, 100)
    part3.TopSurface = Enum.SurfaceType.Smooth
    part3.Parent = spawnBox

    local floor = Instance.new("Part")
    floor.Name = "floor"
    floor.Anchored = true
    floor.BottomSurface = Enum.SurfaceType.Smooth
    floor.CFrame = CFrame.new(5255.05029, 0.500011027, 131.75, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    floor.Position = Vector3.new(5.26e+03, 0.5, 132)
    floor.Size = Vector3.new(100, 1, 100)
    floor.TopSurface = Enum.SurfaceType.Smooth
    floor.Parent = spawnBox

    spawnBox.Parent = workspace
    return spawnBox
end