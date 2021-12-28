local Player = game.Players.LocalPlayer

for _, module in pairs(script:GetDescendants()) do
    if module:IsA("ModuleScript") then
        require(module)
    end
end