local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, Player: Player, ...any) -> (),
    SendTo: (Courier_T, Port: string, Players: {Player}, ...any) -> ()
}

type VehicleSeat_T = {
    __index: VehicleSeat_T,
    Name: string,
    Tag: string,
    Root: VehicleSeat,
    Occupant: Humanoid | nil,

    Events: {
        OccupantChanged: typeof(Signal)
    },

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local VehicleSeat: VehicleSeat_T = {}
VehicleSeat.__index = VehicleSeat
VehicleSeat.Name = "VehicleSeat"
VehicleSeat.Tag = "VehicleSeat"
VehicleSeat.Ancestor = workspace

function VehicleSeat.new(root: any)
    return setmetatable({
        Root = root,
        Occupant = nil,

        Events = {
            OccupantChanged = Signal.new()
        }
    }, VehicleSeat)
end

function VehicleSeat:Start()
    self.Root.Disabled = true -- disable the seat so players cant walk on it to get into it, they must use the proximity prompt
    self.Cleaner:Add(self.Root.Changed:Connect(function(property: string)
        if property == "Occupant" then
            local occupant = self.Root.Occupant
            if occupant ~= nil then
                local character = occupant.Parent
                local player = Players:GetPlayerFromCharacter(character)

                if player then
                    self.Root:SetNetworkOwner(player)
                    self.Events.OccupantChanged:Fire(player, self.Occupant)
                    self.Occupant = player

                    local jumpConnection = nil :: RBXScriptSignal
                    jumpConnection = occupant.Jumping:Connect(function()
                        self.Root.Steer = 0
                        self.Root.Throttle = 0
                        
                        jumpConnection:Disconnect()
                    end)
                    self.Cleaner:Add(jumpConnection)
                end
            else
                self.Root:SetNetworkOwner(nil)
                self.Root.Steer = 0
                self.Root.Throttle = 0

                self.Events.OccupantChanged:Fire(nil, self.Occupant)
                self.Occupant = nil
            end
        end
    end))
end

function VehicleSeat:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(VehicleSeat)

return VehicleSeat
