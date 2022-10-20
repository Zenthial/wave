local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type Boat_T = {
    __index: Boat_T,
    Name: string,
    Tag: string,
    Root: Model & {
        VehicleSeat: VehicleSeat,
        Base: Part & {
            Attachment: Attachment,
            AlignOrientation: AlignOrientation,
            VectorForce: VectorForce,
            LinearVelocity: LinearVelocity,
        }
    },

    Seat: VehicleSeat,
    LinearVelocity: LinearVelocity,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local Boat: Boat_T = {}
Boat.__index = Boat
Boat.Name = "Boat"
Boat.Tag = "Boat"
Boat.Ancestor = game

function Boat.new(root: any)
    return setmetatable({
        Root = root,
    }, Boat)
end

function Boat:Start()
    self.OccupantPlayer = nil

    local mainTurret = self.Root:FindFirstChild("Turret")
    if mainTurret ~= nil and self.Root:GetAttribute("DriverMansTurret") == nil then -- if it has a main turret and no variable saying the driver shouldnt get it, then give it to them
        self.Root:SetAttribute("DriverMansTurret", true)
    end
    local driverMansMainTurret = self.Root:GetAttribute("DriverMansTurret") or false

    self:InitializeDriverProximityPrompt()

    local vehicleSeatComponent = tcs.get_component(self.Root.VehicleSeat, "VehicleSeat")
    self.Cleaner:Add(vehicleSeatComponent.Events.OccupantChanged:Connect(function(newOccupant, oldOccupant)
        if newOccupant ~= nil then
            self.Courier:Send("BindToBoat", newOccupant, self.Root)

            if mainTurret ~= nil and driverMansMainTurret == true then
                self.Courier:Send("BindToTurret", newOccupant, mainTurret, self.Root.Name)
            end
        else
            self.ProximityPrompt.Enabled = true
            self.OccupantPlayer = nil
            self.Courier:Send("UnbindFromBoat", oldOccupant, self.Root)

            if mainTurret ~= nil and driverMansMainTurret == true then
                self.Courier:Send("UnbindFromTurret", oldOccupant, mainTurret, self.Root.Name)
            end
        end
    end))
end

function Boat:InitializeDriverProximityPrompt()
    local prompt = Instance.new("ProximityPrompt")
    prompt.Enabled = true
    prompt.ClickablePrompt = true
    prompt.ObjectText = "Driver Seat"
    prompt.ActionText = "Drive the " .. self.Root.Name
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.MaxActivationDistance = 10
    prompt.HoldDuration = 1
    prompt.RequiresLineOfSight = false
    CollectionService:AddTag(prompt, "Prompt")

    self.Cleaner:Add(prompt.Triggered:Connect(function(player: Player)
        if self.OccupantPlayer == nil and player.Character ~= nil and player.Character.Humanoid ~= nil then
            local hum = player.Character.Humanoid
            if hum.Sit == true then return end
            self.OccupantPlayer = player
            prompt.Enabled = false
            self.Root.VehicleSeat:Sit(hum)
        end
    end))

    prompt.Parent = self.Root.VehicleSeat
    self.ProximityPrompt = prompt
end

function Boat:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(Boat)

return Boat