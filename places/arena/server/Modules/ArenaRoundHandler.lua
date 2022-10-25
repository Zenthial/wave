local CollectionService = game:GetService("CollectionService")
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
    roundAttributesFolder:SetAttribute("RedAlive", 3)
    roundAttributesFolder:SetAttribute("BlueScore", 0)
    roundAttributesFolder:SetAttribute("BlueAlive", 3)
    roundAttributesFolder:SetAttribute("MaxRoundWins", MAX_ROUND_WINS)
    roundAttributesFolder:SetAttribute("Victor", "No one")

    roundAttributesFolder.Parent = ReplicatedStorage

    return roundAttributesFolder
end

local function countdown(number: number, folder: Folder, attributeName: string, boolCheck: string)
    repeat
        task.wait(1)
        number -= 1
        -- print(number)
        folder:SetAttribute(attributeName, number)
    until number <= 0 or folder:GetAttribute(boolCheck) == false
end

local State = {
    Score = {
        Red = 0,
        Blue = 0
    },

    Round = 1,

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

    DeathEngine:CanRespawn(false)

    self.RoundAttributes = roundAttributes
    self:LoadTeams()
    self:RoundSetup()
end

function RoundHandler:LoadTeams()
    local teams = ArenaDataHandler:GetTeams()
    if teams ~= nil then 
        for teamName, teamUsers in pairs(teams) do
            for _, userId in teamUsers do
                local player = Players:GetPlayerByUserId(userId)
                player.Team = Teams[teamName]
            end
        end
    else
        for i, player in Players:GetPlayers() do
            -- if i % 2 == 0 then
            --     player.Team = Teams["Red"]
            -- else
            --     player.Team = Teams["Blue"]
            -- end

            player.Team = Teams["Blue"]
        end
    end
end

function RoundHandler:LoadPlayers()
    for _, player in Players:GetPlayers() do
        DeathEngine:SpawnPlayer(player)
    end
end

function RoundHandler:SwitchSpawns()
    for _, spawn in workspace.Spawns:GetChildren() do
        if spawn.Name == "Bright red" then
            spawn.Name = "Bright blue"
        elseif spawn.Name == "Bright blue" then
            spawn.Name = "Bright red"
        end
    end
end

function RoundHandler:MakeCanister()
    local canisters = workspace.Canisters:GetChildren()
    local canister = canisters[Random.new():NextInteger(1, #canisters)]

    CollectionService:AddTag(canister, "CreditCanister")
    return canister
end

function RoundHandler:ToggleForceFields(bool: boolean)
    for _, forceField in workspace.Interactive.ForceFields:GetChildren() do
        forceField.ForceField.CanCollide = bool
    end
end

function RoundHandler:RoundSetup()
    if self.Round % 2 == 0 then
        self:SwitchSpawns()
    end

    local activeCanister = self:MakeCanister()
    self:ToggleForceFields(true)
    self:LoadPlayers()
    self.RoundAttributes:SetAttribute("Intermission", true)
    self.RoundAttributes:SetAttribute("InRound", false)
    self.RoundAttributes:SetAttribute("IntermissionClock", 5)
    
    countdown(5, self.RoundAttributes, "IntermissionClock", "Intermission")
    
    self:ToggleForceFields(false)
    self.RoundAttributes:SetAttribute("Intermission", false)
    self.RoundAttributes:SetAttribute("InRound", true)
    self.RoundAttributes:SetAttribute("RoundClock", ROUND_TIMER)
    
    local roundCleaner = Trove.new()
    for _, player in Players:GetPlayers() do
        roundCleaner:Add(player:GetAttributeChangedSignal("Dead"):Connect(function()
            self.AlivePlayers[player.Team.Name] -= 1
            self.RoundAttributes:SetAttribute(player.Team.Name.."Alive", self.AlivePlayers[player.Team.Name])
            if self.AlivePlayers[player.Team.Name] == 0 then
                self.RoundAttributes:SetAttribute("InRound", false)
            end
        end))
    end
    
    self.RoundAttributes:SetAttribute("RedAlive", #Teams["Red"]:GetPlayers())
    self.RoundAttributes:SetAttribute("BlueAlive", #Teams["Blue"]:GetPlayers())
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

    CollectionService:RemoveTag(activeCanister, "CreditCanister")
    self.Round += 1
    self:RoundSetup()
end

return RoundHandler