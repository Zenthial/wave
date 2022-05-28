-- a vast, over-arching component handling almost everything related to the armory selection
-- ties into the UI as well

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local ArmoryUtil = require(script.Parent.Parent.Modules.Armory.ArmoryUtil) :: {
    LoadCharacterAppearance: (self: ModuleScript, player: Player, model: Model, overwriteName: string?) -> ()
}
local WeaponStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))
local Welder = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("Welder"))

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Weapons = Assets:WaitForChild("Weapons")
local UI = Assets:WaitForChild("UI")

local InspectFrame = UI:WaitForChild("InspectFrame")
local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer
local InventoryPlayer = nil

local RAYCAST_MAX_DISTANCE = 50

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Armory_T = {
    __index: Armory_T,
    Name: string,
    Tag: string,
    PrimaryModel: nil | Model,
    SecondaryModel: nil | Model,
    CurrentlySelected: number,

    Cleaner: Cleaner_T
}

local Armory: Armory_T = {}
Armory.__index = Armory
Armory.Name = "Armory"
Armory.Tag = "Armory"
Armory.Ancestor = game

function Armory.new(root: any)
    return setmetatable({
        Root = root,
        PrimaryModel = nil,
        SecondaryModel = nil,
        CurrentlySelected = 0,
        Times = 0,
    }, Armory)
end

function Armory:Start()
    InventoryPlayer = Assets:WaitForChild("InventoryPlayer"):Clone()
    InventoryPlayer.Parent = workspace
    self:LoadCharacter()

    Camera.CameraType = Enum.CameraType.Scriptable

    self:SetupListeners()
end

function Armory:SetupListeners()
    TweenService:Create(Camera, TweenInfo.new(if self.Times == 0 then 1 else 0.5), {
        CFrame = CFrame.new(InventoryPlayer.HumanoidRootPart.Position - Vector3.new(5.5, -1.2, 0), InventoryPlayer.HumanoidRootPart.Position)
    }):Play()

    self.Times += 1

    self:HandleMouse()
end

function Armory:LoadCharacter()
    if not CollectionService:HasTag(InventoryPlayer, "AnimationHandler") then
        CollectionService:AddTag(InventoryPlayer, "AnimationHandler")
    end

    local primaryName = Player:GetAttribute("EquippedPrimary")
    local secondaryName = Player:GetAttribute("EquippedSecondary")

    ArmoryUtil:LoadCharacterAppearance(Player, InventoryPlayer)
    local animationComponent = tcs.get_component(InventoryPlayer, "AnimationHandler")

    local primaryFolder = Weapons[primaryName] :: Folder
    if not primaryFolder then error("No weapon folder for "..primaryName) end
    local secondaryFolder = Weapons[secondaryName] :: Folder
    if not secondaryFolder then error("No weapon folder for "..secondaryName) end

    self:LoadAnimationFolder(animationComponent, primaryFolder, primaryName)
    self:LoadAnimationFolder(animationComponent, secondaryFolder, secondaryName)
    
    local primaryModel = primaryFolder.Model:Clone() :: Model
    primaryModel.Name = primaryName
    local secondaryModel = secondaryFolder.Model:Clone() :: Model
    secondaryModel.Name = secondaryName

    self:SetupCollisionGroups(primaryModel, primaryName)
    self:SetupCollisionGroups(secondaryModel, secondaryName)

    primaryModel.Parent = InventoryPlayer
    secondaryModel.Parent = InventoryPlayer

    self.PrimaryModel = primaryModel
    self.SecondaryModel = secondaryModel

    Welder:WeldWeapon(InventoryPlayer, primaryModel, false)
    Welder:WeldWeapon(InventoryPlayer, secondaryModel, true)
    
    animationComponent:Play(primaryName.."easeMiddle")

    self.Cleaner:Add(function()
        self.PrimaryModel = nil
        self.SecondaryModel = nil

        primaryModel:Destroy()
        secondaryModel:Destroy()
        InventoryPlayer:Destroy()
    end)
end

function Armory:LoadAnimationFolder(component, folder: Folder, name: string)
    for _, animation: Animation in pairs(folder.Anims:GetChildren()) do
        local ani = animation:Clone()
        ani.Name = name..""..ani.Name
        component:Load(ani)
    end
end

function Armory:SetupCollisionGroups(model: Model, collisionGroup: string)
    for _, thing in pairs(model:GetDescendants()) do
        if thing:IsA("BasePart") then
            thing:SetAttribute(collisionGroup, true)
        end
    end
end

function Armory:HighlightModel(model: Model)
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(63, 149, 241)
    highlight.FillTransparency = 0.6
    highlight.Parent = model
end

function Armory:HighlightPrimary()
    if self.PrimaryModel then
        self:HighlightModel(self.PrimaryModel)
    end
end

function Armory:HighlightSecondary()
    if self.SecondaryModel then
        self:HighlightModel(self.SecondaryModel)
    end
end

function Armory:CleanupHighlights()
    if self.PrimaryModel and self.PrimaryModel:FindFirstChild("Highlight") then
        self.PrimaryModel.Highlight:Destroy()
    elseif self.SecondaryModel and self.SecondaryModel:FindFirstChild("Highlight") then
        self.SecondaryModel.Highlight:Destroy()
    end
end

function Armory:HandleMouse()
    local primaryName = Player:GetAttribute("EquippedPrimary")
    local secondaryName = Player:GetAttribute("EquippedSecondary")

    local mouse = Player:GetMouse()
    local mouseConnection = mouse.Move:Connect(function()
        local raycastResult = workspace:Raycast(Camera.CFrame.Position, (mouse.Hit.Position - Camera.CFrame.Position).Unit * RAYCAST_MAX_DISTANCE)

        if raycastResult then
            local part = raycastResult.Instance
            if part and part:IsA("BasePart") then
                if part:GetAttribute(primaryName) ~= nil then
                    self:CleanupHighlights()
                    self:HighlightPrimary()
                    self.CurrentlySelected = 1
                elseif part:GetAttribute(secondaryName) ~= nil then
                    self:CleanupHighlights()
                    self:HighlightSecondary()
                    self.CurrentlySelected = 2
                else
                    self:CleanupHighlights()
                    self.CurrentlySelected = 0
                end
            end
        end
    end)

    local inputConnection: RBXScriptConnection
    inputConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if self.CurrentlySelected > 0 then
                inputConnection:Disconnect()
                mouseConnection:Disconnect()
                self:HandleSelected()
            end
        end
    end)

    self.Cleaner:Add(function()
        if inputConnection and inputConnection.Connected then
            inputConnection:Disconnect()
        end

        if mouseConnection and mouseConnection.Connected then
            mouseConnection:Disconnect()
        end
    end)
end

function Armory:HandleSelected()
    local target = self.PrimaryModel
    if self.CurrentlySelected == 2 then
        target = self.SecondaryModel
    end

    local inspectFrame = InspectFrame:Clone()
    inspectFrame.Label.Text = target.Name
    inspectFrame.Parent = self.Root

    local boundingBox = target:GetBoundingBox()
    local position = boundingBox.Position - Vector3.new(2, 1, 1)
    local tween = TweenService:Create(Camera, TweenInfo.new(0.5), {CFrame = CFrame.new(position, boundingBox.Position)})
    tween:Play()
    tween.Completed:Wait()

    local editConnection
    editConnection = inspectFrame.Button.MouseButton1Click:Connect(function()
        print("edit")
    end)

    local inputConnection
    inputConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if self.CurrentlySelected > 0 then
                inspectFrame:Destroy()
                editConnection:Disconnect()
                inputConnection:Disconnect()
                self:SetupListeners()
            end
        end
    end)

    self.Cleaner:Add(function()
        if inputConnection and inputConnection.Connected then
            inputConnection:Disconnect()
        end

        if editConnection and editConnection.Connected then
            editConnection:Disconnect()
        end
    end)
end

function Armory:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(Armory)

return Armory