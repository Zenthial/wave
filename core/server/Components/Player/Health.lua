local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))

local DEFAULT_HEALTH_STATS = {
    MAX_HEALTH = 75,
    MAX_SHIELD = 25,
    RECHARGE_WAIT = 10,
    RECHARGE_TIME = 4
}

local Health = {}
Health.__index = Health
Health.Name = "Health"
Health.Tag = "Health"
Health.Needs = {"Cleaner"}

function Health.new(root: any)
    return setmetatable({
        Root = root,
        Dead = false,

        Events = {
            HealthChanged = Signal.new(),
            ShieldChanged = Signal.new(),
            Died = Signal.new()
        }
    }, Health)
end

function Health:Start()
    self.MaxHealth = DEFAULT_HEALTH_STATS.MAX_HEALTH
    self.Root:SetAttribute("MaxHealth", DEFAULT_HEALTH_STATS.MAX_HEALTH)
    self.MaxShields = DEFAULT_HEALTH_STATS.MAX_SHIELD
    self.Root:SetAttribute("MaxShields", DEFAULT_HEALTH_STATS.MAX_SHIELD)

    self.MaxTotalHealth = self.MaxHealth + self.MaxShields
    self.Root:SetAttribute("MaxTotalHealth", self.MaxTotalHealth)
    
    self.RechargeTime = DEFAULT_HEALTH_STATS.RECHARGE_TIME
    self.RechargeWait = DEFAULT_HEALTH_STATS.RECHARGE_WAIT
    
    self:SetHealth(DEFAULT_HEALTH_STATS.MAX_HEALTH)
    self:SetShields(DEFAULT_HEALTH_STATS.MAX_SHIELD)
    self:SetTotalHealth(self.MaxHealth + self.MaxShields)
    
    self.LastTotal = self.TotalHealth
    self.DamageTime = tick()
    self.Charging = false

    if self.Root.Character ~= nil then
        self.Character = self.Root.Character
        self.ShieldModelComponent = tcs.get_component(self.Character, "ShieldModel") --[[:await()]]
    end

    self.Cleaner:Add(self.Root.CharacterAdded:Connect(function(char)
        self.Character = char
        self.ShieldModelComponent = tcs.get_component(self.Character, "ShieldModel") --[[:await()]]
    end))

    -- lots of legacy wace trash here
    self.Cleaner:Add(self.Root:GetAttributeChangedSignal("TotalHealth"):Connect(function()
        self.TotalHealth = self.Root:GetAttribute("TotalHealth")
        local currentTotalHealth = math.clamp(self.TotalHealth, 0, self.MaxTotalHealth) :: number
        local previousTotalHealth = self.LastTotal :: number

        local damage = previousTotalHealth - currentTotalHealth
        local availableDamage = damage -- overwritten down the line

        local newShield = self.Shields
        local newHealth = self.Health

        if damage > 0 then
            self.DamageTime = tick()
        end

        if (damage > 0 and currentTotalHealth > 0) or (currentTotalHealth - damage > self.MaxHealth) or self.Charging then
            if damage > 0 then
                newShield = self.Shields - damage
                availableDamage = -(self.Shields - damage)

                if self.Shields > 0 and self.Shields - damage <= 0 then
                    self.ShieldModelComponent:ShieldEmpty()
                end

            elseif self.Charging then
                availableDamage = damage
                newShield -= availableDamage
            else
                availableDamage = (self.MaxHealth - newHealth) + damage
                newShield -= availableDamage
                availableDamage = damage - availableDamage
            end

            if newShield < 0 then
                newShield = 0
            elseif newShield > self.MaxShields then
                newShield = self.MaxShields
            else
                if self.ShieldModelComponent ~= nil then
                    self.ShieldModelComponent:UpdateShieldTransparency(newShield/self.MaxShields)
                    task.delay(0.2, function()
                        if not self.Charging then
                            self.ShieldModelComponent:UpdateShieldTransparency(1)
                        end
                    end)
                end
            end
        end

        if not self.Charging and (newShield <= 0 or damage < 0) then
			newHealth -= availableDamage
		end

        if newHealth <= 0 then
			newHealth = 0
		elseif newShield <= 0 then
			newHealth = math.clamp(self.TotalHealth, 0, self.MaxHealth)
		elseif newHealth > self.MaxHealth then
			newHealth = self.MaxHealth
		end

        if self.TotalHealth == self.MaxTotalHealth then
            newHealth = self.MaxHealth
            newShield = self.MaxShields
        end

        self.LastTotal = currentTotalHealth
        print(string.format("setting new health %d and shields %d", newHealth, newShield))
        self:SetHealth(newHealth)
        self:SetShields(newShield)

        self:RegenShield(self.DamageTime)

        if currentTotalHealth <= 0 then
            self.Dead = true
            self.Events.Died:Fire()
        end
    end))
end

function Health:SetHealth(health: number)
    health = math.clamp(health, 0, self.MaxHealth)
    self.Health = health

    local player = self.Root :: Player
    player:SetAttribute("Health", health)
end

function Health:SetShields(shields: number)
    shields = math.clamp(shields, 0, self.MaxShields)
    self.Shields = shields
    
    local player = self.Root :: Player
    player:SetAttribute("Shields", shields)
end

function Health:SetTotalHealth(trueHealth: number)
    trueHealth = math.clamp(trueHealth, 0, self.MaxTotalHealth)
    self.TotalHealth = trueHealth
    
    local player = self.Root :: Player
    if self.TotalHealth <= 0 then
        self.Dead = true
    else
        self.Dead = false
    end
    player:SetAttribute("TotalHealth", trueHealth)
end

function Health:RegenShield(lastDamageTime: number)
    task.spawn(function()
        if not self.Charging and self.Shields < self.MaxShields and not self.Dead then
            task.wait(self.RechargeTime)
            if lastDamageTime >= self.DamageTime then
                self.Charging = true
                while self.Shields < self.MaxShields and lastDamageTime >= self.DamageTime do
                    self:SetTotalHealth(self.TotalHealth + 1)
                    task.wait(0.08)
                end
                self.Charging = false
                self:RegenShield(tick())
            end
        end
    end)
end

function Health:TakeDamage(damage: number)
    self:SetTotalHealth(self.TotalHealth - damage)
end

function Health:Destroy()
    self.Cleaner:Destroy()
end

tcs.create_component(Health)

return Health