local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local SoundHandler = {}

function SoundHandler:Start()
    repeat
        task.wait(1)
    until Player:GetAttribute("Loaded") == true and typeof(Player:GetAttribute("Health")) == "number"

    local lowHealthPlaying = false
    Player:GetAttributeChangedSignal("Health"):Connect(function()
        if Player:GetAttribute("Dead") then return end
        local newHealth = Player:GetAttribute("Health")
        local newShields = Player:GetAttribute("Shields")

        if newHealth + newShields < (Player:GetAttribute("MaxHealth") + Player:GetAttribute("MaxShields")) * .2 then
            lowHealthPlaying = true
            SoundService.Sounds.LowHealth:Play()
        elseif lowHealthPlaying == true then
            lowHealthPlaying = false
            SoundService.Sounds.LowHealth:Stop()
        end
    end)

    Player:GetAttributeChangedSignal("Dead"):Connect(function()
        if Player:GetAttribute("Dead") == true then
            SoundService.Sounds.LowHealth:Stop()
        end
    end)

    local regenPlaying = false
    Player:GetAttributeChangedSignal("Shields"):Connect(function()
        if Player:GetAttribute("Dead") then return end
        local newHealth = Player:GetAttribute("Health")
        local newShields = Player:GetAttribute("Shields")
        local oldShields = Player:GetAttribute("OldShields")

        if newShields < oldShields and newShields > 0 then
            SoundService.Sounds.ShieldImpact:Play()
        elseif newShields == 0 then
            -- SoundService.Sounds.ShieldCrack:Play()
        elseif newShields > oldShields and newShields < Player:GetAttribute("MaxShields") and regenPlaying == false then
            regenPlaying = true
            SoundService.Sounds.ShieldRegen:Play()
        elseif newShields == Player:GetAttribute("MaxShields") then
            SoundService.Sounds.ShieldFull:Play()
        elseif newHealth + newShields > (Player:GetAttribute("MaxHealth") + Player:GetAttribute("MaxShields")) * .2 and lowHealthPlaying then
            lowHealthPlaying = false
            SoundService.Sounds.LowHealth:Stop()
        end
    end)

    SoundService.Sounds.ShieldRegen.Stopped:Connect(function()
        regenPlaying = false
    end)
end

return SoundHandler