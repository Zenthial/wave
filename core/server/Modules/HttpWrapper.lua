local HttpService = game:GetService("HttpService")

local MAINFRAME_WEBSITE = "http://tommyscholly.com"
local SKINS_ENDPOINT = "/skins"


local HttpWrapper = {}

function HttpWrapper:GetSkins(player: Player)
    local response = HttpService:RequestAsync({
        Method = "GET",
        Url = MAINFRAME_WEBSITE..SKINS_ENDPOINT..tostring(player.UserId)
    })

    print(response.Status)
    if response.Status == 200 then
        return response.Body --[[
            {
                ["W17"] = {"one", "two", "three"}
            }
        ]]
    else
        return nil
    end
end

return HttpWrapper
