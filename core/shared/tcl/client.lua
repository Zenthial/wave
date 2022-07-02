local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local PortRemote = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PortsFolder"):WaitForChild("PortRemote") :: RemoteFunction

local TCLClient = {
    Cache = {}
}

function TCLClient:Send(portString: string, ...)
    local portRemote = self.Cache[portString]

    if portRemote == nil then
        portRemote = PortRemote:InvokeServer(portString) :: RemoteEvent | nil
        self.Cache[portString] = portRemote
    end

    if portRemote ~= nil then
        portRemote:FireServer(...)
    end
end

function TCLClient:Listen(portString: string)
    local portRemote = self.Cache[portString]

    if portRemote == nil then
        portRemote = PortRemote:InvokeServer(portString) :: RemoteEvent | nil
        self.Cache[portString] = portRemote
    end

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
