local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local RedTeam = Teams.Red :: Team
local BlueTeam = Teams.Blue :: Team
local NeutralTeam = Teams.Neutral :: Team

local random = Random.new()

local function createSignal(name: string): RemoteFunction
    local remote = Instance.new("RemoteFunction")
    remote.Name = name
    remote.Parent = Shared

    return remote
end

local function getTeam(player: Player)
    if #RedTeam:GetPlayers() > #BlueTeam:GetPlayers() then
        return BlueTeam
    else
        return RedTeam
    end
end

local function collectSpawns(spawnsFolder: Folder, team: Team)
    local spawnTable = {}
    
    for _, spawn in ipairs(spawnsFolder:GetChildren()) do
        if spawn.Name == team.TeamColor.Name then
            table.insert(spawnTable, spawn)
        end
    end

    return spawnTable
end

local GameStateHandler = {}

function GameStateHandler:Start()
    local gameStateSignal = createSignal("GameStateSignal")
    
    gameStateSignal.OnServerInvoke = function(player, stateType: string)
        if stateType == "Join" then
            local currentMap = workspace:FindFirstChild("CurrentMap")
            if currentMap then
                local team = getTeam(player)
                player.Team = team
                
                local character = player.Character or player.CharacterAdded:Wait()
                local hrp = character:FindFirstChild("HumanoidRootPart")
                
                if hrp then
                    local spawns = collectSpawns(currentMap.Spawns, team)
                    local randomSpawnPoint = spawns[random:NextInteger(1, #spawns)]

                    hrp.CFrame = randomSpawnPoint.CFrame + Vector3.new(0, 3, 0)
                    player:SetAttribute("InRound", true)
                    return true
                else
                    return false
                end
            end
        elseif stateType == "Leave" then
            player.Team = NeutralTeam
            
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:FindFirstChild("HumanoidRootPart")
            
            if hrp then
                local spawn = workspace:FindFirstChild("SpawnLocation")

                hrp.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
                player:SetAttribute("InRound", false)
                return true
            else
                return false
            end
        end
    end
end

return GameStateHandler