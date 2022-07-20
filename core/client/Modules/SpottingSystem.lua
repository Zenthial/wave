
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local Util = ReplicatedStorage:WaitForChild("Shared").util
local Input = require(Util:WaitForChild("Input"))
local Keyboard = Input.Keyboard

local Client = Players.LocalPlayer
local Mouse = Client:GetMouse()

local SPOT_LIFETIME = 5

------------------------------------------------------------------------

local function getHumanoid(hit: Instance)
    local humanoid = hit.Parent:FindFirstChild("Humanoid")
    if not humanoid then
        humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")
    end
    return humanoid
end

local function spotEnemy(nameTag)
    nameTag.Tag:SetAttribute("Enabled", true)
    nameTag.Tag:SetAttribute("Tick", os.time())

    CollectionService:AddTag(nameTag.Tag, "ImageTag")
    local imageTag = tcs.await_component(nameTag.Tag, "ImageTag")
    imageTag:SetImage(10180459956)
    imageTag:SetColor(Color3.fromRGB(254, 85, 85))

    local renderStep 
    renderStep = RunService.RenderStepped:Connect(function(dt) 
        local startTime = nameTag.Tag:GetAttribute("Tick")
        if startTime + SPOT_LIFETIME > os.time() then return end

        renderStep:Disconnect()
        CollectionService:RemoveTag(nameTag.Tag, "ImageTag")
        nameTag.Tag:SetAttribute("Enabled", false)
    end)
end

local function Spot()
    local target = Mouse.Target

    if not target then return end

    local humanoid = getHumanoid(target)
    local player = humanoid and Players:GetPlayerFromCharacter(humanoid.Parent)
    local nameTag = player and tcs.getcomponent(humanoid.Parent, "Tag")

    if not nameTag then return end

    if player.TeamColor == Client.TeamColor then return end

    spotEnemy(nameTag)
end


local SpottingSystem = {}

function SpottingSystem:Start()
    local keyboard = Keyboard.new()
    
    keyboard.KeyDown:Connect(function(key)
        if key == Enum.KeyCode[Client.Keybinds:GetAttribute("Spot")] then
            Spot()
        end
    end)

end

return SpottingSystem