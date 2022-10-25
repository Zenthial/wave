local CollectionService = game:GetService("CollectionService")
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

type StaticTurret_T = {
    __index: StaticTurret_T,
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

local StaticTurret: StaticTurret_T = {}
StaticTurret.__index = StaticTurret
StaticTurret.Name = "StaticTurret"
StaticTurret.Tag = "StaticTurret"
StaticTurret.Ancestor = workspace

function StaticTurret.new(root: any)
    return setmetatable({
        Root = root,
    }, StaticTurret)
end

function StaticTurret:Start()
    print("static turret started")
    local vehicleSeat = self.Root.Parent.CopilotSeat
    assert(vehicleSeat ~= nil, "No Seat in "..self.Root.Parent.Name)

    self:InitializeProximityPrompt()

    local vehicleSeatComponent = tcs.get_component(vehicleSeat, "VehicleSeat")
    self.Cleaner:Add(vehicleSeatComponent.Events.OccupantChanged:Connect(function(newOccupant, oldOccupant)
        if newOccupant ~= nil then
            self.Courier:Send("BindToStaticTurret", newOccupant, self.Root, self.Root.Name)
        else
            self.OccupantPlayer = nil
            self.ProximityPrompt.Enabled = true
            self.Courier:Send("UnbindFromStaticTurret", oldOccupant, self.Root, self.Root.Name)
        end
    end))
end

function StaticTurret:InitializeProximityPrompt()
    local prompt = Instance.new("ProximityPrompt")
    prompt.Enabled = true
    prompt.ClickablePrompt = true
    prompt.ObjectText = "Turret Seat"
    prompt.ActionText = "Man the Turret"
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
            self.Root.Parent.CopilotSeat:Sit(hum)
        end
    end))

    prompt.Parent = self.Root.Parent.CopilotSeat
    self.ProximityPrompt = prompt
end

function StaticTurret:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(StaticTurret)

return StaticTurret
