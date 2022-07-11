local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local PortsFolder = Instance.new("Folder")
PortsFolder.Name = "PortsFolder"
PortsFolder.Parent = ReplicatedStorage:WaitForChild("Shared")

local CourierServer = {
    PortSignals = {},
    PortRemotes = {},
    PortCleaners = {}
}

function CourierServer:Listen(portString: string): typeof(Signal)
    local portSignal = Signal.new()
    local portCleaner = Trove.new()
    local portRemote = Instance.new("RemoteEvent")
    portRemote.Parent = PortsFolder

    if self.PortCleaners[portString] ~= nil then
        error("Only one server provider allowed per port")
    end 

    self.PortSignals[portString] = portSignal
    self.PortCleaners[portString] = portCleaner
    self.PortRemotes[portString] = portRemote

    portCleaner:Add(portRemote.OnServerEvent:Connect(function(...)
        -- add validation here
        portSignal:Fire(...)
    end))

    portCleaner:Add(function()
        portSignal:Destroy()
        portRemote:Destroy()
    end)

    return portSignal
end

function CourierServer:Send(portString: string, player: Player, ...)
    local remote = self.PortRemotes[portString]
    assert(remote:IsA("RemoteEvent"), "Port "..portString.." does not exist")

    remote:FireClient(player, ...)
end

function CourierServer:SendTo(portString: string, players: {Player}, ...)
    local remote = self.PortRemotes[portString]
    assert(remote:IsA("RemoteEvent"), "Port "..portString.." does not exist")

    for _, player in ipairs(players) do
        remote:FireClient(player, ...)        
    end
end

function CourierServer:SendToAll(portString: string, ...) 
    local remote = self.PortRemotes[portString]
    assert(remote:IsA("RemoteEvent"), "Port "..portString.." does not exist")

    remote:FireAllClients(...)
end

function CourierServer:GetPort(portString: string)
    local remote = self.PortRemotes[portString]
    if remote then
        return remote
    else
        local portRemote = Instance.new("RemoteEvent")
        portRemote.Parent = PortsFolder

        self.PortRemotes[portString] = portRemote
        return portRemote
    end
end

local portRemote = Instance.new("RemoteFunction")
portRemote.Name = "PortRemote"
portRemote.Parent = PortsFolder

portRemote.OnServerInvoke = function(player: Player, portString: string)
    return CourierServer:GetPort(portString)
end

return CourierServer
