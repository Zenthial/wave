local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))
local ChatStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("ChatStats"))

local Deployables = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("Deployables")
local DeployableGui = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("UI"):WaitForChild("DeployableGui")

local DeployableEngine = {}

function DeployableEngine:Start()
    local RequestDeployable = Instance.new("RemoteEvent")
    RequestDeployable.Name = "RequestDeployable"
    RequestDeployable.Parent = ReplicatedStorage

    RequestDeployable.OnServerEvent:Connect(function(player: Player, deployableName: string, position: CFrame)
        local deployableStats = WeaponStats[deployableName]

        if deployableStats then
            local model = Deployables[deployableName].DeployableModel:Clone() :: Model
            model.Name = player.Name .. deployableName
            model:SetAttribute("Player", player)
            model:MoveTo(position.Position)

            if deployableStats.TeamKillPrevention then
                model:SetAttribute("Team", player.TeamColor)
            end

            CollectionService:AddTag(model, deployableName)

            local gui = DeployableGui:Clone() :: BillboardGui
            gui.Adornee = model.PrimaryPart
            gui.Indicator1.BackgroundColor3 = ChatStats.TeamColors[player.TeamColor.Name].Text
            gui.Indicator2.BackgroundColor3 = ChatStats.TeamColors[player.TeamColor.Name].Stroke
            gui.Parent = model
            
            model.Parent = workspace
        end

    end)
end

return DeployableEngine