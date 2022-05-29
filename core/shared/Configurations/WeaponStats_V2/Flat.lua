local WeaponStats = {}

for _, file in pairs(script.Parent.stats:GetChildren()) do
    local mod = require(file)

    assert(mod.Name, "No name for " .. file.Name)

    table.insert(WeaponStats, mod)
end

return WeaponStats