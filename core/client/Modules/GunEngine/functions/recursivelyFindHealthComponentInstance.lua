local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function recursivelyFindHealthComponentInstance(part: BasePart)
    if part:GetAttribute("Health") ~= nil or part:GetAttribute("CurrentHealth") ~= nil or part:GetAttribute("DefaultHealth") ~= nil then
        return part
    else
        local player: Player = Players:GetPlayerFromCharacter(part)
        if player and player.Team ~= LocalPlayer.Team then
            return player
        elseif part.Parent ~= workspace then
            return recursivelyFindHealthComponentInstance(part.Parent)
        else
            return nil
        end
    end
end

return recursivelyFindHealthComponentInstance