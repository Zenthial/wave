local WIJ_ID = 3747606

return {
    ["HEX"] = {

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
        }
    }
}