local client = require(script.client)

local RunService = game:GetService("RunService")

if RunService:IsServer() or RunService:IsStudio() then
    local server = require(script.server)
    return server
elseif RunService:IsClient() then
    return client
end

return client
