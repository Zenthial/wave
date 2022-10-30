local TextService = game:GetService("TextService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Configurations = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations")
local ChatStats = require(Configurations:WaitForChild("ChatStats"))
local courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))

local function chatMiddleware(Player: Player, message: string): string | nil
    local textResultObject: TextFilterResult = nil
    local success, err = pcall(function()
        textResultObject = TextService:FilterStringAsync(message, Player.UserId, Enum.TextFilterContext.PublicChat)
    end)

    if success then
        local filteredMessage

        local success1, errorMessage = pcall(function()
            filteredMessage = textResultObject:GetChatForUserAsync(Player.UserId)
        end)

        if success1 then
            return filteredMessage
        end

        warn(errorMessage, Player.UserId)

        return nil
    else
        warn(string.format("Cannot filter string %s for user %s", message, Player.Name))
        return nil
    end
end

local ChatService = {}

function ChatService:Start()
    courier:Listen("AttemptChat"):Connect(function(Player: Player, message: string)
        local filteredMessage = chatMiddleware(Player, message) 
        if filteredMessage ~= nil then
            local playerTeamColorStats = ChatStats.TeamColors[Player.TeamColor.Name] or ChatStats.TeamColors.Default
            local playerTags = self:GetPlayerTags(Player)
            courier:SendToAll("OnChat", Player.Name, playerTeamColorStats.Text, playerTags, filteredMessage)
        end
    end) 
end

function ChatService:GetPlayerTags(Player: Player)
    local tags = {}

    -- check name tags
    for tagName, userIdTable in pairs(ChatStats.NameTags) do
        if table.find(userIdTable, Player.UserId) ~= nil then
            tags[tagName] = ChatStats.TagColor
        end
    end

    -- check group tags
    for groupId, tagName in pairs(ChatStats.GroupTags) do
        if Player:IsInGroup(tonumber(groupId)) then
            tags[tagName] = ChatStats.TagColor
        end
    end

    -- check rank tags
    local rankTag = nil
    for rankId, tagName in pairs(ChatStats.GroupTags) do
        if Player:GetRankInGroup(ChatStats.DefaultGroupRankCheckId) >= tonumber(rankId) then
            rankTag = tagName
        end
    end

    if rankTag ~= nil then
        tags[rankTag] = ChatStats.TagColor
    end

    return tags
end

return ChatService