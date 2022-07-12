local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local VehicleStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("VehicleStats"))

local DEFAULT_VEHICLE_HEALTH = 1000

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type VehicleHealth_T = {
    __index: VehicleHealth_T,
    Name: string,
    Tag: string,
    Root: Model & {
        Chassis: Model & {
            Treads: Model
        }
    },

    Cleaner: Cleaner_T
}

local VehicleHealth: VehicleHealth_T = {}
VehicleHealth.__index = VehicleHealth
VehicleHealth.Name = "VehicleHealth"
VehicleHealth.Tag = "VehicleHealth"
VehicleHealth.Ancestor = workspace

function VehicleHealth.new(root: any)
    return setmetatable({
        Root = root,
    }, VehicleHealth)
end

function VehicleHealth:Start()
    local stats = VehicleStats[self.Root.Name]
    assert(stats, "No Vehicle Stats for " .. self.Root.Name)
    self.Stats = stats

    local health = stats.Health or DEFAULT_VEHICLE_HEALTH
    self.Root:SetAttribute("MaxHealth", health)
    self.MaxHealth = health
    self:SetHealth(health)
end

function VehicleHealth:SetHealth(health: number)
    health = math.clamp(health, 0, self.MaxHealth)
    self.Health = health
    self.Root:SetAttribute("Health", health)
    if health <= 0 then
        self.Root:SetAttribute("Dead", true)
    else
        self.Root:SetAttribute("Dead", false)
    end
end

function VehicleHealth:TakeDamage(damage: number)
    self:SetHealth(self.Health - damage)
end

function VehicleHealth:Destroy()
    self.Cleaner:Clean()
end

return VehicleHealth
