local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Configurations = Shared:WaitForChild("Configurations")
local ObjectiveConfigurations = require(Configurations:WaitForChild("ObjectiveConfigurations"))
local Trove = require(Shared:WaitForChild("util"):WaitForChild("Trove"))

local NUM_OPTIONS = 3
local VOTE_TIMER = 15

function shuffle(t: {any}): {any}
    math.randomseed(os.time())
    local tbl = {}
    for i = 1, #t do
        tbl[i] = t[i]
    end
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

local function chooseRandom(options: {string}): {string}
    options = shuffle(options)
    local randomChoices = {}
    
    for i = 1, NUM_OPTIONS do
        randomChoices[i] = options[i]
    end

    return randomChoices
end

type ObjectiveRunner = {
    PollSignal: RemoteEvent,
    ObjectiveSignal: RemoteEvent,
    VoteSignal: RemoteEvent,
}

local ObjectiveRunner: ObjectiveRunner = {}

function ObjectiveRunner:Start()
    local objectiveSignal = Instance.new("RemoteEvent")
    objectiveSignal.Name = "ObjectiveSignal"
    objectiveSignal.Parent = ReplicatedStorage
    self.ObjectiveSignal = objectiveSignal

    local pollSignal = Instance.new("RemoteEvent")
    pollSignal.Name = "PollSignal"
    pollSignal.Parent = ReplicatedStorage
    self.PollSignal = pollSignal

    local voteSignal = Instance.new("RemoteEvent")
    voteSignal.Name = "VoteSignal"
    voteSignal.Parent = ReplicatedStorage
    self.VoteSignal = voteSignal

    task.wait(10)
    self:PollUsers()
end

function ObjectiveRunner:PollUsers()
    if #Players:GetPlayers() < 2 then
        repeat
            task.wait(2)
        until not (#Players:GetPlayers() < 2)
    end

    print("polling")

    local mapOptions = chooseRandom(ObjectiveConfigurations.Maps)
    local modeOptions = chooseRandom(ObjectiveConfigurations.Modes)

    local mapMap = {}
    local playerMapMap = {}
    for _, map in mapOptions do
        mapMap[map] = 0
    end

    for _, player in Players:GetPlayers() do
        playerMapMap[player] = {Voted = false, Choice = nil}
    end
    
    local pollCleaner = Trove.new()
    pollCleaner:Add(self.PollSignal.OnServerEvent:Connect(function(player, choice: string)
        if playerMapMap[player] == nil then
            playerMapMap[player] = {Voted = false, Choice = nil}
        end
        
        if playerMapMap[player].Choice ~= choice then
            if mapMap[choice] ~= nil then
                mapMap[choice] += 1
            end
            
            if playerMapMap[player].Voted then
                mapMap[playerMapMap[player].Choice] -= 1
            end
            
            playerMapMap[player].Voted = true
            playerMapMap[player].Choice = choice
            
            self.VoteSignal:FireAllClients(mapMap)
        end
    end))
    self.VoteSignal:FireAllClients(mapMap)
    
    task.wait(VOTE_TIMER)
    self.VoteSignal:FireAllClients(nil)
    pollCleaner:Clean()
    
    local mapChoice = nil
    for map, count in mapMap do
        if mapChoice == nil then
            mapChoice = map
        elseif mapMap[mapChoice] < count then
            mapChoice = map
        end
    end

    local modeMap = {}
    local playerModeMap = {}
    for _, map in modeOptions do
        modeMap[map] = 0
    end

    for _, player in Players:GetPlayers() do
        playerModeMap[player] = {Voted = false, Choice = nil}
    end
    
    pollCleaner:Add(self.PollSignal.OnServerEvent:Connect(function(player, choice: string)
        if playerModeMap[player] == nil then
            playerModeMap[player] = {Voted = false, Choice = nil}
        end
        
        if playerModeMap[player].Choice ~= choice then
            if modeMap[choice] ~= nil then
                modeMap[choice] += 1
            end
            
            if playerModeMap[player].Voted then
                modeMap[playerModeMap[player].Choice] -= 1
            end
            
            playerModeMap[player].Voted = true
            playerModeMap[player].Choice = choice
            
            self.VoteSignal:FireAllClients(modeMap)
        end
    end))
    self.VoteSignal:FireAllClients(modeMap)
    
    task.wait(VOTE_TIMER)
    self.VoteSignal:FireAllClients(nil)
    pollCleaner:Clean()
    
    local modeChoice = nil
    for mode, count in mapMap do
        if modeChoice == nil then
            modeChoice = mode
        elseif modeMap[modeChoice] < count then
            modeChoice = mode
        end
    end

    self:SetupObjectives(mapChoice, modeChoice)
end

function ObjectiveRunner:SetupObjectives(map: string, mode: string)
    
end

return ObjectiveRunner