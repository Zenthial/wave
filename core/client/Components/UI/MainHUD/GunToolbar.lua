local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Weapons = Assets:WaitForChild("Weapons")

local NORMAL_HEAT_COLOR = Color3.fromRGB(255, 155, 15)
local OVERHEAT_COLOR = Color3.fromRGB(255, 59, 15)

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type GunToolbar_T = {
    __index: GunToolbar_T,
    Name: string,
    Tag: string,
    Root: {
        ViewportFrame: ViewportFrame & {
            TriggerIcon: ImageLabel,
            Heat: TextLabel,
            GunName: TextLabel   
        },
        HeatBar: Frame & {
            Frame: Frame
        }
    },
    Camera: Camera,
    InspectItem: Model,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local GunToolbar: GunToolbar_T = {}
GunToolbar.__index = GunToolbar
GunToolbar.Name = "GunToolbar"
GunToolbar.Tag = "GunToolbar"
GunToolbar.Ancestor = game

function GunToolbar.new(root: any)
    return setmetatable({
        Root = root,
    }, GunToolbar)
end

function GunToolbar:Start()
    self.Root.ViewportFrame.TriggerIcon.Visible = false
    self.Root.ViewportFrame.Heat.Text = ""
    self.Root.ViewportFrame.GunName.Text = ""
    self.Root.HeatBar.Frame.Size = UDim2.new(0, 0, 0.8, 0)

    local camera = Instance.new("Camera")
    camera.CameraType = Enum.CameraType.Scriptable
    camera.Parent = self.Root.ViewportFrame

    self.Root.ViewportFrame.CurrentCamera = camera
    self.Camera = camera
end

function GunToolbar:SetViewport(weaponName: string)
    if weaponName == nil then if self.InspectItem ~= nil then self.InspectItem:Destroy() self.InspectItem = nil end return end
    
    local inspectFolder = Weapons:FindFirstChild(weaponName) :: Folder
    assert(inspectFolder ~= nil, "No folder for "..weaponName)
    
    local inspectModel: Model = nil

    if inspectFolder:IsA("Configuration") and inspectFolder:FindFirstChild("Model") then
        inspectModel = inspectFolder.Model:Clone() :: Model
        inspectModel.PrimaryPart = nil
        inspectModel:PivotTo(CFrame.new(Vector3.new(0, 0, 0), Vector3.new(5, 0, 0)) * CFrame.Angles(0, math.rad(180), 0))
    end

    for _, thing in pairs(inspectModel:GetChildren()) do
        if thing:IsA("BasePart") then thing.Anchored = true end
    end
    inspectModel.Name = "InspectModel"..weaponName
    inspectModel.Parent = self.Root.ViewportFrame

    self.Camera.CFrame = CFrame.new(Vector3.new(0, 0, -1.25), Vector3.new(0, 0, 0))
    
    if self.InspectItem ~= nil then self.InspectItem:Destroy() end
    self.InspectItem = inspectModel
end

function GunToolbar:SetOverheated(bool: boolean)
    if bool == true then
        TweenService:Create(self.Root.HeatBar.Frame, TweenInfo.new(0.5), {Size = UDim2.new(1, 0, .8, 0)}):Play()
        TweenService:Create(self.Root.HeatBar.Frame, TweenInfo.new(0.5), {BackgroundColor3 = OVERHEAT_COLOR}):Play()
    elseif bool == false and self.InspectItem ~= nil then
        TweenService:Create(self.Root.HeatBar.Frame, TweenInfo.new(0.5), {Size = UDim2.new(1, 0, .8, 0)}):Play()
        TweenService:Create(self.Root.HeatBar.Frame, TweenInfo.new(0.5), {BackgroundColor3 = NORMAL_HEAT_COLOR}):Play()
    elseif bool == nil or self.InspectItem == nil then
        TweenService:Create(self.Root.HeatBar.Frame, TweenInfo.new(0.5), {Size = UDim2.new(0, 0, .8, 0)}):Play()
    end
end

function GunToolbar:TriggerBar(triggerTime: number)
    self.Root.ViewportFrame.TriggerIcon.Visible = true
    task.delay(triggerTime, function() self.Root.ViewportFrame.TriggerIcon.Visible = false end)
end

function GunToolbar:SetHeat(heat: number)
    if heat == nil then
        self.Root.ViewportFrame.Heat.Text = ""
    else
        self.Root.ViewportFrame.Heat.Text = tostring(heat) .. "%"
    end    
end

function GunToolbar:SetName(name: string)
    if name == nil then
        self.Root.ViewportFrame.GunName.Text = ""
    else
        self.Root.ViewportFrame.GunName.Text = name
    end
end

function GunToolbar:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(GunToolbar)

return GunToolbar