local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local OrbStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("OrbStats"))

local ORB_DEBOUNCE = 60

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type HealingOrb_T = {
    __index: HealingOrb_T,
    Name: string,
    Tag: string,
    Debounce: boolean,
    Root: Model & {
        Trigger: BasePart
    },

    Cleaner: Cleaner_T
}

local HealingOrb: HealingOrb_T = {}
HealingOrb.__index = HealingOrb
HealingOrb.Name = "HealingOrb"
HealingOrb.Tag = "HealingOrb"
HealingOrb.Ancestor = game

function HealingOrb.new(root: any)
    return setmetatable({
        Debounce = false,

        Root = root,
    }, HealingOrb)
end

function HealingOrb:Start()
    self.Cleaner:Add(self.Root.Trigger.Touched:Connect(function(hit)
    	if self.Debounce then return end
        local name = hit.Parent.Name
        local player = Players:FindFirstChild(name)
        if not player or not player:IsA("Player") then return end

        local healthComponent = tcs.get_component(player, "Health")
        healthComponent:TakeDamage(-OrbStats[string.lower(self.Root.Name)])
        
        self.Debounce = true
        self.Root.Particles.Aura.Enabled = false
        self.Root.Particles.Pickup.Enabled = true
        self.Root.Trigger.Sound:Play()
        self.Root.Trigger.Transparency = 1
        self.Root.Body.Transparency = 1

        task.delay(0.2, function()
            self.Root.Particles.Pickup.Enabled = false
            self.Root.Trigger.PointLight.Enabled = false
        end)
        
        task.delay(ORB_DEBOUNCE, function()
            self.Debounce = false
            self.Root.Particles.Aura.Enabled = true
            self.Root.Particles.Pickup.Enabled = true
            self.Root.Trigger.PointLight.Enabled = true
            self.Root.Trigger.Transparency = 0.5
            self.Root.Body.Transparency = 0

            task.delay(.1, function()
                self.Root.Particles.Pickup.Enabled = false
            end)
        end)
    end))
end

function HealingOrb:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(HealingOrb)

return HealingOrb