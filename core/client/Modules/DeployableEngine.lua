local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

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
    self.ActiveTweens = {}
    self.ActiveThread = nil
    self.CurrentDeployable = nil

    if Player.Character == nil then
        Player.CharacterAdded:Wait()
    end
end

function DeployableEngine:FeedInput(deployableStats: DeployableStats, equippedWeapon)
    if self.CurrentDeployable == nil then
        self:RenderDeployable(deployableStats, equippedWeapon)
    elseif self.CurrentDeployable ~= nil and self.CurrentDeployable.Name == "C4" then
        -- exists only for c4
        local deployableComponent = tcs.get_component(self.CurrentDeployable, self.CurrentDeployable.Name)
        deployableComponent:Trigger()
    end
end

function DeployableEngine:RenderDeployable(deployableStats: DeployableStats, equippedWeapon)
    if Player.Character and Player.Character.HumanoidRootPart
        and (Player:GetAttribute("NumDeployable"..deployableStats.Name) or 0) < (Player:GetAttribute("MaxDeployable"..deployableStats.Name) or 1)
    then
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
 
            preview:SetPrimaryPartCFrame(modelCFrame)
            preview.Parent = DeployablesBin
            self.Preview = preview
 
            task.spawn(function()
                 local tweenTable = table.create(100)
                 for _, v in pairs (preview:GetChildren()) do
                     if (v:IsA("Part") or v:IsA("UnionOperation")) and v.Transparency < 1 then
                         local tween = TweenService:Create(v, TweenInfo.new(deployableStats.DeployTime), {Transparency = 0})
                         tween:Play()
                         table.insert(tweenTable, tween)
                     end
                 end
 
                 self.ActiveTweens = tweenTable
            end)
 
            task.wait(deployableStats.DeployTime)
 
            if self.Placing and preview ~= nil and preview.Parent ~= nil then
                self.CurrentDeployable = RequestDeployable:InvokeServer(deployableStats.Name, modelCFrame)
                
                preview:Destroy()
                Player:SetAttribute("PlacingDeployable", false)
            end
        end
    end
end

function DeployableEngine:CancelDeployable()
    self.Placing = false

    if self.Preview ~= nil then
        self.Preview:Destroy()
        self.Preview = nil
    end

    if self.ActiveTweens ~= nil then
        for _, tween: Tween in pairs(self.ActiveTweens) do
            task.spawn(function()
                tween:Pause()
                tween:Destroy()
            end)
        end 
    end

    Player:SetAttribute("PlacingDeployable", false)
end

return DeployableEngine
