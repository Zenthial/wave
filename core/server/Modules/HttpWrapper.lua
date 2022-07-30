---@diagnostic disable: invalid-class-name
local HttpService = game:GetService("HttpService")

local MAINFRAME_WEBSITE = "http://tommyscholly.com"
local SKINS_ENDPOINT = "/users/skins"
local STATS_ENDPOINT = "/users/stats"

local HttpWrapper = {}

function HttpWrapper:GetSkins(player: Player)
    local response = HttpService:RequestAsync({
        Method = "GET",
        Url = MAINFRAME_WEBSITE..SKINS_ENDPOINT..tostring(player.UserId)
    })

    print(response.StatusCode)
    if response.StatusCode == 200 then
        return response.Body --[[
            {
                ["W17"] = {"one", "two", "three"}
            }
        ]]
    else
        return nil
    end
end

function HttpWrapper:UpdatePlayerStats(player: Player)
    local statsFolder = player:FindFirstChild("Stats")
    assert(statsFolder ~= nil and typeof(statsFolder) == "Folder", "No Stats Folder found on "..player.Name)

    local response = HttpService:RequestAsync({
        Method = "POST",
        Body = {
            UserId = player.UserId,
            Stats = statsFolder:GetAttributes()
        },
        Url = MAINFRAME_WEBSITE..STATS_ENDPOINT..tostring(player.UserId)
    })

    print(response.StatusCode)
    return response.StatusCode
end

function HttpWrapper:GetPlayerStats(player: Player)
    
end

return HttpWrapper
