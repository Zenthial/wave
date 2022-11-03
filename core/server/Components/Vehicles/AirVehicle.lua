local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local VehicleStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("VehicleStats"))

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
    local linearVelocity = enginePart.LinearVelocity
    assert(linearVelocity, "No linearVelocity for ".. self.Root.Name)
    self.Engine = enginePart

    local stats = VehicleStats[self.Root.Name]
    assert(stats, "No vehicle stats for " .. self.Root.Name)

    self.Stats = stats
    self.LinearVelocity = linearVelocity
    self.Direction = direction

    direction.CFrame = enginePart.CFrame
	direction.D = stats.DirectionD
	direction.MaxTorque = stats.DirectionTorque
	direction.P = stats.DirectionP

    local function goFlat()
		local LookVector = enginePart.CFrame.LookVector
		direction.CFrame = CFrame.new(enginePart.CFrame.Position, enginePart.CFrame.Position + Vector3.new(LookVector.X, 0, LookVector.Z))
	end
    
    local pilotSeat = self.Root.PilotSeat
    assert(pilotSeat, "No pilot seat for " .. self.Root.Name)
    self.Seat = pilotSeat

    self:InitializeHitbox()
    CollectionService:AddTag(self.Root, "VehicleHealth")

    self.Root:SetAttribute("VehicleInteractToggle", false)
    self.Root:SetAttribute("Flying", false)
    self.Root:SetAttribute("Scraping", false)

    self:InitializePilotProximityPrompt()

    local vehicleSeatComponent = tcs.get_component(pilotSeat, "VehicleSeat")
    self.Cleaner:Add(vehicleSeatComponent.Events.OccupantChanged:Connect(function(newOccupant, oldOccupant)
        if self:IsVehicleFlipped() then
            direction.MaxTorque = self.Stats.DirectionTorque
            repeat
                task.wait()
            until not self:IsVehicleFlipped()
            
            task.wait(0.2)
            direction.MaxTorque = Vector3.new(0, 0, 0)
        end

        if newOccupant ~= nil then
            self.LinearVelocity.MaxForce = self.Stats.MaxForce
            self.Courier:Send("BindToPlane", newOccupant, self.Root)
        else
            self.OccupantPlayer = nil
            self.ProximityPrompt.Enabled = true
            self.LinearVelocity.MaxForce = 0
            self.Courier:Send("UnbindFromPlane", oldOccupant, self.Root)
            goFlat()
        end
    end))

    self.Cleaner:Add(self.Root:GetAttributeChangedSignal("Dead"):Connect(function()
        if self.Root:GetAttribute("Dead") then
            if self.OccupantPlayer then
                self.Courier:Send("UnbindFromPlane", self.OccupantPlayer, self.Root)
            end
            local explosion = Instance.new("Explosion")
            explosion.BlastRadius = 30
            explosion.ExplosionType = Enum.ExplosionType.NoCraters
            explosion.Position = self.Engine.Position
            explosion.DestroyJointRadiusPercent = 0.80
            explosion.Visible = true
            explosion.Parent = self.Engine
            self.LinearVelocity:Destroy()
            self.Direction:Destroy()
            task.wait(25)
            self.Root:Destroy()
        end
    end))

    self.Cleaner:Add(self.Root:GetAttributeChangedSignal("Health"):Connect(function()
        local currentHealth = self.Root:GetAttribute("Health")
        local maxHealth = self.Root:GetAttribute("MaxHealth")
        
        if currentHealth/maxHealth <= 0.5  and currentHealth/maxHealth > 0.15 then
            local randomBricks = math.random(0, 3)
            local planeParts = self.Root.Engine:GetConnectedParts()
            for i=1, randomBricks do
                local rand = math.random(1, #planeParts)
                while (planeParts[rand].Material == Enum.Material.CorrodedMetal) do
                    rand = math.random(1, #planeParts)
                end
                planeParts[rand].Material = Enum.Material.CorrodedMetal
            end
        end
    end))

    
    local function partInCharacter(part: any)
        if part.Name == "Workspace" then
            return false
        end
        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
            if part.Name == player.Name then
                return true
            end
        end
        return partInCharacter(part.Parent)
    end

    while (task.wait(1)) do
        self:RunServiceLoop()
    end
end

local overlapParam = OverlapParams.new()
overlapParam.FilterType = Enum.RaycastFilterType.Blacklist
function AirVehicle:RunServiceLoop()
    overlapParam.FilterDescendantsInstances = {self.Root, CollectionService:GetTagged("Character")}
    local health_component = tcs.get_component(self.Root, "VehicleHealth")
    local hit = game.Workspace:GetPartsInPart(self.Hitbox)
    print(hit)
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

function AirVehicle:InitializeHitbox()
    local partClone = Instance.new("Part")
    partClone.CanCollide = false
    partClone.Transparency = .9
    partClone.Anchored = true
    local parts = {}
    for _, part in pairs(self.Root:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "Engine" then
            local newPart = partClone:Clone()
            newPart.Size = part.Size + Vector3.new(0.2, 0.2, 0.2)
            newPart:PivotTo(part.CFrame)
            newPart.Parent = self.Root
            table.insert(parts, newPart)
        end
    end
    local newPart = partClone:Clone()
    newPart.Size = self.Root.Engine.Size + Vector3.new(0.2, 0.2, 0.2)
    newPart:PivotTo(self.Root.Engine.CFrame)
    newPart.Parent = self.Root
    newPart:UnionAsync(parts)
    newPart.Name = "Hitbox"
    local WeldConstraint = Instance.new("WeldConstraint")
    WeldConstraint.Part0 = newPart
    WeldConstraint.Part1 = self.Root.Engine
    WeldConstraint.Parent = newPart
    newPart.Anchored = false
    self.Hitbox = newPart
end

function AirVehicle:IsVehicleFlipped()
    return (self.Root.PilotSeat.CFrame * CFrame.Angles(math.pi/2, 0, 0)).LookVector.Y < 0.2        
end

function AirVehicle:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(AirVehicle)

return AirVehicle