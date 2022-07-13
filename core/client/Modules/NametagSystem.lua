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

local function setTagToEnemy(nameTag)
    nameTag:SetColor(Color3.fromRGB(254, 85, 85), Color3.fromRGB(254, 85, 85))
end

local function setTagToAlly(nameTag)
    nameTag:SetColor(Color3.fromRGB(96, 255, 122), Color3.fromRGB(255,255,255))
end

local function playerAdded(player: Player)
    local function changeTeam(prop: string)    
        if  player.Character == nil then return end 
        if prop ~= "TeamColor" then return end
        
        local nameTag = tcs.get_component(player.Character, "Tag")

        if nameTag == nil then return end

        if player.TeamColor ~= Client.TeamColor then
            nameTag:Disable()
            setTagToEnemy(nameTag)
            return
        end

        nameTag:Enable()
        setTagToAlly(nameTag)
    end 

    local function characterAdded(character)
        --tag setup
        CollectionService:AddTag(character, "Tag")
        local nameTag = tcs.get_component(character, "Tag")
        nameTag:SetAdornee(character.Head)

        CollectionService:AddTag(nameTag.Tag, "SubtextTag")
        local subtextTag = tcs.get_component(nameTag.Tag, "SubtextTag")
        subtextTag:SetText(player.DisplayName)

        CollectionService:AddTag(nameTag.Tag, "HealthTag")
        local healthTag = tcs.get_component(nameTag.Tag, "HealthTag")
        healthTag:ConnectTo(player)

        changeTeam("TeamColor")
    end

    if player.Character then
        characterAdded(player.Character)
    end
    player.CharacterAdded:Connect(characterAdded)
    player.Changed:Connect(changeTeam)
end

local function clientTeamChange(prop: string)
    if prop ~= "TeamColor" then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == Client then continue end

        local nameTag = tcs.get_component(player.Character, "Tag")

        if nameTag == nil then return end

        if player.TeamColor ~= Client.TeamColor then
            nameTag:Disable()
            setTagToEnemy(nameTag)
            continue
        end

        nameTag:Enable()
        setTagToAlly(nameTag)
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
    Client.Changed:Connect(clientTeamChange)
end

return NametagSystem