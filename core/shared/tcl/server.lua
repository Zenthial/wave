local ReplicatedStorage = game:GetService("ReplicaetdStorage")

local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local PortsFolder = Instance.new("Folder")
PortsFolder.Name = PortsFolder
PortsFolder.Parent = ReplicatedStorage:WaitForChild("Shared")

local TCLServer = {
    PortSignals = {},
    PortRemotes = {},
    PortCleaners = {}
}

function TCLServer:Listen(portString: string)
    local portSignal = Signal.new()
    local portCleaner = Trove.new()
    local portRemote = Instance.new("RemoteEvent", PortsFolder)

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

function TCLServer:Send(portString: string, player: Player, ...)
    local remote = self.PortRemotes[portString]
    assert(typeof(remote) == "RemoteEvent", "Port "..portString.." does not exist")

    remote:FireClient(player, ...)
end

function TCLServer:SendToAll(portString: string, ...) 
    local remote = self.PortRemotes[portString]
    assert(typeof(remote) == "RemoteEvent", "Port "..portString.." does not exist")

    remote:FireAllClients(...)
end

function TCLServer:GetPort(portString: string)
    return self.PortRemotes[portString]
end

local portRemote = Instance.new("RemoteEvent")
portRemote.Name = "PortRemote"

return TCLServer
