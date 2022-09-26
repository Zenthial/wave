local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type AirVehicle_T = {
    __index: AirVehicle_T,
    Name: string,
    Tag: string,
    Root: Model & {
        Engine: Part & {
            Altitude: BodyVelocity,
            Direction: BodyGyro,
        },
        PilotSeat: VehicleSeat,
    },

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local AirVehicle: AirVehicle_T = {}
AirVehicle.__index = AirVehicle
AirVehicle.Name = "AirVehicle"
AirVehicle.Tag = "AirVehicle"
AirVehicle.Ancestor = workspace

function AirVehicle.new(root: any)
    return setmetatable({
        Root = root,
    }, AirVehicle)
end

function AirVehicle:Start()
    local enginePart = self.Root.Engine
    assert(enginePart, "No engine for " .. self.Root.Name)
    local direction = enginePart.Direction
    assert(direction, "No direction on " .. self.Root.Name)
    self.Engine = enginePart

    direction.CFrame = enginePart.CFrame
	direction.D = 150
	direction.MaxTorque = Vector3.new(300000, 300000, 300000)
	direction.P = 500

    local function goFlat()
		local LookVector = enginePart.CFrame.LookVector
		direction.CFrame = CFrame.new(enginePart.CFrame.Position, enginePart.CFrame.Position + Vector3.new(LookVector.X, 0, LookVector.Z))
	end
    
    local seat = self.Root.PilotSeat
    assert(seat, "No seat for " .. self.Root.Name)
    self.Seat = seat

    self:InitializePilotProximityPrompt()

    local vehicleSeatComponent = tcs.get_component(seat, "VehicleSeat")
    self.Cleaner:Add(vehicleSeatComponent.Events.OccupantChanged:Connect(function(newOccupant, oldOccupant)
        if self:IsVehicleFlipped() then
            direction.MaxTorque = Vector3.new(0, 0, 25000000)
            repeat
                task.wait()
            until not self:IsVehicleFlipped()
            
            task.wait(0.2)
            direction.MaxTorque = Vector3.new(0, 0, 0)
        end

        if newOccupant ~= nil then
            self.Courier:Send("BindToPlane", newOccupant, self.Root)
        else
            self.OccupantPlayer = nil
            self.ProximityPrompt.Enabled = true   
            self.Courier:Send("UnbindFromPlane", oldOccupant, self.Root)
            goFlat()
        end
    end))
end

function AirVehicle:InitializePilotProximityPrompt()
    local prompt = Instance.new("ProximityPrompt")
    prompt.Enabled = true
    prompt.ClickablePrompt = true
    prompt.ObjectText = "Pilot Seat"
    prompt.ActionText = "Pilot the " .. self.Root.Name
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
            self.Root.PilotSeat:Sit(hum)
        end
    end))

    prompt.Parent = self.Root.PilotSeat
    self.ProximityPrompt = prompt
end

function AirVehicle:IsVehicleFlipped()
    return (self.Root.PilotSeat.CFrame * CFrame.Angles(math.pi/2, 0, 0)).LookVector.Y < 0.2        
end

function AirVehicle:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(AirVehicle)

return AirVehicle