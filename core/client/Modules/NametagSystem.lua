-- Preston (seliso)
-- 7/10/2022
--------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

--local util = ReplicatedStorage:WaitForChild("Shared").util
--local promise = require(util.Promise)

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local Client = Players.LocalPlayer

--------------------------------------------------------------------------------------------
-- Local methods

local function playerSameStrikeTeam(client: Player, player: Player)
    return client:GetAttribute("StrikeTeam") == player:GetAttribute("StrikeTeam")
end

local function getTeamColor(player: Player): Color3
    if player.TeamColor ~= Client.TeamColor then
        return Color3.fromRGB(254, 85, 85)
    end

    local allyColor =Color3.fromRGB(47, 110, 255)

    if playerSameStrikeTeam(Client, player) then
        allyColor = Color3.fromRGB(83, 255, 195)
    end

    return allyColor
end

local function updTagColors(player)
    if player.Character == nil then return end 

    local teamColor = getTeamColor(player)
    local nameTag = tcs.getcomponent(player.Character, "Tag")

    if nameTag == nil then return end

    local tags = {
        tcs.getcomponent(nameTag.Tag, "TitleTag"),
        tcs.getcomponent(nameTag.Tag, "SubtextTag"),
        tcs.getcomponent(nameTag.Tag, "ImageTag")
    }
    for _, tag in pairs(tags) do 
        if tag == nil then continue end
        tag:SetColor(teamColor)
    end
end

local function changeStrikeTeam(player)
    if player.Character == nil then return end 

    --add tag if player is on same striketeam along with being on the same team
    updTagColors(player)

    local nameTag = tcs.getcomponent(player.Character, "Tag")

    if nameTag == nil then return end

    if playerSameStrikeTeam(Client, player) and player.TeamColor == Client.TeamColor then 
        CollectionService:AddTag(nameTag.Tag, "HealthTag")
        local healthTag = tcs.get_component(nameTag.Tag, "HealthTag")
        healthTag:ConnectTo(player)
        return 
    end

    --remove tag

     CollectionService:RemoveTag(nameTag.Tag, "HealthTag")
end

local function playerAdded(player: Player)

    local function changeTeam(prop: string)    
        if player.Character == nil then return end 
        if prop ~= "TeamColor" then return end

        local nameTag = tcs.getcomponent(player.Character, "Tag")

        if nameTag == nil then return end

        changeStrikeTeam(player)

        if player.TeamColor ~= Client.TeamColor then
            nameTag:Disable()    
            return
        end
        nameTag:Enable() 
    end 

    local function characterAdded(character)
        --tag setup
        CollectionService:AddTag(character, "Tag")
        local nameTag = tcs.await_component(character, "Tag")
        nameTag:SetAdornee(character.Head)

        CollectionService:AddTag(nameTag.Tag, "TitleTag")
        local titleTag = tcs.await_component(nameTag.Tag, "TitleTag")
        titleTag:SetText(player.DisplayName)

        changeTeam("TeamColor")
        changeStrikeTeam(player)
    end

    if player.Character then
        characterAdded(player.Character)
    end
    player.CharacterAdded:Connect(characterAdded)
    player.Changed:Connect(changeTeam)
    player:GetAttributeChangedSignal("StrikeTeam"):Connect(function() changeStrikeTeam(player) end)
end

local function clientChangeStrikeTeam()
    for _, player in pairs(Players:GetPlayers()) do
        if player == Client then continue end
        if player.TeamColor ~= Client.TeamColor then continue end
        if playerSameStrikeTeam(Client, player) == false then continue end

        changeStrikeTeam(player)
    end
end

local function clientTeamChange(prop: string)
    if prop ~= "TeamColor" then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == Client then continue end

        local nameTag = tcs.getcomponent(player.Character, "Tag")

        if nameTag == nil then return end

        clientChangeStrikeTeam()

        if player.TeamColor ~= Client.TeamColor then
            nameTag:Disable()
            continue
        end

        nameTag:Enable()
    end
end

--------------------------------------------------------------------------------------------
-- Class

local NametagSystem = {}

function NametagSystem:Start()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == Client then continue end
        playerAdded(player)
    end
    Players.PlayerAdded:Connect(playerAdded)

    clientTeamChange("TeamColor")
    clientChangeStrikeTeam()
    Client.Changed:Connect(clientTeamChange)
    Client:GetAttributeChangedSignal("StrikeTeam"):Connect(clientChangeStrikeTeam)
end

return NametagSystem