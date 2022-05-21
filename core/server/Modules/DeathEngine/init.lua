local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local createDeathBox = require(script.createDeathBox)

local RESPAWN_TIMER = 5

type HealthComponent_T = {
    Events: {
        Died: {
            Connect: (any, () -> ()) -> ()
        }
    },

    SetTotalHealth: (HealthComponent_T, number) -> ()
}

local spawnBox = createDeathBox()
local floor: Part = spawnBox.floor
local random = Random.new()

local function getRandomPos(part: Part)
    local minX = floor.Position.X - floor.Size.X/2
    local maxX = floor.Position.X + floor.Size.X/2
    local minZ = floor.Position.Z - floor.Size.Z/2
    local maxZ = floor.Position.Z + floor.Size.Z/2
    local randPos = Vector3.new(random:NextInteger(minX, maxX), floor.Position.Y + 3, random:NextInteger(minZ, maxZ))
    return randPos
end

local PlayerCleaners: {[Player]: typeof(Trove)} = {}

local function playerAdded(player: Player)
    local health_component = tcs.get_component(player, "Health") --[[:await()]] :: HealthComponent_T
    if health_component ~= nil then
        local cleaner = Trove.new()
        cleaner:Add(player:GetAttributeChangedSignal("Dead"):Connect(function()
            if player:GetAttribute("Dead") == false then return end
            local character = player.Character
            local randPos = getRandomPos(floor)
            character.HumanoidRootPart.Position = randPos

            task.delay(RESPAWN_TIMER, function()
                if workspace:FindFirstChild("Spawns") and workspace.Spawns:FindFirstChild(player.TeamColor.Name) then
                    local teamSpawn = workspace.Spawns[player.TeamColor.Name]
                    randPos = getRandomPos(teamSpawn)
                    character.HumanoidRootPart.Position = randPos
                else
                    character.HumanoidRootPart.Position = Vector3.new(0, 3, 0)
                end

                health_component:SetTotalHealth(100) -- probably bad to hardcode this value
                player:SetAttribute("LastKiller", "")
            end)
        end))

        PlayerCleaners[player] = cleaner
    end
end

local function playerRemoving(player: Player)
    if PlayerCleaners[player] ~= nil then
        PlayerCleaners[player]:Clean()
    end
end

local DeathEngine = {}

function DeathEngine:Start()
    for _, player in pairs(Players:GetPlayers()) do
        playerAdded(player)
    end

    Players.PlayerAdded:Connect(playerAdded)

    Players.PlayerRemoving:Connect(playerRemoving)
end

return DeathEngine