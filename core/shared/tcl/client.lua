local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local PortRemote = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PortsFolder"):WaitForChild("PortRemote") :: RemoteFunction

local TCLClient = {}

function TCLClient:Send(portString: string, ...)
    local portRemote = PortRemote:InvokeServer(portString) :: RemoteEvent | nil

    if portRemote ~= nil then
        portRemote:FireServer(...)
    end
end

function TCLClient:Listen(portString: string)
    local portRemote = PortRemote:InvokeServer(portString) :: RemoteEvent | nil

    if portRemote ~= nil then
        local portSignal = Signal.new()

        portRemote.OnClientEvent:Connect(function(...)
            portSignal:Fire(...)
        end)

        return portSignal
    else
        return nil
    end
end

return TCLClient
