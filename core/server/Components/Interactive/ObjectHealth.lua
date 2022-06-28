
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

    self.Root:SetAttribute("CurrentHealth", defaultHealth)

    self.MaxHealth = defaultHealth
    self.CurrentHealth = defaultHealth

    if regenSpeed > 0 and regenRate > 0 then
        self.Active = true
        self:StartRegenLoop(regenSpeed, regenRate)
    end
end

function ObjectHealth:StartRegenLoop(regenSpeed: number, regenRate: number)
    while self.Active do
        if self.CurrentHealth < self.MaxHealth then
            self.CurrentHealth = math.clamp(self.CurrentHealth + regenRate, 0, self.MaxHealth)
            self.Root:SetAttribute("CurrentHealth", self.CurrentHealth)
        end

        task.wait(regenSpeed)
    end
end

function ObjectHealth:TakeDamage(damage)

end

function ObjectHealth:Destroy()
    self.Active = false
    self.Cleaner:Clean()
end

tcs.create_component(ObjectHealth)
return ObjectHealth
