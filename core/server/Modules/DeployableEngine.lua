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

    local RequestDeployable = Instance.new("RemoteFunction")
    RequestDeployable.Name = "RequestDeployable"
    RequestDeployable.Parent = ReplicatedStorage

    RequestDeployable.OnServerInvoke = function(player: Player, deployableName: string, position: CFrame)
        print(player:GetAttributes())
        local quantity = player:GetAttribute("GadgetQuantity")
        local deployableStats = WeaponStats[deployableName]

        local deployableQuantity = player:GetAttribute("NumDeployable"..deployableName) -- the amount of deployables that are already deployed
        local maxQuantity = player:GetAttribute("MaxDeployable"..deployableName)
        if deployableQuantity == nil then
            player:SetAttribute("NumDeployable"..deployableName, 0)
            player:SetAttribute("MaxDeployable"..deployableName, deployableStats.MaxDeployables) -- the maximum amount of deployables allowed to be deployed for that specific deployable
            deployableQuantity = 0
            maxQuantity = deployableStats.MaxDeployables
        end

        assert(maxQuantity ~= nil, "maxQuantity must be a number, did you forget to set MaxDeployables on a Deployable?")

        if deployableStats and quantity > 0 and deployableQuantity < maxQuantity then
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
            player:SetAttribute("NumDeployable"..deployableName, deployableQuantity + 1)

            return model
        end

        return nil
    end
end

return DeployableEngine
