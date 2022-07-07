
local RunService = game:GetService("RunService")

if RunService:IsServer() then
    local server = require(script.server)
    return server
elseif RunService:IsClient() then
    local client = require(script.client)
    return client
end
