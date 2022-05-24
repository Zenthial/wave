local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Deployables = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Deployables")
local RequestDeployable = ReplicatedStorage:WaitForChild("RequestDeployable") :: RemoteEvent

local DeployablesBin = workspace:WaitForChild("DeployablesBin")
local Player = Players.LocalPlayer

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = {}
raycastParams.IgnoreWater = true

type DeployableStats = {
    Name: string,
    DeployTime: number,
}

local DeployableEngine = {}

function DeployableEngine:Start()
    self.Placing = false
    self.Preview = false

    if Player.Character == nil then
        Player.CharacterAdded:Wait()
    end
end

function DeployableEngine:RenderDeployable(deployableStats: DeployableStats, equippedWeapon)
    if Player.Character and Player.Character.HumanoidRootPart then
        local cframe: CFrame = Player.Character.HumanoidRootPart.CFrame
        local position = cframe + (cframe.LookVector * 3)
        local raycastResult = workspace:Raycast(position.Position, Vector3.new(0, -100, 0), raycastParams)
                
        if raycastResult then
           if equippedWeapon then
               equippedWeapon:Unequip()
           end

           local hrpPos = Player.Character.HumanoidRootPart.Position
           local modelCFrame = CFrame.new(raycastResult.Position, Vector3.new(hrpPos.X, raycastResult.Position.Y, hrpPos.Z))

           Player:SetAttribute("LocalSprinting", false)
           Player:SetAttribute("LocalCrouching", false)
           Player:SetAttribute("PlacingDeployable", true)
           self.Placing = true

           local preview = Deployables[deployableStats.Name].DeployableModel:Clone() :: Model
           CollectionService:AddTag(preview, "Ignore")
           
           for _, object in pairs(preview:GetChildren()) do
               if object:IsA("Seat") then
                   object:Destroy()
               elseif (object:IsA("Part") or object:IsA("UnionOperation")) and object.Transparency < 1 then
                    object.Material = Enum.Material.Neon
                    object.BrickColor = BrickColor.new("Bright blue")
                    object.Transparency = 0.9
                    object.CanCollide = false
               end
           end

           preview.Parent = DeployablesBin
           preview:SetPrimaryPartCFrame(modelCFrame)
           self.Preview = preview

           local timer = 0
           while self.Placing and timer < deployableStats.DeployTime do
                timer = timer + 0.05
                for _, v in pairs (preview:GetChildren()) do
                    if (v:IsA("Part") or v:IsA("UnionOperation")) and v.Transparency < 1 then
                        v.Transparency = v.Transparency - 0.02
                    end
                end
                task.wait(0.05)
           end

           if self.Placing then
               RequestDeployable:FireServer(deployableStats.Name, modelCFrame)
           end

           Player:SetAttribute("PlacingDeployable", false)
           preview:Destroy()
        end
    end
end

function DeployableEngine:CancelDeployable()
    self.Placing = false
    Player:SetAttribute("PlacingDeployable", false)
end

return DeployableEngine