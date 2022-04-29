local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ProfileService = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ProfileService"))
local PlayerProfileTemplate = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("PlayerProfile"))

local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local PlayerDataStore = ProfileService.GetProfileStore("PlayerData_B", PlayerProfileTemplate)
local PlayerProfiles = {}
local PlayerCleaners = {}

local function HandlePlayerData(player: Player, profile)
    local playerCleaner = Trove.new()

    local optionsFolder = Instance.new("Folder")
    optionsFolder.Name = "Options"
    optionsFolder.Parent = player
    for optionName, optionValue in pairs(profile.Data.Options) do
        optionsFolder:SetAttribute(optionName, optionValue)
        playerCleaner:Add(optionsFolder:GetAttributeChangedSignal(optionName):Connect(function()
            local newOption = optionsFolder:GetAttribute(optionName)
            profile.Data.Options[optionName] = newOption
        end))
    end

    local keybindFolder = Instance.new("Folder")
    keybindFolder.Name = "Keybinds"
    keybindFolder.Parent = player

    for keybindName, keybindValue in pairs(profile.Data.Keybinds) do
        keybindFolder:SetAttribute(keybindName, keybindValue)
    end

    local statsFolder = Instance.new("Folder")
    statsFolder.Name = "Stats"
    statsFolder.Parent = player
    for statName, statValue in pairs(profile.Data.Stats) do
        statsFolder:SetAttribute(statName, statValue)
        playerCleaner:Add(statsFolder:GetAttributeChangedSignal(statName):Connect(function()
            local newStat = statsFolder:GetAttribute(statName)
            profile.Data.Stats[statName] = newStat
        end))
    end

    PlayerCleaners[player] = playerCleaner

    player:SetAttribute("DataLoaded", true)
end

local function PlayerAdded(player)
    player:SetAttribute("DataLoaded", false)
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

local function OptionSync(player: Player, optionName: string, optionValue: boolean)
    assert(player:GetAttribute(optionName) ~= "", "Option does not exist on player "..player.Name)

    if optionValue ~= player:GetAttribute(optionName) then
        player:SetAttribute(optionName, optionValue)
    end
end

local DataLoader = {}

function DataLoader:Start()
    local OptionSyncRemote = Instance.new("RemoteEvent")
    OptionSyncRemote.Name = "OptionSyncRemote"
    OptionSyncRemote.OnServerEvent:Connect(OptionSync)
    OptionSyncRemote.Parent = ReplicatedStorage.Shared

    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(PlayerAdded, player)
    end
    
    Players.PlayerAdded:Connect(PlayerAdded)

    Players.PlayerRemoving:Connect(function(player)
        local profile = PlayerProfiles[player]
        if profile ~= nil then
            profile:Release()
            -- make sure everything is gc'd
            PlayerProfiles[player] = nil
        end

        local cleaner = PlayerCleaners[player]
        if cleaner ~= nil then
            cleaner:Clean()
            -- make sure everything is gc'd
            PlayerCleaners[player] = nil
        end
    end)
end

function DataLoader:GetPlayerProfile(player: Player)
    return PlayerProfiles[player]
end

return DataLoader