local Player = game.Players.LocalPlayer

local modules = {}

for _, module in pairs(script:GetDescendants()) do
    if module:IsA("ModuleScript") then
        local m = require(module)
        modules[module.Name] = m
        if m["Start"] ~= nil then
            task.spawn(function()
                m:Start()
            end)
        end
    end
end