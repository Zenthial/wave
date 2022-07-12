local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local PortRemote = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PortsFolder"):WaitForChild("PortRemote") :: RemoteFunction
local SendToOthersRemote = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("PortsFolder"):WaitForChild("SendToOthersRemote") :: RemoteFunction

local CourierClient = {
    Cache = {}
}

function CourierClient:Send(portString: string, ...)
    local portRemote = self.Cache[portString]

    if portRemote == nil then
        portRemote = PortRemote:InvokeServer(portString) :: RemoteEvent | nil
        self.Cache[portString] = portRemote
    end

    if portRemote ~= nil then
        portRemote:FireServer(...)
    end
end

function CourierClient:SendToOthers(portString: string, ...)
    SendToOthersRemote:FireServer(portString, ...)
end

function CourierClient:Listen(portString: string): typeof(Signal)
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
        error("no remote created for " .. portString)
    end
end

return CourierClient

