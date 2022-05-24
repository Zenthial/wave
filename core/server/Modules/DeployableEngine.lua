local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))
local ChatStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("ChatStats"))

local Deployables = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Deployables")
local DeployableGui = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("UI"):WaitForChild("DeployableGui")

local DeployableEngine = {}

function DeployableEngine:Start()
    local DeployablesBin = Instance.new("Folder")
    DeployablesBin.Name = "DeployablesBin"
    DeployablesBin.Parent = workspace

    local RequestDeployable = Instance.new("RemoteEvent")
    RequestDeployable.Name = "RequestDeployable"
    RequestDeployable.Parent = ReplicatedStorage

    RequestDeployable.OnServerEvent:Connect(function(player: Player, deployableName: string, position: CFrame)
        local quantity = player:GetAttribute("GadgetQuantity")
        local deployableStats = WeaponStats[deployableName]

        if deployableStats and quantity > 0 then
            local model = Deployables[deployableName].DeployableModel:Clone() :: Model
            model.Name = player.Name .. deployableName
            model:SetAttribute("Player", player.Name)

            if deployableStats.TeamKillPrevention then
                model:SetAttribute("Team", player.TeamColor)
            end

            CollectionService:AddTag(model, deployableName)

            local gui = DeployableGui:Clone() :: BillboardGui
            gui.Adornee = model.PrimaryPart
            gui.Indicator1.BackgroundColor3 = ChatStats.TeamColors[player.TeamColor.Name].Text
            gui.Indicator2.BackgroundColor3 = ChatStats.TeamColors[player.TeamColor.Name].Stroke
            gui.Parent = model
            
            model:SetPrimaryPartCFrame(position)
            model.Parent = DeployablesBin

            player:SetAttribute("GadgetQuantity", quantity - 1)
        end

    end)
end

return DeployableEngine