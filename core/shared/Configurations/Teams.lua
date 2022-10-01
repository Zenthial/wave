local WIJ_ID = 3747606

return {
    ["HEX"] = {

    },

    ["Arenas"] = {
        {
            Name = "Red",
            Color = BrickColor.new("Bright red"),
            AutoAssignable = false,
            Function = function()
                return false    
            end,
            Value = 1
        },
        {
            Name = "Blue",
            Color = BrickColor.new("Bright blue"),
            AutoAssignable = false,
            Function = function()
                return false    
            end,
            Value = 2
        },
        {
            Name = "Intermission",
            Color = BrickColor.new("Institutional white"),
            AutoAssignable = true,
            Function = function()
                return true
            end,
            Value = 3
        }
    },

    ["Swordfish"] = {
        {
            Name = "Raiders",
            Color = BrickColor.new("Bright red"),
            AutoAssignable = true,
            Function = function()
                return true
            end,
            Value = 1
        },
        {
            Name = "WIJ",
            Color = BrickColor.new("Bright blue"),
            AutoAssignable = false,
            Function = function(player: Player)
                if player:IsInGroup(WIJ_ID) then
                    return true
                end

                return false
            end,
            Value = 2
        },
        {
            Name = "Civilians",
            Color = BrickColor.new("Grey"),
            AutoAssignable = true,
            Function = function(player: Player)
                return true
            end,
            Value = 3
        }
    }
}