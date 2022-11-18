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
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))
local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Weapons = Assets:WaitForChild("Weapons")
local Skills = Assets:WaitForChild("Skills")
local UI = Assets:WaitForChild("UI")

local InspectFrame = UI:WaitForChild("InspectFrame")
local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local InventoryPlayer = nil
local ArsenalModel = workspace:WaitForChild("Arsenal") :: Model
local InspectPart = ArsenalModel:WaitForChild("InspectPart") :: Part

local RAYCAST_MAX_DISTANCE = 50

type Cleaner_T = {
    Add: (Cleaner_T, any, string?) -> (),
    Clean: (Cleaner_T) -> ()
}

type Arsenal_T = {
    __index: Arsenal_T,
    Name: string,
    Tag: string,
    PrimaryModel: nil | Model,
    SecondaryModel: nil | Model,
    SkillModel: nil | Model,
    InspectItem: nil | Model,
    CurrentlySelected: number,
    ArmoryUI: {self: {}, Populate: (self: {}, slot: number) -> typeof(Signal)},

    Cleaner: Cleaner_T
}

local Arsenal: Arsenal_T = {}
Arsenal.__index = Arsenal
Arsenal.Name = "Arsenal"
Arsenal.Tag = "Arsenal"
Arsenal.Ancestor = PlayerGui

function Arsenal.new(root: any)
    return setmetatable({
        Root = root,
        PrimaryModel = nil,
        SecondaryModel = nil,
        SkillModel = nil,
        CurrentlySelected = 0,
        InspectWeapon = nil,
        MouseCleaner = nil,
    }, Arsenal)
end

function Arsenal:Start()
    if Player.Character == nil then Player.CharacterAdded:Wait() end
    repeat task.wait() until Player:GetAttribute("Loaded") == true
    task.wait(0.5)

    InventoryPlayer = Assets:WaitForChild("InventoryPlayer"):Clone()
    InventoryPlayer.Parent = workspace
    ArmoryUtil:LoadCharacterAppearance(Player, InventoryPlayer)

    for _, thing in pairs(InventoryPlayer:GetChildren()) do
        if thing:IsA("Accessory") and thing:FindFirstChild("Handle") then
            thing.Handle.CanQuery = false
        end
    end

    if not CollectionService:HasTag(InventoryPlayer, "AnimationHandler") then
        CollectionService:AddTag(InventoryPlayer, "AnimationHandler")
    end

    local animationComponent = tcs.get_component(InventoryPlayer, "AnimationHandler")
    self.AnimationComponent = animationComponent

    self:LoadCharacter()
    self:SetupInspectTable(Player:GetAttribute("EquippedPrimary"))

    self.ArmoryUI = tcs.get_component(self.Root.Armory, "ClassArmoryUI")
    local Overlay = tcs.get_component(self.Root, "Overlay")

    self.Cleaner:Add(Overlay.Events.ArmorySelected:Connect(function()
        self:ArmorySelection()
    end))

    self.Cleaner:Add(Player:GetAttributeChangedSignal("InArsenalSelection"):Connect(function()
        local inClassSelection = Player:GetAttribute("InArsenalSelection")

        if not inClassSelection then
            Camera.CameraType = Enum.CameraType.Scriptable
            Camera.CFrame = CFrame.new(InventoryPlayer.HumanoidRootPart.Position + Vector3.new(12, 0, 0), InventoryPlayer.HumanoidRootPart.Position)
        else
            Camera.CameraType = Enum.CameraType.Custom
            Camera.CameraSubject = Player.Character
        end
    end))

    self.Cleaner:Add(self.Root.Back.Button.MouseButton1Click:Connect(function()
        self.Root.Main.Visible = true
        self.Root.Voting.Visible = true
        self.Root.Back.Visible = false
        self.Root.ArmoryText.Visible = false

        if self.MouseCleaner then
            self.MouseCleaner:Clean()
            self.MouseCleaner = nil     
        end

        if self.InventoryPlayerRotationCleaner then
            self.InventoryPlayerRotationCleaner:Clean()
            self.InventoryPlayerRotationCleaner = nil
        end

        TweenService:Create(Camera, TweenInfo.new(0.5), {CFrame = CFrame.new(InventoryPlayer.HumanoidRootPart.Position + Vector3.new(12, 0, 0), InventoryPlayer.HumanoidRootPart.Position)}):Play()
    end))

    self.ArmoryUI.Events.InspectItem:Connect(function(itemName: string)
        self:SetupInspectTable(itemName)
    end)
end

function Arsenal:ArmorySelection()
    self.Root.Back.Visible = true
    self.Root.ArmoryText.Visible = true

    TweenService:Create(Camera, TweenInfo.new(0.5), {
        CFrame = CFrame.new(InventoryPlayer.HumanoidRootPart.Position + Vector3.new(5.5, -0.5, 0), InventoryPlayer.HumanoidRootPart.Position)
    }):Play()

    self.InventoryPlayerRotationCleaner = self:InventoryPlayerRotation()
    self.MouseCleaner = self:HandleMouse()
end

function Arsenal:InventoryPlayerRotation()
    local itemCleaner = Trove.new()

    local function handleInput(_inputObject: InputObject)
        local pressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        if pressed then
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
            local change = UserInputService:GetMouseDelta()

            if InventoryPlayer then
                InventoryPlayer:PivotTo(InventoryPlayer:GetPivot() * CFrame.Angles(0, math.rad(change.X), 0))
            end
        else
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end
    end

    itemCleaner:Add(UserInputService.InputBegan:Connect(handleInput))
    itemCleaner:Add(UserInputService.InputChanged:Connect(handleInput))
    itemCleaner:Add(UserInputService.InputEnded:Connect(handleInput))

    return itemCleaner
end

function Arsenal:SetupInspectTable(weaponName: string)
    local inspectFolder = Weapons:FindFirstChild(weaponName) :: Folder
    if not inspectFolder then
        inspectFolder = Skills:FindFirstChild(weaponName)
    end
    assert(inspectFolder ~= nil, "No folder for "..weaponName)
    
    local inspectModel: Model = nil

    if inspectFolder:IsA("Configuration") and inspectFolder:FindFirstChild("Model") then
        inspectModel = inspectFolder.Model:Clone() :: Model
        inspectModel.PrimaryPart = nil
        inspectModel:PivotTo(CFrame.new(InspectPart.CFrame.Position, InspectPart.CFrame.Position - Vector3.new(5, 0, 0)))
    elseif inspectFolder:IsA("Configuration") and inspectFolder:FindFirstChild("Projectile") then
        local model = Instance.new("Model")
        local proj = inspectFolder.Projectile:Clone()
        proj.Parent = model
        inspectModel = model
        inspectModel:PivotTo(InspectPart.CFrame - Vector3.new(.15, 0, 0))
    elseif inspectFolder:IsA("Model") then -- skill
        inspectModel = inspectFolder:Clone()
        inspectModel.PrimaryPart = nil
        inspectModel:PivotTo(CFrame.new(InspectPart.CFrame.Position, InspectPart.CFrame.Position - Vector3.new(0, 0, 5)))
    end

    for _, thing in pairs(inspectModel:GetChildren()) do
        if thing:IsA("BasePart") then thing.Anchored = true end
    end
    inspectModel.Name = "InspectModel"..weaponName
    inspectModel.Parent = workspace
    
    if self.InspectItem ~= nil then self.InspectItem:Destroy() end
    self.InspectItem = inspectModel
end

function Arsenal:RemoveWeapon(weaponName: string, stopAnimation: boolean)
    local oldWeaponModel = InventoryPlayer:FindFirstChild(weaponName)
    if oldWeaponModel then oldWeaponModel:Destroy() end
    if stopAnimation then
        local animationComponent = tcs.get_component(InventoryPlayer, "AnimationHandler")
        animationComponent:Stop(weaponName.."easeMiddle")
    end
end

function Arsenal:LoadCharacter()
    InventoryPlayer["Right Arm"].Transparency = 0
    InventoryPlayer["Right Leg"].Transparency = 0
    InventoryPlayer["Left Leg"].Transparency = 0

    local primaryName = Player:GetAttribute("EquippedPrimary")
    local secondaryName = Player:GetAttribute("EquippedSecondary")
    local skillName = Player:GetAttribute("EquippedSkill")

    local primaryFolder = Weapons[primaryName] :: Folder
    if not primaryFolder then error("No weapon folder for "..primaryName) end
    local secondaryFolder = Weapons[secondaryName] :: Folder
    if not secondaryFolder then error("No weapon folder for "..secondaryName) end
    local skillModel = Skills[skillName] :: Model
    if not skillModel then error("No skill model for "..skillName) end
    
    local primaryModel = primaryFolder.Model:Clone() :: Model
    primaryModel.Name = primaryName
    local secondaryModel = secondaryFolder.Model:Clone() :: Model
    secondaryModel.Name = secondaryName
    skillModel = skillModel:Clone()

    self:SetupCollisionGroups(primaryModel, primaryName)
    self:SetupCollisionGroups(secondaryModel, secondaryName)
    self:SetupCollisionGroups(skillModel, skillName)

    primaryModel.Parent = InventoryPlayer
    secondaryModel.Parent = InventoryPlayer
    skillModel.Parent = InventoryPlayer

    if self.PrimaryModel then self.PrimaryModel:Destroy() end
    if self.SecondaryModel then self.SecondaryModel:Destroy() end
    if self.SkillModel then self.SkillModel:Destroy() end
    self.PrimaryModel = primaryModel
    self.SecondaryModel = secondaryModel
    self.SkillModel = skillModel

    Welder:WeldWeapon(InventoryPlayer, primaryModel, false)
    Welder:WeldWeapon(InventoryPlayer, secondaryModel, true)
    Welder:WeldWeapon(InventoryPlayer, skillModel, true)

    local animationComponent = self.AnimationComponent
    self:LoadAnimationFolder(animationComponent, primaryFolder, primaryName)
    animationComponent:Play(primaryName.."easeMiddle")

    self.Cleaner:Add(function()
        self.PrimaryModel = nil
        self.SecondaryModel = nil
        self.SkillModel = nil

        primaryModel:Destroy()
        secondaryModel:Destroy()
        skillModel:Destroy()
        InventoryPlayer:Destroy()
    end)
end

function Arsenal:LoadAnimationFolder(component, folder: Folder, name: string)
    for _, animation: Animation in pairs(folder.Anims:GetChildren()) do
        local ani = animation:Clone()
        ani.Name = name..""..ani.Name
        component:Load(ani)
    end
end

function Arsenal:SetupCollisionGroups(model: Model, collisionGroup: string)
    for _, thing in pairs(model:GetDescendants()) do
        if thing:IsA("BasePart") then
            thing:SetAttribute("CollisionGroup", collisionGroup)
        end
    end
end

function Arsenal:HighlightModel(model: Model)
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(63, 149, 241)
    highlight.FillTransparency = 0.6
    highlight.Parent = model
end

function Arsenal:HighlightPrimary()
    if self.PrimaryModel then
        self:HighlightModel(self.PrimaryModel)
    end
end

function Arsenal:HighlightSecondary()
    if self.SecondaryModel then
        self:HighlightModel(self.SecondaryModel)
    end
end

function Arsenal:HighlightSkill()
    if self.SkillModel then
        self:HighlightModel(self.SkillModel)
    end
end

function Arsenal:CleanupHighlights()
    if self.PrimaryModel and self.PrimaryModel:FindFirstChild("Highlight") then
        self.PrimaryModel.Highlight:Destroy()
    end
    if self.SecondaryModel and self.SecondaryModel:FindFirstChild("Highlight") then
        self.SecondaryModel.Highlight:Destroy()
    end
    if self.SkillModel and self.SkillModel:FindFirstChild("Highlight") then
        self.SkillModel.Highlight:Destroy()
    end
end

function Arsenal:HandleMouse()
    local primaryName = Player:GetAttribute("EquippedPrimary")
    local secondaryName = Player:GetAttribute("EquippedSecondary")
    local skillName = Player:GetAttribute("EquippedSkill")

    local mouse = Player:GetMouse()

    local internalCleaner = Trove.new()
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {self.SkillModel, self.PrimaryModel, self.SecondaryModel}
    internalCleaner:Add(mouse.Move:Connect(function()
        local raycastResult = workspace:Raycast(Camera.CFrame.Position, (mouse.Hit.Position - Camera.CFrame.Position).Unit * RAYCAST_MAX_DISTANCE)

        if raycastResult then
            local part = raycastResult.Instance
            if part and part:IsA("BasePart") then
                if part:GetAttribute("CollisionGroup") == primaryName then
                    self:CleanupHighlights()
                    self:HighlightPrimary()
                    self.CurrentlySelected = 1
                elseif part:GetAttribute("CollisionGroup") == secondaryName then
                    self:CleanupHighlights()
                    self:HighlightSecondary()
                    self.CurrentlySelected = 2
                elseif part:GetAttribute("CollisionGroup") == skillName then
                    self:CleanupHighlights()
                    self:HighlightSkill()
                    self.CurrentlySelected = 4
                else
                    self:CleanupHighlights()
                    self.CurrentlySelected = 0
                end
            end
        end
    end))

    internalCleaner:Add(UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if self.CurrentlySelected > 0 then
                internalCleaner:Clean()
                if self.InventoryPlayerRotationCleaner then
                    self.InventoryPlayerRotationCleaner:Clean()
                    self.InventoryPlayerRotationCleaner = nil
                end
                self:HandleSelected()
            end
        end
    end))

    self.Cleaner:Add(internalCleaner, "Clean")

    return internalCleaner
end

function Arsenal:HandleSelected()
    self.Root.ArmoryText.Visible = false
    self.Root.Back.Visible = false

    local target = self.PrimaryModel :: Model & {Highlight: Highlight}
    if self.CurrentlySelected == 2 then
        target = self.SecondaryModel
    elseif self.CurrentlySelected == 4 then
        target = self.SkillModel
    end

    local inspectFrame = InspectFrame:Clone()
    inspectFrame.Label.Text = target.Name
    inspectFrame.Parent = self.Root

    local boundingBox = target:GetBoundingBox()
    local position = boundingBox.Position + Vector3.new(2, -1, 1)
    local tween = TweenService:Create(Camera, TweenInfo.new(0.5), {CFrame = CFrame.new(position, boundingBox.Position)})
    tween:Play()
    tween.Completed:Wait()

    local internalCleaner = Trove.new()
    internalCleaner:Add(inspectFrame.Edit.Button.MouseButton1Click:Connect(function()
        internalCleaner:Clean()
        target.Highlight.FillTransparency = 1
        target.Highlight.OutlineColor = Color3.new(1, 1, 1)

        if self.CurrentlySelected == 2 then
            InventoryPlayer["Right Arm"].Transparency = 0.5
            InventoryPlayer["Right Leg"].Transparency = 0.5
            InventoryPlayer["Left Leg"].Transparency = 0.5
        end

        TweenService:Create(Camera, TweenInfo.new(0.5), {CFrame = CFrame.new(InspectPart.Position - Vector3.new(0, 0, 5), InspectPart.Position)}):Play()
        local itemCleaner = self:HandleItemRotation()
        inspectFrame:Destroy()
        internalCleaner:Add(self.ArmoryUI:Populate(self.CurrentlySelected):Connect(function(itemName: string)
            itemCleaner:Clean()

            self.Root.ArmoryText.Visible = true
            self.Root.Back.Visible = true

            if itemName ~= nil then
                local oldWeapon
                if self.CurrentlySelected == 1 then
                    oldWeapon = Player:GetAttribute("EquippedPrimary")
                    Player:SetAttribute("EquippedPrimary", itemName)
                elseif self.CurrentlySelected == 2 then
                    oldWeapon = Player:GetAttribute("EquippedSecondary")
                    Player:SetAttribute("EquippedSecondary", itemName)
                elseif self.CurrentlySelected == 4 then
                    oldWeapon = Player:GetAttribute("EquippedSkill")
                    Player:SetAttribute("EquippedSkill", itemName)
                end
                self:RemoveWeapon(oldWeapon, self.CurrentlySelected == 1)
                self:LoadCharacter()
            end
            self:ArmorySelection()
            internalCleaner:Clean()
        end))
    end))

    internalCleaner:Add(inspectFrame)

    internalCleaner:Add(UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if self.CurrentlySelected > 0 then
                internalCleaner:Clean()
                self:ArmorySelection()
            end
        end
    end))

    self.Cleaner:Add(internalCleaner, "Clean")
end

function Arsenal:HandleItemRotation()
    local itemCleaner = Trove.new()

    local function handleInput(_inputObject: InputObject)
        local pressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        if pressed then
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
            local change = UserInputService:GetMouseDelta()

            if self.InspectItem then
                self.InspectItem:PivotTo(self.InspectItem:GetPivot() * CFrame.Angles(0, math.rad(change.X), 0))
            end
        else
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end
    end

    itemCleaner:Add(UserInputService.InputBegan:Connect(handleInput))
    itemCleaner:Add(UserInputService.InputChanged:Connect(handleInput))
    itemCleaner:Add(UserInputService.InputEnded:Connect(handleInput))

    return itemCleaner
end

function Arsenal:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(Arsenal)

return Arsenal