local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ProfileService = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ProfileService"))
local PlayerProfileTemplate = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("PlayerProfile"))

local PlayerDataStore = ProfileService.GetProfileStore("PlayerData", PlayerProfileTemplate)
local PlayerProfiles = {}

local function HandlePlayerData(player: Player, profile)
    local optionsFolder = Instance.new("Folder")
    optionsFolder.Name = "OptionsFolder"
    optionsFolder.Parent = player
    for optionName, optionValue in pairs(profile.Data.Options) do
        player:SetAttribute(optionName.."Option", optionValue)

        local option = Instance.new("NumberValue")
        option.Name = optionName
        option.Value = optionValue
        option.Parent = optionsFolder
    end

    local statsFolder = Instance.new("Folder")
    statsFolder.Name = "StatsFolder"
    statsFolder.Parent = player
    for statName, statValue in pairs(profile.Data.Stats) do
        player:SetAttribute(statName.."Stat", statValue)

        local stat = Instance.new("NumberValue")
        stat.Name = statName
        stat.Value = statValue
        stat.Parent = statsFolder
    end
end

function PlayerAdded(player)
    local profile = PlayerDataStore:LoadProfileAsync("Player_" .. player.UserId)
    if profile ~= nil then
        profile:AddUserId(player.UserId) -- GDPR compliance
        profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
        profile:ListenToRelease(function()
            PlayerProfiles[player] = nil
            -- The profile could've been loaded on another Roblox server:
            player:Kick()
        end)

        if player:IsDescendantOf(Players) == true then
            PlayerProfiles[player] = profile
            -- A profile has been successfully loaded:
            HandlePlayerData(player, profile)
        else
            -- Player left before the profile loaded:
            profile:Release()
        end
    else
        -- The profile couldn't be loaded possibly due to other
        --   Roblox servers trying to load this profile at the same time:
        player:Kick() 
    end
end

local DataLoader = {}

function DataLoader:Start()
    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(PlayerAdded, player)
    end
    
    Players.PlayerAdded:Connect(PlayerAdded)

    Players.PlayerRemoving:Connect(function(player)
        local profile = PlayerProfiles[player]
        if profile ~= nil then
            profile:Release()
        end
    end)
end

function DataLoader:GetPlayerProfile(player: Player)
    return PlayerProfiles[player]
end

return DataLoader