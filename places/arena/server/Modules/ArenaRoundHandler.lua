local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local Teams = game:GetService("Teams")

local ArenaDataHandler = require(script.Parent.ArenaDataHandler)
local DeathEngine = require(ServerScriptService.Server.Modules.DeathEngine)
local Courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local MAX_PLAYERS = 1
local MAX_ROUND_WINS = 5
local INTERMISSION_TIMER = 60
local ROUND_TIMER = 180

local function createRoundAttributes()
    local roundAttributesFolder = Instance.new("Folder")
    roundAttributesFolder.Name = "RoundAttributesFolder"
    
    roundAttributesFolder:SetAttribute("Intermission", true)
    roundAttributesFolder:SetAttribute("IntermissionClock", INTERMISSION_TIMER)
    roundAttributesFolder:SetAttribute("InRound", false)
    roundAttributesFolder:SetAttribute("RoundClock", -1)
    roundAttributesFolder:SetAttribute("RedScore", 0)
    roundAttributesFolder:SetAttribute("BlueScore", 0)
    roundAttributesFolder:SetAttribute("MaxRoundWins", MAX_ROUND_WINS)
    roundAttributesFolder:SetAttribute("Victor", "No one")

    roundAttributesFolder.Parent = ReplicatedStorage

    return roundAttributesFolder
end

local function countdown(number: number, folder: Folder, attributeName: string, boolCheck: string)
    repeat
        task.wait(1)
        number -= 1
        print(number)
        folder:SetAttribute(attributeName, number)
    until number <= 0 or folder:GetAttribute(boolCheck) == false
end

local State = {
    Score = {
        Red = 0,
        Blue = 0
    },

    AlivePlayers = {
        Red = MAX_PLAYERS/2,
        Blue = MAX_PLAYERS/2
    }
}

local RoundHandler: typeof(State) = State

function RoundHandler:Start()
    local roundAttributes = createRoundAttributes()
    
    repeat
        task.wait(1)
    until #Players:GetPlayers() == MAX_PLAYERS

    self.RoundAttributes = roundAttributes
    self:RoundSetup()
end

function RoundHandler:LoadTeams()
    local teams = ArenaDataHandler:GetTeams()
    if teams ~= nil then 
        for teamName, teamUsers in pairs(teams) do
            for _, userId in teamUsers do
                local player = Players:GetPlayerByUserId(userId)
                player.Team = Teams[teamName]
                DeathEngine:SpawnPlayer(player)
            end
        end
    else
        for i, player in Players:GetPlayers() do
            if i % 2 == 0 then
                player.Team = Teams["Red"]
                DeathEngine:SpawnPlayer(player)
            else
                player.Team = Teams["Blue"]
                DeathEngine:SpawnPlayer(player)
            end
        end
    end
end

function RoundHandler:PlayersIntermission()
    for _, player in Players:GetPlayers() do
        player.Team = Teams["Intermission"]
        DeathEngine:SpawnPlayer(player)
    end
end

function RoundHandler:RoundSetup()
    self:PlayersIntermission()
    self.RoundAttributes:SetAttribute("Intermission", true)
    self.RoundAttributes:SetAttribute("InRound", false)
    self.RoundAttributes:SetAttribute("IntermissionClock", 5)
    print("here")
    countdown(5, self.RoundAttributes, "IntermissionClock", "Intermission")

    self.RoundAttributes:SetAttribute("Intermission", false)
    self.RoundAttributes:SetAttribute("InRound", true)
    self.RoundAttributes:SetAttribute("RoundClock", ROUND_TIMER)

    local roundCleaner = Trove.new()
    for _, player in Players:GetPlayers() do
        roundCleaner:Add(player:GetAttributeChangedSignal("Dead"):Connect(function()
            self.AlivePlayers[player.Team.Name] -= 1
            if self.AlivePlayers[player.Team.Name] == 0 then
                self.RoundAttributes:SetAttribute("InRound", false)
            end
        end))
    end

    self:LoadTeams()
    countdown(ROUND_TIMER, self.RoundAttributes, "RoundClock", "InRound")

    roundCleaner:Clean()
    if self.AlivePlayers.Red == 0 then
        self.Score.Blue += 1
        if self.Score.Blue == MAX_ROUND_WINS then
            self.RoundAttributes:SetAttribute("Victor", "Blue")
        end

        return
    else
        self.Score.Red += 1
        if self.Score.Red == MAX_ROUND_WINS then
            self.RoundAttributes:SetAttribute("Victor", "Red")
        end

        return
    end

    self:RoundSetup()
end

return RoundHandler