local INSPECT_PART_RELATIVE_CFRAME = CFrame.new(-1.68988037, 1.87501335, -10.3878784, 0.965925634, 0, 0.258819014, 0, 1, 0, -0.258819014, 0, 0.965925634)

return function(relativeHumanoidRootPart: Part)
    local part = Instance.new("Part")
    part.Name = "part"
    part.Anchored = true
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.CFrame = relativeHumanoidRootPart.CFrame:ToWorldSpace(INSPECT_PART_RELATIVE_CFRAME)
    part.Size = Vector3.new(15, 9.75, 2)
    part.TopSurface = Enum.SurfaceType.Smooth
    part.Transparency = 1

    return part
end