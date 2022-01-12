local AnimationData = {}

local types = require(script.Parent:WaitForChild("Types"))

function AnimationData.new(name: string, id: number)
    local self: types.AnimationDataTab = {
        Name = name,
        TrackId = id,
        MarkerSignals = {},
    }
    return self;
end

return AnimationData

--[[
    EXAMPLE:

    local rollAnimationData = AnimationData.new(...)
    rollAnimationData.MarkerSignals["ShakeCamera"] = function(paramString: string)
        --do stuff
    end
]]