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
    Thread: thread | nil,
    DefaultHealth: number,
    RegenSpeed: number,
    RegenRate: number,
    DeathRechargeRate: number,
    CanRegen: boolean,

    Cleaner: Cleaner_T
}

local ObjectHealth: ObjectHealth_T = {}
ObjectHealth.__index = ObjectHealth
ObjectHealth.Name = "ObjectHealth"
ObjectHealth.Tag = "ObjectHealth"
ObjectHealth.Ancestor = workspace

function ObjectHealth.new(root: any)
    return setmetatable({
        Active = false,
        Root = root,
        Thread = nil,
    }, ObjectHealth)
end

function ObjectHealth:Start()
    self.DefaultHealth = self.Root:GetAttribute("DefaultHealth")
    assert(typeof(self.DefaultHealth) == "number", "DefaultHealth was not a number")
    self.RegenSpeed = self.Root:GetAttribute("RegenSpeed")
    assert(typeof(self.RegenSpeed) == "number", "RegenSpeed was not a number")
    self.RegenRate = self.Root:GetAttribute("RegenRate")
    assert(typeof(self.RegenRate) == "number", "RegenSpeed was not a number")
    self.DeathRechargeRate = self.Root:GetAttribute("DeathRechargeRate") or -1
    assert(typeof(self.DeathRechargeRate) == "number", "DeathRechargeRate was not a number")
    self.CanRegen = self.Root:GetAttribute("CanRegen") or false
    assert(typeof(self.CanRegen) == "boolean", "CanRegen was not a boolean")

    self.Root:SetAttribute("CurrentHealth", self.DefaultHealth)
    self.Root:SetAttribute("Dead", false)

    self.MaxHealth = self.DefaultHealth
    self.CurrentHealth = self.DefaultHealth

    self.CanRegen = self.Root:GetAttribute("CanRegen")
    self.Dead = false
    
    self.Cleaner:Add(self.Root:GetAttributeChangedSignal("CanRegen"):Connect(function()
        self.CanRegen = self.Root:GetAttribute("CanRegen")
    end))

    -- should we think about adding listeners for the other attributes too? Might be useful if we implement this for mechs or things and change regen rates in phases?
end

function ObjectHealth:StartRegenLoop(regenSpeed: number, regenRate: number, deathRechargeWait: number)
    while self.Active do
        task.wait(regenSpeed)
        if self.CurrentHealth < self.MaxHealth and not self.Dead and self.CanRegen then
            self.CurrentHealth = math.clamp(self.CurrentHealth + regenRate, 0, self.MaxHealth)
            self.Root:SetAttribute("CurrentHealth", self.CurrentHealth)
        end

        if self.CurrentHealth <= 0 then
            self.Dead = true
            self.Root:SetAttribute("Dead", true)
            self.CanRegen = false
            if deathRechargeWait >= 0 then
                task.wait(deathRechargeWait)
                self.CanRegen = true
            end
        end
    end
end

function ObjectHealth:TakeDamage(damage)
    pcall(function()
        task.cancel(self.Thread) -- Behavior is temporary. May not error in the future should a thread not exist
    end)
    local newHealth = math.clamp(self.CurrentHealth - damage, 0, self.MaxHealth)

    self.CurrentHealth = newHealth
    self.Root:SetAttribute("CurrentHealth", newHealth)
    if self.RegenSpeed > 0 and self.RegenRate > 0 and self.CanRegen then
        self.Active = true
        self.Thread = task.spawn(self:StartRegenLoop(self.RegenSpeed, self.RegenRate, self.DeathRechargeRate))
    end
end

function ObjectHealth:Destroy()
    pcall(function()
        task.cancel(self.Thread) -- Behavior is temporary. May not error in the future should a thread not exist
    end)
    self.Active = false
    self.Cleaner:Clean()
end

tcs.create_component(ObjectHealth)

return ObjectHealth
