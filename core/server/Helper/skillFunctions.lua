return {
    deleteSkillModel = function(player: Player)
        
    end,
    createSkillModel = function(player: Player)
        
    end,
    setTableTransparency = function(player, objTable, transparency)
        if transparency then
            for i,v in pairs(objTable) do
                v.Transparency = transparency
            end
        else
            for i,v in pairs(objTable) do
                if v:IsA("Decal") then
                    v.Transparency = 0
                else
                    if string.sub(v.Name, 1, 8) == "Hologram" then
                        v.Transparency = 0.25
                    elseif string.sub(v.Name, 1, 5) == "Blade" or string.sub(v.Name, 1, 7) == "Battery" or v.Name == "Reactor" then
                        v.Transparency = 0
                    elseif string.sub(v.Name, 1, 5) == "Glass" then
                        v.Transparency = 0.75
                        v.Material = "SmoothPlastic"
                    elseif string.sub(v.Name, 1, 6) == "Bottle" then
                        v.Transparency = 0.5
                        v.Material = "Neon"
                    elseif string.sub(v.Name, 1, 5) == "Three" and (v.Parent.Name == "STUN" or v.Parent.Name == "TAG") then
                        v.Transparency = 0.75
                    else 
                        v.Transparency = 0
                        v.Material = "SmoothPlastic"
                    end
                end
            end
        end
    end
}