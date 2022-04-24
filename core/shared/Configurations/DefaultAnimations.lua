local animationTables = {}

for _, animation in pairs(script.Parent.Parent.Assets.GlobalAnimations:GetChildren()) do
    animationTables[animation.Name] = animation:Clone()
end

return animationTables