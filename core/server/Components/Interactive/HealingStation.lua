local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local STATION_DEBOUNCE = 30

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type HealingStation_T = {
    __index: HealingStation_T,
    Name: string,
    Tag: string,
    Debounce: boolean,
    Root: {Trigger: BasePart},

    Cleaner: Cleaner_T
}

local HealingStation: HealingStation_T = {}
HealingStation.__index = HealingStation
HealingStation.Name = "HealingStation"
HealingStation.Tag = "HealingStation"
HealingStation.Ancestor = game

function HealingStation.new(root: any)
    return setmetatable({
        Debounce = false,
        Root = root,
    }, HealingStation)
end

function HealingStation:Start()
    self.Cleaner:Add(self.Root.Trigger.Touched:Connect(function(hit)
    	if self.Debounce then return end
        local name = hit.Parent.Name
        local player = Players:FindFirstChild(name)
        if not player or not player:IsA("Player") then return end

        local healthComponent = tcs.get_component(player, "Health")
        healthComponent:SetTotalHealth(player:GetAttribute("MaxTotalHealth"))
        
        self.Debounce = true
        self.Root.Indicator.ParticleEmitter.Enabled = true
        self.Root.Indicator.BrickColor = BrickColor.new("Black")
        self.Root.Indicator.PointLight.Enabled = false
        self.Root.Indicator.Recharge:Play()
        
        task.delay(.2, function()
            self.Root.Indicator.ParticleEmitter.Enabled = false
        end)
        
        task.delay(STATION_DEBOUNCE, function()
            self.Debounce = false
            self.Root.Indicator.BrickColor = BrickColor.new("Lime green")
            self.Root.Indicator.PointLight.Enabled = true
        end)
    end))
end

function HealingStation:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(HealingStation)

return HealingStation