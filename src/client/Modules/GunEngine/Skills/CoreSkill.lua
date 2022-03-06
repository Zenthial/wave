local CoreSkill = {}
CoreSkill.__index = CoreSkill

function CoreSkill.new(skillStats, model)
    local self = setmetatable({
        CurrentEnergy = 100;
        MaxEnergy = 100;
        MinEnergy = 0;

        Stats = skillStats;
    }, CoreSkill)
    return self
end

function CoreSkill:Destroy()
    
end

return CoreSkill