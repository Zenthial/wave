local Players = game:GetService("Players")
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
    Root: Player,

    Cleaner: Cleaner_T
}

local Health: Health_T = {}
Health.__index = Health
Health.Name = "Health"
Health.Tag = "Health"
Health.Ancestor = Players

function Health.new(root: any)
    print("creating component heal")
    return setmetatable({
        Root = root,
    }, Health)
end

function Health:Start()
    self.Root:SetAttribute("MaxHealth", DEFAULT_HEALTH_STATS.MAX_HEALTH)
    self.Root:SetAttribute("MaxShields", DEFAULT_HEALTH_STATS.MAX_SHIELD)

    self.Root:SetAttribute("Health", DEFAULT_HEALTH_STATS.MAX_HEALTH)
    self.Root:SetAttribute("OldHealth", DEFAULT_HEALTH_STATS.MAX_HEALTH)
    self.Root:SetAttribute("Shields", DEFAULT_HEALTH_STATS.MAX_SHIELD)
    self.Root:SetAttribute("OldShields", DEFAULT_HEALTH_STATS.MAX_SHIELD)
    self.Root:SetAttribute("Dead", false)

    self.RechargeTime = DEFAULT_HEALTH_STATS.RECHARGE_TIME
    self.RechargeWait = DEFAULT_HEALTH_STATS.RECHARGE_WAIT

    self.DamageTime = tick()
    self.Root:SetAttribute("ShieldRegening", false)

    if self.Root.Character ~= nil then
        self.Character = self.Root.Character
        self.ShieldModelComponent = tcs.get_component(self.Character, "ShieldModel")
    end

    self.Cleaner:Add(self.Root.CharacterAdded:Connect(function(char)
        self.Character = char
        self.ShieldModelComponent = tcs.get_component(self.Character, "ShieldModel")
    end))

    self.Cleaner:Add(self.Root:GetAttributeChangedSignal("Health"):Connect(function()
        local health = self.Root:GetAttribute("Health")
        local oldHealth = self.Root:GetAttribute("OldHealth")
        
        if health ~= oldHealth then
            self:SetHealth(health)
        end
    end))

    self.Cleaner:Add(self.Root:GetAttributeChangedSignal("Shields"):Connect(function()
        local shields = self.Root:GetAttribute("Shields")
        local oldShields = self.Root:GetAttribute("OldShields")
        
        if shields ~= oldShields then
            self:SetShields(shields)
        end
    end))
end

function Health:SetShields(shields)
    self.Root:SetAttribute("OldShields", self.Root:GetAttribute("Shields"))
    self.Root:SetAttribute("Shields", shields)

    if self.ShieldModelComponent ~= nil then
        self.ShieldModelComponent:UpdateShieldTransparency(self.Root:GetAttribute("Shields") / self.Root:GetAttribute("MaxShields"))
        task.delay(0.2, function()
            if not self.Root:GetAttribute("ShieldRegening") then
                self.ShieldModelComponent:UpdateShieldTransparency(1)
            end
        end)
    end

    if shields == 0 then
        self.DamageTime = tick()
        self.ShieldModelComponent:ShieldEmpty()
        self:RegenShield(self.DamageTime)
    end
end

function Health:ResetExtraShields()
    self.Root:SetAttribute("MaxShields", DEFAULT_HEALTH_STATS.MAX_SHIELD)
    self:SetShields(DEFAULT_HEALTH_STATS.MAX_SHIELD)
end

function Health:AddExtraShields(extraAmount: number)
    local oldMax = self.Root:GetAttribute("MaxShields")
    local newMax = oldMax + extraAmount
    self.Root:SetAttribute("MaxShields", newMax)
    self:SetShields(self.Root:GetAttribute("Shields") + extraAmount)
end

function Health:SetHealth(health)
    health = math.clamp(health, 0, self.Root:GetAttribute("MaxHealth"))

    if health == 0 and self.Root:GetAttribute("Dead") == false then
        self.Root:SetAttribute("Dead", true)
        self.ShieldModelComponent:Spawn()
    elseif health > 0 and self.Root:GetAttribute("Dead") == true then
        self.Root:SetAttribute("Dead", false)
    end

    self.Root:SetAttribute("OldHealth", self.Root:GetAttribute("Health"))
    self.Root:SetAttribute("Health", health)
end

function Health:RegenShield(lastDamageTime: number)
    task.spawn(function()
        if not self.Root:GetAttribute("ShieldRegening") and self.Root:GetAttribute("Shields") < self.Root:GetAttribute("MaxShields") and not self.Root:GetAttribute("Dead") then
            task.wait(self.RechargeTime)
            if lastDamageTime >= self.DamageTime then
                self.Root:SetAttribute("ShieldRegening", true)
                while self.Root:GetAttribute("Shields") < self.Root:GetAttribute("MaxShields") and lastDamageTime >= self.DamageTime and not self.Root:GetAttribute("Dead") do
                    self:SetShields(self.Root:GetAttribute("Shields") + 1)
                    task.wait(0.17) -- probably should not be hard coded
                end
                self.Root:SetAttribute("ShieldRegening", false)
                self:RegenShield(tick())
            end
        end
    end)
end

function Health:TakeDamage(damage: number)
    local currentHealth = self.Root:GetAttribute("Health")
    local currentShields = self.Root:GetAttribute("Shields")

    if damage > 0 then
        if currentShields > 0 then
            if currentShields - damage <= 0 then
                self:SetShields(0)
                damage = damage - currentShields
            else
                self:SetShields(currentShields - damage)
                damage = 0
            end
        end

        if damage > 0 then
            if currentHealth - damage <= 0 then
                self:SetHealth(0)
            else
                self:SetHealth(currentHealth - damage)
            end
        end
    -- healing!
    elseif damage < 0 then
        local maxHealth = self.Root:GetAttribute("MaxHealth")
        local heals = -(damage)
        if currentHealth + heals <= maxHealth then
            self:SetHealth(currentHealth + heals)
        elseif currentHealth + heals > maxHealth then
            self:SetHealth(maxHealth)
            heals = heals - (maxHealth - currentHealth)
        end

        if heals > 0 then
            local newShields = currentShields + heals
            newShields = math.clamp(newShields, 0, self.Root:GetAttribute("MaxShields"))
            self:SetShields(newShields)
        end
    end
end

function Health:Heal(health: number)
    self:TakeDamage(-health)
end

function Health:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(Health)

return Health