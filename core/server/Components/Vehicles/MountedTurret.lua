local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, Player: Player, ...any) -> (),
    SendTo: (Courier_T, Port: string, Players: {Player}, ...any) -> ()
}

type MountedTurret_T = {
    __index: MountedTurret_T,
    Name: string,
    Tag: string,

    Root: Model & {
        Y: Model & {
            XZ: Folder,
            Core: Part & {
                XZ: HingeConstraint,
                Y: HingeConstraint
            },
    
            Middle: Part,
            Seat: Seat
        },
        BaseMount: Part,
    },

    Core: Part & {
        XZ: HingeConstraint,
        Y: HingeConstraint
    },
    Middle: Part,

    HingeXZ: HingeConstraint,
    HingeY: HingeConstraint,

    Cleaner: Cleaner_T,
}

local MountedTurret: MountedTurret_T = {}
MountedTurret.__index = MountedTurret
MountedTurret.Name = "MountedTurret"
MountedTurret.Tag = "MountedTurret"
MountedTurret.Ancestor = workspace

function MountedTurret.new(root: any)
    return setmetatable({
        Root = root,
    }, MountedTurret)
end

function MountedTurret:Start()
    print("mounted turret started")
    local body = self.Root.Y
    local middle = body.Middle
    local core = body.Core
    local vehicleSeat = self.Root.Seat
    assert(body ~= nil, "No Y model in "..self.Root.Name)
    assert(middle ~= nil, "No Middle part in "..self.Root.Name)
    assert(core ~= nil, "No Core part in "..self.Root.Name)
    assert(vehicleSeat ~= nil, "No Seat in "..self.Root.Name)

    self.Core = core
    self.Middle = middle

    local hingeXZ = core:FindFirstChild("XZ")
    local hingeY = core:FindFirstChild("Y")
    assert(hingeXZ, "No XZ Hinge for " .. self.Root.Name)
    assert(hingeY, "No Y Hinge for " .. self.Root.Name)
   
    self:InitializeProximityPrompt()

    local vehicleSeatComponent = tcs.get_component(vehicleSeat, "VehicleSeat")
    self.Cleaner:Add(vehicleSeatComponent.Events.OccupantChanged:Connect(function(newOccupant, oldOccupant)
        if newOccupant ~= nil then
            self.Courier:Send("BindToMountedTurret", newOccupant, self.Root, self.Root.Name)
        else
            self.OccupantPlayer = nil
            self.ProximityPrompt.Enabled = true
            self.Courier:Send("UnbindFromMountedTurret", oldOccupant, self.Root, self.Root.Name)
        end
    end))
end

function MountedTurret:InitializeProximityPrompt()
    local prompt = Instance.new("ProximityPrompt")
    prompt.Enabled = true
    prompt.ClickablePrompt = true
    prompt.ObjectText = "Turret Seat"
    prompt.ActionText = "Man the Turret"
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.MaxActivationDistance = 20
    prompt.HoldDuration = 1
    prompt.RequiresLineOfSight = false

    self.Cleaner:Add(prompt.Triggered:Connect(function(player: Player)
        if self.OccupantPlayer == nil and player.Character ~= nil and player.Character.Humanoid ~= nil then
            local hum = player.Character.Humanoid
            if hum.Sit == true then return end
            self.OccupantPlayer = player
            prompt.Enabled = false
            self.Root.Seat:Sit(hum)
        end
    end))

    prompt.Parent = self.Root.BaseMount
    self.ProximityPrompt = prompt
end

function MountedTurret:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(MountedTurret)

return MountedTurret
