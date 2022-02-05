local AnimationData = require(script.Parent.Parent.Modules.AnimationData)

local asset = "rbxassetid://"

local animationTables = {}

for _, animation in pairs(script.Parent.Parent.Assets.GlobalAnimations:GetChildren()) do
    animationTables[animation.Name] = AnimationData.new(animation.Name, animation.AnimationId:sub(#asset))
end

return animationTables