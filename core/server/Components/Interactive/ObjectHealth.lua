
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type ObjectHealth_T = {
    __index: ObjectHealth_T,
    Name: string,
    Tag: string,
    Debounce: boolean,
    Root: BasePart,

    Cleaner: Cleaner_T
}

local ObjectHealth: ObjectHealth_T = {}
ObjectHealth.__index = ObjectHealth
ObjectHealth.Name = "ObjectHealth"
ObjectHealth.Tag = "ObjectHealth"
ObjectHealth.Ancestor = game

function ObjectHealth.new(root: any)
    return setmetatable({
        Active = false,
        Root = root,
    }, ObjectHealth)
end

function ObjectHealth:Start()
    local defaultHealth = self.Root:GetAttribute("DefaultHealth")
    assert(typeof(defaultHealth) == "number", "DefaultHealth was not a number")
    local regenSpeed = self.Root:GetAttribute("RegenSpeed")
    assert(typeof(regenSpeed) == "number", "RegenSpeed was not a number")
    local regenRate = self.Root:GetAttribute("RegenRate")
    assert(typeof(regenRate) == "number", "RegenSpeed was not a number")
    local deathRechargeWait = self.Root:GetAttribute("DeathRechargeRate")
    assert(typeof(regenRate) == "number", "DeathRechargeRate was not a number")

    self.Root:SetAttribute("CurrentHealth", defaultHealth)
    self.Root:SetAttribute("Dead", false)

    self.MaxHealth = defaultHealth
    self.CurrentHealth = defaultHealth

    self.CanRegen = false
    self.Dead = false
    
    self.Cleaner:Add(self.Root:GetAttributeChangedSignal("CanRegen"):Connect(function()
        self.CanRegen = self.Root:GetAttribute("CanRegen")
    end))

    if regenSpeed > 0 and regenRate > 0 then
        self.Active = true
        self:StartRegenLoop(regenSpeed, regenRate, deathRechargeWait)
    end
end

function ObjectHealth:StartRegenLoop(regenSpeed: number, regenRate: number, deathRechargeWait: number)
    while self.Active do
        if self.CurrentHealth < self.MaxHealth and not self.Dead and self.CanRegen then
            self.CurrentHealth = math.clamp(self.CurrentHealth + regenRate, 0, self.MaxHealth)
            self.Root:SetAttribute("CurrentHealth", self.CurrentHealth)
        end

        if self.CurrentHealth <= 0 then
            self.Dead = true
            self.Root:SetAttribute("Dead", true)
            self.CanRegen = false
            task.wait(deathRechargeWait)
            self.CanRegen = true
        end

        task.wait(regenSpeed)
    end
end

function ObjectHealth:TakeDamage(damage)
    local newHealth = math.clamp(self.CurrentHealth - damage, 0, self.MaxHealth)

    self.Root:SetAttribute("CurrentHealth", newHealth)
    self.CurrentHealth = newHealth
end

function ObjectHealth:Destroy()
    self.Active = false
    self.Cleaner:Clean()
end

tcs.create_component(ObjectHealth)
return ObjectHealth
