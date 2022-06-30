local server = require(script.server.lua)
local client = require(script.client.lua)

local RunService = game:GetService("RunService")

if RunService:IsServer() then
    return server
elseif RunService:IsClient() then
    return client
end

return server
