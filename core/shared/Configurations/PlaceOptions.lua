local Teams = require(script.Parent.Teams)

export type PlaceStats = {
    Teams: {},
}

local defaultPlaceStats = {
    Teams = {
        {
            Name = "Red",
            Color = BrickColor.new("Bright red"),
            AutoAssignable = false,
            Function = function()
                return true    
            end,
            Value = 1
        },
        {
            Name = "Blue",
            Color = BrickColor.new("Bright blue"),
            AutoAssignable = false,
            Function = function()
                return true    
            end,
            Value = 2
        },
    },
}

return function(placeId: number): PlaceStats
    local placeStats = Teams[placeId]
    if placeStats then
        return {Teams = placeStats}
    end

    return defaultPlaceStats
end