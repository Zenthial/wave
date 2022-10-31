local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local ChatStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("ChatStats"))
local GlobalOptions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("GlobalOptions"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))
local courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))

local Objects = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("Objects")
local Effect = Objects:WaitForChild("HumanoidDeathEffect")

local createDeathBox = require(script.createDeathBox)

local RenderDeathEffect = Instance.new("RemoteEvent")
RenderDeathEffect.Name = "RenderDeathEffect"
RenderDeathEffect.Parent = ReplicatedStorage

local KillNotifier = Instance.new("RemoteEvent") -- notifies kills, assist count as kills and assists takes (type, person)
KillNotifier.Name = "KillNotifier"
KillNotifier.Parent = ReplicatedStorage

local RESPAWN_TIMER = GlobalOptions.RespawnTime
local DEATH_BANNER = true
local CanRespawn = true

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
    local minX = part.Position.X - part.Size.X/2
    local maxX = part.Position.X + part.Size.X/2
    local minZ = part.Position.Z - part.Size.Z/2
    local maxZ = part.Position.Z + part.Size.Z/2
    local randPos = Vector3.new(random:NextInteger(minX, maxX), part.Position.Y + 3, random:NextInteger(minZ, maxZ))
    return randPos
end

local function spawnPlayer(player, character)
    local shieldComponent = tcs.get_component(character, "ShieldModel")
    shieldComponent:Spawn()

    local health_component = tcs.get_component(player, "Health") :: HealthComponent_T
    health_component:Heal(100) -- probably bad to hardcode this value
    player:SetAttribute("LastKiller", "")
    
    if workspace:FindFirstChild("Spawns") ~= nil and workspace.Spawns:FindFirstChild(player.TeamColor.Name) ~= nil then
        local teamSpawn = workspace.Spawns[player.TeamColor.Name]
        local randPos = getRandomPos(teamSpawn)
        -- character.HumanoidRootPart.Position = randPos
        character:SetPrimaryPartCFrame(CFrame.new(randPos))
    else
        -- character.HumanoidRootPart.Position = getRandomPos(floor)
        character:SetPrimaryPartCFrame(CFrame.new(getRandomPos(floor)))
    end
end

local PlayerCleaners: {[Player]: typeof(Trove)} = {}

local function playerAdded(player: Player)
    local damageFolder = Instance.new("Folder")
    damageFolder.Name = "DamageFolder"
    damageFolder.Parent = player

    local health_component = tcs.get_component(player, "Health") :: HealthComponent_T
    if health_component ~= nil then
        local character = player.Character or player.CharacterAdded:Wait()
        spawnPlayer(player, character)

        local cleaner = Trove.new()
        cleaner:Add(player:GetAttributeChangedSignal("Dead"):Connect(function()
            if player:GetAttribute("Dead") == false then return end
            local randPos = getRandomPos(floor)
            local deathPosition = character.HumanoidRootPart.Position
            character:PivotTo(CFrame.new(randPos))

            local effect = Effect:Clone()
            effect.CFrame = CFrame.new(deathPosition)
            effect.Name = player.Name .. "DeathEffect"
            effect.Parent = workspace
            effect["Death" .. math.random(1, 5)]:Play()
            CollectionService:AddTag(effect, "Ignore")

            local killer = player:GetAttribute("LastKiller")
            courier:Send("CameraFollow", player, deathPosition)

            task.spawn(function()
                if killer ~= "" then
                    local killerPlayer = Players:FindFirstChild(killer) :: Player
                    if killerPlayer then
                        killerPlayer:SetAttribute("Kills", killerPlayer:GetAttribute("Kills") + 1)
                        KillNotifier:FireClient(killerPlayer, "Kill", player)
                    end
    
                    for _, folder in pairs(damageFolder) do
                        local damagePlayer = Players:FindFirstChild(folder.Name):: Player
                        if damagePlayer == nil then continue end
    
                        local damage = damageFolder:GetAttribute("Damage")
                        local timeout = damageFolder:GetAttribute("Time")
                        local hits = damageFolder:GetAttribute("Hits")
    
                        if tick() - timeout <= GlobalOptions.AssistTimeout and hits >= GlobalOptions.AssistHitsThreshold then
                            if damage >= GlobalOptions.AssistAsKillThreshold then
                                damagePlayer:SetAttribute("AssistsAsKills", damagePlayer:GetAttribute("AssistsAsKills") + 1)
                                KillNotifier:FireClient(damagePlayer, "AssistAsKill", player)
                            elseif damage >= GlobalOptions.AssistThreshold then
                                damagePlayer:SetAttribute("Assists", damagePlayer:GetAttribute("Assists") + 1)
                                KillNotifier:FireClient(damagePlayer, "Assist", player)
                            end
                        end
                    end

                    damageFolder:ClearAllChildren()
                end
            end)

            task.delay(0.2, function()
                if DEATH_BANNER then
                    effect.Orb.Enabled = false

                    if killer ~= "" then
                        local color = ChatStats.TeamColors[tostring(player.TeamColor)].Text or ChatStats.TeamColors["Default"].Text
                        RenderDeathEffect:FireAllClients(effect, player.Name, killer, color)
                        task.wait(GlobalOptions.DeathNotifierTime + 1)
                    end
                end

                effect:Destroy()
            end)

            if CanRespawn then
                task.delay(RESPAWN_TIMER, function()
                    spawnPlayer(player, character)
                end)
            end
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

function DeathEngine:SpawnPlayer(player: Player)
    local character = player.Character or player.CharacterAdded:Wait()
    spawnPlayer(player, character)
end

function DeathEngine:CanRespawn(bool)
    CanRespawn = bool
end

return DeathEngine