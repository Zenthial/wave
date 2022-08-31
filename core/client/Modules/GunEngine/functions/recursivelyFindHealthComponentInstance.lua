local Players = game:GetService("Players")

local function recursivelyFindHealthComponentInstance(part: BasePart)
    if part:GetAttribute("Health") ~= nil then
        return part
    else
        local player: Player = Players:GetPlayerFromCharacter(part)
        if player then
            return player
        elseif part.Parent ~= workspace then
            return recursivelyFindHealthComponentInstance(part.Parent)
        else
            return nil
        end
    end
end

return recursivelyFindHealthComponentInstance