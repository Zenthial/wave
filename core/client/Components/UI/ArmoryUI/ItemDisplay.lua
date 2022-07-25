local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local Functions = require(script.Parent.Functions)

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local SELECTED_SIZE = UDim2.new(0.55, 0, 0.06, 0)
local UNSELECTED_SIZE = UDim2.new(0, 0, 0.06, 0)

type ItemDisplay = Frame & {
    Title: TextLabel,
    ScrollingFrame: ScrollingFrame & {
        Container: Frame & {
            UIListLayout: UIListLayout,
            UIPadding: UIPadding,
        }
    },
    Details: Folder & {
        TopDetail: Frame,
        BottomDetail: Frame,
    }
}

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type ItemDisplay_T = {
    __index: ItemDisplay_T,
    Name: string,
    Tag: string,
    Root: ItemDisplay,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local ItemDisplay: ItemDisplay_T = {}
ItemDisplay.__index = ItemDisplay
ItemDisplay.Name = "ItemDisplay"
ItemDisplay.Tag = "ItemDisplay"
ItemDisplay.Ancestor = PlayerGui

function ItemDisplay.new(root: any)
    return setmetatable({
        Root = root,
    }, ItemDisplay)
end

function ItemDisplay:Start()

end

function ItemDisplay:SetViewport(viewport: ViewportFrame, modelFolder: Configuration | Folder)
    local camera = Instance.new("Camera")
    viewport.CurrentCamera = camera
    
    local inspectModel
    if modelFolder:IsA("Configuration") and modelFolder:FindFirstChild("Model") then
        inspectModel = modelFolder.Model:Clone() :: Model
        inspectModel.PrimaryPart = nil
        inspectModel:PivotTo(CFrame.new(Vector3.new(0, 0, 0),  Vector3.new(0, 0, 5)) * CFrame.Angles(0, math.rad(180), 0))
    elseif modelFolder:IsA("Configuration") and modelFolder:FindFirstChild("Projectile") then
        local model = Instance.new("Model")
        local proj = modelFolder.Projectile:Clone()
        proj.Parent = model
        inspectModel = model
        inspectModel:PivotTo(CFrame.new(Vector3.new(0, 0, 0)))
    elseif modelFolder:IsA("Model") then -- skill
        inspectModel = modelFolder:Clone()
        inspectModel.PrimaryPart = nil
        inspectModel:PivotTo(CFrame.new(Vector3.new(0, 0, 0), Vector3.new(0, 0, 5)))
    end

    for _, thing in pairs(inspectModel:GetChildren()) do
        if thing:IsA("BasePart") then thing.Anchored = true thing.Material = Enum.Material.Neon thing.BrickColor = BrickColor.new("Institutional white") end
    end

    inspectModel.Name = "InspectModel" .. modelFolder.Name
    inspectModel.Parent = viewport
    
    local distance = 1.25
    if modelFolder.Name == "MSI" or modelFolder.Name == "E31" then
        distance = 1.5
    end
    camera.CFrame = CFrame.new(Vector3.new(-distance, 0, 0), Vector3.new(0, 0, 0))
end

function ItemDisplay:SetWeapon(weaponStats, selected: boolean)
    local tier = Functions.GetTier(weaponStats.WeaponCost)

    local points = Player:GetAttribute("Points")
    local pointsRemaining = weaponStats.WeaponCost - points :: number
    local formattedPoints = Functions.CommaValue(weaponStats.WeaponCost)
    local stringPoints = Functions.GetString(formattedPoints)

    self.Root.MainFrame.ItemName.Text = weaponStats.Name
    self.Root.MainFrame.Price.Text = stringPoints
    self.Root.MainFrame.BackgroundColor3 = self.Root.MainFrame:GetAttribute((selected and "Selected") or "Default")

    self.Root.Selected.BackgroundTransparency = 0
    self.Root.Selected.Size = (selected and SELECTED_SIZE) or UNSELECTED_SIZE
    
    self.Root.Locked.ItemName.Text = weaponStats.Name
    self.Root.Locked.Price.Text = tostring(pointsRemaining) .. " Points Remaining"

    self.Root.TierFrame.TierRating.Text = "0"..string.format(Functions.FORMAT, tostring(tier))

    self.Root.ViewportFrame.BackgroundColor3 = Functions.TIER_COLORS[tier]
    self:SetViewport(self.Root.ViewportFrame, Functions.GetItem(weaponStats.Name))

    if pointsRemaining > 0 then
        self.Root.Locked.Visible = true
        self.Root.MainFrame.Visible = false
    end


    self.Cleaner:Add(Player:GetAttributeChangedSignal("Points"):Connect(function()
        local currentPoints = Player:GetAttribute("Points")
        pointsRemaining = weaponStats.WeaponCost - currentPoints

        self.Root.Locked.Price.Text = tostring(pointsRemaining) .. " Points Remaining"
        if pointsRemaining > 0 then
            self.Root.Locked.Visible = true
            self.Root.MainFrame.Visible = false
        else
            self.Root.Locked.Visible = false
            self.Root.MainFrame.Visible = true
        end
    end))
end

function ItemDisplay:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(ItemDisplay)

return ItemDisplay