local stats = {}

for _, file in pairs(script.stats:GetChildren()) do
    local mod = require(file)

    assert(mod.Name, "No name for " .. file.Name)

    stats[mod.Name] = mod
end

return stats