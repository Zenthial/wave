local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ProfileService = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ProfileService"))
local PlayerProfileTemplate = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("PlayerProfile"))

local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local PlayerDataStore = ProfileService.GetProfileStore("PlayerData", PlayerProfileTemplate)
local PlayerProfiles = {}
local PlayerCleaners = {}

local function HandlePlayerData(player: Player, profile)
    local playerCleaner = Trove.new()

    local optionsFolder = Instance.new("Folder")
    optionsFolder.Name = "OptionsFolder"
    optionsFolder.Parent = player
    for optionName, optionValue in pairs(profile.Data.Options) do
        player:SetAttribute(optionName.."Option", optionValue)
        playerCleaner:Add(player:GetAttributeChangedSignal(optionName.."Option"):Connect(function()
            local newOption = player:GetAttribute(optionName.."Option")
            profile.Data.Options[optionName] = newOption
        end))

        local option = Instance.new("NumberValue")
        option.Name = optionName
        option.Value = optionValue
        option.Parent = optionsFolder
    end

    for keybindName, keybindValue: Enum.KeyCode in pairs(profile.Data.Keybinds) do
        player:SetAttribute(keybindName.."Keybind", keybindValue.Name)
    end

    local statsFolder = Instance.new("Folder")
    statsFolder.Name = "StatsFolder"
    statsFolder.Parent = player
    for statName, statValue in pairs(profile.Data.Stats) do
        player:SetAttribute(statName.."Stat", statValue)
        playerCleaner:Add(player:GetAttributeChangedSignal(statName.."Stat"):Connect(function()
            local newStat = player:GetAttribute(statName.."Stat")
            profile.Data.Stats[statName] = newStat
        end))

        local stat = Instance.new("NumberValue")
        stat.Name = statName
        stat.Value = statValue
        stat.Parent = statsFolder
    end

    PlayerCleaners[player] = playerCleaner
end

local function DecodeKeycodeEnums(enumTable: {[string]: string})
    local newTable = {}
    for key, enumName in pairs(enumTable) do
        newTable[key] = Enum.KeyCode[enumName]
    end

    return newTable
end

local function EncodeKeycodeEnums(enumTable: {[string]: Enum.KeyCode})
    local newTable = {}
    for key, enum in pairs(enumTable) do
        newTable[key] = enum.Name
    end

    return newTable
end

local function PlayerAdded(player)
    local profile = PlayerDataStore:LoadProfileAsync("Player_" .. player.UserId)
    if profile ~= nil then
        profile:AddUserId(player.UserId) -- GDPR compliance
        if profile.Data.Keybinds then
            profile.Data.Keybinds = DecodeKeycodeEnums(profile.Data.Keybinds)
        end
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
            profile.Data.Keybinds = EncodeKeycodeEnums(profile.Data.Keybinds)
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