
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

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
    Root: {Trigger: BasePart},

    Cleaner: Cleaner_T
}

local ObjectHealth: ObjectHealth_T = {}
ObjectHealth.__index = ObjectHealth
ObjectHealth.Name = "ObjectHealth"
ObjectHealth.Tag = "ObjectHealth"
ObjectHealth.Ancestor = game

function ObjectHealth.new(root: any)
    return setmetatable({
        Debounce = false,
        Root = root,
    }, ObjectHealth)
end

function ObjectHealth:Start()
    local defaultHealth = self.Root:GetAttribute("DefaultHealth")
    assert(typeof(defaultHealth) == "number", "DefaultHealth was not a number")
    local regenSpeed = self.Root:GetAttribute("RegenSpeed")
    assert(typeof(regenSpeed) == "number", "RegenSpeed was not a number")

    self.MaxHealth = defaultHealth
    self.CurrentHealth = defaultHealth

    
end

function ObjectHealth:TakeDamage(damage)

end

function ObjectHealth:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(ObjectHealth)
return ObjectHealth
