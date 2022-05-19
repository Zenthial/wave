local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local DEFAULT_HEALTH_STATS = {
    MAX_HEALTH = 75,
    MAX_SHIELD = 25,
    RECHARGE_WAIT = 10,
    RECHARGE_TIME = 4
}

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Health_T = {
    __index: Health_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T
}

local Health: Health_T = {}
Health.__index = Health
Health.Name = "Health"
Health.Tag = "Health"
Health.Ancestor = game

function Health.new(root: any)
    return setmetatable({
        Root = root,
    }, Health)
end

function Health:Start()
    self.Root:SetAttribute("MaxHealth", DEFAULT_HEALTH_STATS.MAX_HEALTH)
    self.Root:SetAttribute("MaxShields", DEFAULT_HEALTH_STATS.MAX_SHIELD)
    self.Root:SetAttribute("MaxTotalHealth", DEFAULT_HEALTH_STATS.MAX_HEALTH + DEFAULT_HEALTH_STATS.MAX_SHIELD)
    self.Root:SetAttribute("TotalHealth", DEFAULT_HEALTH_STATS.MAX_HEALTH + DEFAULT_HEALTH_STATS.MAX_SHIELD)
    self.Root:SetAttribute("OldTotalHealth", DEFAULT_HEALTH_STATS.MAX_HEALTH + DEFAULT_HEALTH_STATS.MAX_SHIELD)
    self.Root:SetAttribute("Health", DEFAULT_HEALTH_STATS.MAX_HEALTH)
    self.Root:SetAttribute("Shields", DEFAULT_HEALTH_STATS.MAX_SHIELD)
    self.Root:SetAttribute("Dead", false)

    self.DamageTime = tick()
    self.Root:SetAttribute("ShieldRegening", false)

    if self.Root.Character ~= nil then
        self.Character = self.Root.Character
        self.ShieldModelComponent = tcs.get_component(self.Character, "ShieldModel") --[[:await()]]
    end

    self.Cleaner:Add(self.Root.CharacterAdded:Connect(function(char)
        self.Character = char
        self.ShieldModelComponent = tcs.get_component(self.Character, "ShieldModel") --[[:await()]]
    end))

    self:SetTotalHealth(self.Root:GetAttribute("MaxTotalHealth"))
    self:SetupHealthChangeListener()  
end

function Health:SetupHealthChangeListener()
    self.Cleaner:Add(self.Root:GetAttributeChangedSignal("TotalHealth"):Connect(function()
        local totalHealth = self.Root:GetAttribute("TotalHealth")
        local oldTotalHealth = self.Root:GetAttribute("OldTotalHealth")

        local oldHealth = self.Root:GetAttribute("Health")
        local oldShields = self.Root:GetAttribute("Shields")

        local damageDealt = oldTotalHealth - totalHealth
        if damageDealt > 0 then
            local newShields
            local remainder = 0

            if damageDealt <= oldShields then
                newShields = oldShields - damageDealt
            else
                newShields = 0
                remainder = damageDealt - oldShields
            end

            self:SetShields(newShields)
            
            if remainder > 0 then
                local newHealth
                
                if remainder > oldHealth then
                    newHealth = 0
                else
                    newHealth = oldHealth - remainder
                end

                self:SetHealth(newHealth)
            end

            self.DamageTime = tick()
            self:RegenShield(self.DamageTime)
        end
    end))
end

function Health:SetTotalHealth(totalHealth)
    totalHealth = math.clamp(totalHealth, 0, self.Root:GetAttribute("MaxTotalHealth"))

    if totalHealth <= 0 then
        self.Root:SetAttribute("Dead", true)
    else
        self.Root:SetAttribute("Dead", false)
    end

    self.Root:SetAttribute("TotalHealth", totalHealth)
end

function Health:SetShields(shields)
    self.Root:SetAttribute("Shields", shields)

    if self.ShieldModelComponent ~= nil then
        self.ShieldModelComponent:UpdateShieldTransparency(self.Root:GetAttribute("Shields")/self.Root:GetAttribute("MaxShields"))
        task.delay(0.2, function()
            if not self.Root:GetAttribute("ShieldRegening") then
                self.ShieldModelComponent:UpdateShieldTransparency(1)
            end
        end)
    end
end

function Health:SetHealth(health)
    health = math.clamp(health, 0, self.Root:GetAttribute("MaxHealth"))
    self.Root:SetAttribute("Health", health)
end

function Health:RegenShield(lastDamageTime: number)
    task.spawn(function()
        if not self.Root:GetAttribute("ShieldRegening") and self.Root:GetAttribute("Shields") < self.Root:GetAttribute("MaxShields") and not self.Root:GetAttribute("Dead") then
            task.wait(self.RechargeTime)
            if lastDamageTime >= self.DamageTime then
                self.Root:SetAttribute("ShieldRegening", true)
                while self.Root:GetAttribute("Shields") < self.Root:GetAttribute("MaxShields") and lastDamageTime >= self.DamageTime do
                    self:SetTotalHealth(self.Root:GetAttribute("TotalHealth") + 1)
                    task.wait(0.08)
                end
                self.Root:SetAttribute("ShieldRegening", false)
                self:RegenShield(tick())
            end
        end
    end)
end

function Health:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(Health)

return Health