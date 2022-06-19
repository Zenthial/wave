local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FlavorText = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("FlavorText"))

return function()
    local random = Random.new()

    return FlavorText[random:NextInteger(1, #FlavorText)]
end