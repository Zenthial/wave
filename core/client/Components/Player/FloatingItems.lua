local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

-- local Item3DUI = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("UI"):WaitForChild("Item3DUI")
local Item3DUI = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("UI"):WaitForChild("Item3DUI2")
local Line = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("UI"):WaitForChild("Line")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local LineHolder = Instance.new("ScreenGui")
LineHolder.Name = "LineHolder"
LineHolder.Parent = Player.PlayerGui

local PRIMARY_CFRAME = CFrame.new(-2, 2.50000095, 0.49996376, 0.258819044, 0, -0.965925813, 0, 1, 0, 0.965925813, 0, 0.258819044)
local SECONDARY_CFRAME = CFrame.new(2.36461449, 0.300001144, 0.925140381, -0.258819044, 0, -0.965925813, 0, 1, 0, 0.965925813, 0, -0.258819044)
local SKILL_CFRAME = CFrame.new(1.79716492, 2.10000134, 0.701183319, -0.0871557444, 0, -0.99619472, 0, 1, 0, 0.99619472, 0, -0.0871557444)
local GADGET_CFRAME = CFrame.new(-1.81335068, -0.099998951, 1.11741257, 0.0871557444, 0, -0.99619472, 0, 1, 0, 0.99619472, 0, 0.0871557444)

local function createItem(parent)
    local item = Instance.new("Part")
    item.Name = "Item"
    item.Anchored = true
    item.BottomSurface = Enum.SurfaceType.Smooth
    item.CFrame = CFrame.new(-19, 5.50000095, -17.7999992, 0.965925813, 0, 0.258819044, 0, 1, 0, -0.258819044, 0, 0.965925813)
    item.Orientation = Vector3.new(0, 15, 0)
    item.Position = Vector3.new(-19, 5.5, -17.8)
    item.Rotation = Vector3.new(0, 15, 0)
    item.Size = Vector3.new(0.1, 1, 1)
    item.CanCollide = false
    item.CanQuery = false
    item.CanTouch = false
    item.TopSurface = Enum.SurfaceType.Smooth
    item.Transparency = 1
    item.Parent = parent

    local ui = Item3DUI:Clone()
    ui.Name = "Item3DUI"
    ui.Parent = item

    return item
end

local deg = math.pi / 180
local function drawLine(frame, x0, y0, x1, y1, visible)
    local dx = x1 - x0
    local dy = y1 - y0
    local length = (dx * dx + dy * dy)^0.5
    local angle = math.atan2(dy, dx)
    frame.Position = UDim2.new(0, (x0 + x1)/2, 0, (y0 + y1)/2)
    frame.Size = UDim2.new(0, length + 1, 0, 2)
    frame.Rotation = angle / deg
    frame.Visible = visible
end

local function createLine(one: Vector2, two: Vector2)
    local frame = Line:Clone()

    drawLine(frame, one.X, one.Y, two.X, two.Y, true)

    frame.Parent = LineHolder
    return frame
end

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type FloatingItems_T = {
    __index: FloatingItems_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local FloatingItems: FloatingItems_T = {}
FloatingItems.__index = FloatingItems
FloatingItems.Name = "FloatingItems"
FloatingItems.Tag = "Player"
FloatingItems.Ancestor = game

function FloatingItems.new(root: any)
    return setmetatable({
        Root = root,
    }, FloatingItems)
end

function FloatingItems:Start()
    repeat
        task.wait()
    until Player:GetAttribute("ServerSideInventoryLoaded") == true

    local char = Player.Character or Player.CharacterAdded:Wait()
    local primaryName = Player:GetAttribute("EquippedPrimary")
    local secondaryName = Player:GetAttribute("EquippedSecondary")
    local skillName = Player:GetAttribute("EquippedSkill")
    local gadgetName = Player:GetAttribute("EquippedGadget")

    local primary = createItem(char)
    -- primary.Item3DUI.Frame.ItemName.Text = primaryName
    primary.Item3DUI.Frame.Keybind.Text = "1"
    primary.CFrame = char.HumanoidRootPart.CFrame:ToWorldSpace(PRIMARY_CFRAME)
    
    local secondary = createItem(char)
    -- secondary.Item3DUI.Frame.ItemName.Text = secondaryName
    secondary.Item3DUI.Frame.Keybind.Text = "2"
    secondary.CFrame = char.HumanoidRootPart.CFrame:ToWorldSpace(SECONDARY_CFRAME)

    local skill = createItem(char)
    -- skill.Item3DUI.Frame.ItemName.Text = skillName
    skill.Item3DUI.Frame.Keybind.Text = Player.Keybinds:GetAttribute("Skill")
    skill.Item3DUI.Frame.Keybind.TextColor3 = Color3.fromRGB(195, 15, 255)
    skill.CFrame = char.HumanoidRootPart.CFrame:ToWorldSpace(SKILL_CFRAME)

    local gadget = createItem(char)
    -- gadget.Item3DUI.Frame.ItemName.Text = gadgetName
    gadget.Item3DUI.Frame.Keybind.Text = Player.Keybinds:GetAttribute("Gadget")
    gadget.Item3DUI.Frame.Keybind.TextColor3 = Color3.fromRGB(255, 148, 129)
    gadget.CFrame = char.HumanoidRootPart.CFrame:ToWorldSpace(GADGET_CFRAME)

    local primaryModel = char:FindFirstChild(primaryName)
    local secondaryModel = char:FindFirstChild(secondaryName)
    local skillModel = char:FindFirstChild(skillName)

    self:RunServiceLoop(char, primary, secondary, skill, gadget, primaryModel, secondaryModel, skillModel)
end

function FloatingItems:RunServiceLoop(char: Model & {HumanoidRootPart: BasePart}, primary: Instance, secondary: Instance, skill: Instance, gadget: Instance, primaryModel: Model, secondaryModel: Model, skillModel: Model)
    self.Cleaner:Add(RunService.RenderStepped:Connect(function()
        local primaryCFrame = primaryModel.Handle.CFrame
        local secondaryCFrame = secondaryModel.Handle.CFrame
        local skillCFrame = skillModel.Handle.CFrame

        primary.CFrame = CFrame.new(primaryCFrame.Position + Vector3.new(.5, primary.Size.Y, 0.25), Camera.CFrame.Position) * CFrame.Angles(0, 90, 0)
        secondary.CFrame = CFrame.new(secondaryCFrame.Position + Vector3.new(0, 0, 0.25), Camera.CFrame.Position) * CFrame.Angles(0, 90, 0)
        skill.CFrame = CFrame.new(skillCFrame.Position + Vector3.new(0, skill.Size.Y / 2, 1), Camera.CFrame.Position) * CFrame.Angles(0, 90, 0)
        gadget.CFrame = CFrame.new(char.HumanoidRootPart.CFrame:ToWorldSpace(PRIMARY_CFRAME).Position, Camera.CFrame.Position) * CFrame.Angles(0, 90, 0)
    end))
end

function FloatingItems:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(FloatingItems)

return FloatingItems