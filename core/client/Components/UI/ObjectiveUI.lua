local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local ObjectiveConfigurations = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("ObjectiveConfigurations"))
local createObjectiveMarker = require(ReplicatedStorage:WaitForChild("HEXShared"):WaitForChild("createObjectiveMarker"))

local Assets = ReplicatedStorage:WaitForChild("Assets")
local UI = Assets:WaitForChild("UI")
local ObjectiveMarker = UI:WaitForChild("ObjectiveMarker") :: ImageLabel & {Point: TextLabel}

local ObjectiveSignal = ReplicatedStorage:WaitForChild("ObjectiveSignal") :: RemoteEvent
local OwnershipSignal = ReplicatedStorage:WaitForChild("OwnershipSignal") :: RemoteEvent
local ObjectiveStartSignal = ReplicatedStorage:WaitForChild("ObjectiveStartSignal") :: RemoteEvent
local ObjectiveEndSignal = ReplicatedStorage:WaitForChild("ObjectiveEndSignal") :: RemoteEvent
local MarkerSignal = ReplicatedStorage:WaitForChild("MarkerSignal") :: RemoteEvent
local MessageSignal = ReplicatedStorage:WaitForChild("MessageSignal") :: RemoteEvent
local TimerSignal = ReplicatedStorage:WaitForChild("TimerSignal") :: RemoteEvent

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local ObjectiveColors = {
    Red = Color3.fromRGB(235, 28, 10),
    Blue = Color3.fromRGB(18, 141, 235),
    Neutral = Color3.fromRGB(137, 137, 137)
}

local ObjectiveIcons = {
    Neutral = "rbxassetid://9560349721",
    Red = "rbxassetid://9849821389",
    Blue = "rbxassetid://9849821389",
}

local function secondsToClock(seconds)
    seconds = tonumber(seconds)
  
    if seconds <= 0 then
        return "00:00:00";
    else
        local mins = string.format("%02.f", math.floor(seconds/60));
        local secs = string.format("%02.f", math.floor(seconds - mins *60));
        return mins..":"..secs
    end
  end

local function createModeMarker(mode: string, pointString: string, parent: Frame)
    local marker = ObjectiveMarker:Clone()
    marker.Name = mode..pointString
    marker.Visible = false
    marker.Image = ObjectiveIcons.Neutral
    marker.ImageColor3 = ObjectiveColors.Neutral
    marker.Point.Text = pointString
    marker.Parent = parent

    return marker
end

local function makeMessage(message: string)
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "textLabel"
    textLabel.Font = Enum.Font.SciFi
    textLabel.Text = message
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextScaled = true
    textLabel.TextSize = 14
    textLabel.TextWrapped = true
    textLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.fromScale(1, 0.4)

    local uITextSizeConstraint = Instance.new("UITextSizeConstraint")
    uITextSizeConstraint.Name = "uITextSizeConstraint"
    uITextSizeConstraint.Parent = textLabel

    return textLabel
end
type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type ObjectiveUI_T = {
    __index: ObjectiveUI_T,
    Name: string,
    Tag: string,
    Root: Frame & {
        Blue: Frame & {
            Fill: Frame,
            Score: TextLabel
        },
        Red: Frame & {
            Fill: Frame,
            Score: TextLabel
        },
        Container: Frame & {UIListLayout: UIListLayout},
        MessageContainer: Frame & {UIListLayout: UIListLayout},
        Timer: TextLabel
    },

    Cleaner: Cleaner_T
}

local ObjectiveUI: ObjectiveUI_T = {}
ObjectiveUI.__index = ObjectiveUI
ObjectiveUI.Name = "ObjectiveUI"
ObjectiveUI.Tag = "ObjectiveUI"
ObjectiveUI.Ancestor = PlayerGui

function ObjectiveUI.new(root: any)
    return setmetatable({
        Root = root,

        ObjectiveMarkers = {}
    }, ObjectiveUI)
end

function ObjectiveUI:Start()
    local billboardMarkers = {}

    for _, thing in self.Root.Container:GetChildren() do
        if not thing:IsA("UIListLayout") then
            thing:Destroy()
        end
    end

    for _, thing in self.Root.MessageContainer:GetChildren() do
        if not thing:IsA("UIListLayout") then
            thing:Destroy()
        end
    end

    for modeName, modeInfo in ObjectiveConfigurations.ModeInfo do
        local tble = {}
        for _, pointString in modeInfo.Points do
            table.insert(tble, createModeMarker(modeName, pointString, self.Root.Container))
        end

        self.ObjectiveMarkers[modeName] = tble
    end

    self.Cleaner:Add(ObjectiveStartSignal.OnClientEvent:Connect(function(mode)
        for modeName, markers in self.ObjectiveMarkers do
            for _, marker in markers do
                marker.Visible = (modeName == mode)
            end
        end

        self.Root.Red.Score.Text = 0
        self.Root.Blue.Score.Text = 0
        TweenService:Create(self.Root.Red.Fill, TweenInfo.new(0.5), {Size = UDim2.new(0, 0, 0.75, 0)}):Play()
        TweenService:Create(self.Root.Blue.Fill, TweenInfo.new(0.5), {Size = UDim2.new(0, 0, 0.75, 0)}):Play()
    end))

    self.Cleaner:Add(ObjectiveEndSignal.OnClientEvent:Connect(function(winner: string)
        for _, billboardMarker: BillboardGui in billboardMarkers do
            billboardMarker:Destroy()
        end

        billboardMarkers = {}
    end))

    self.Cleaner:Add(ObjectiveSignal.OnClientEvent:Connect(function(mode, points)
        local objectiveStats = ObjectiveConfigurations.ModeInfo[mode]
        local maxScore = objectiveStats.MaxScore

        for teamName, teamPoints in points do
            local teamFrame = self.Root[teamName] :: Frame & {
                Fill: Frame,
                Score: TextLabel
            }
            assert(teamFrame, "Frame does not exist for "..teamName)

            teamFrame.Score.Text = teamPoints
            TweenService:Create(teamFrame.Fill, TweenInfo.new(0.5), {Size = UDim2.new(teamPoints/maxScore, 0, 0.75, 0)}):Play()
        end
    end))

    self.Cleaner:Add(TimerSignal.OnClientEvent:Connect(function(time: number)
        self.Root.Timer.Text = secondsToClock(time)
    end))

    self.Cleaner:Add(OwnershipSignal.OnClientEvent:Connect(function(mode, points)
        for pointName, pointOwner in points do
            local marker = self.Root.Container:FindFirstChild(mode..pointName) :: ImageLabel
            assert(marker, "Marker does not exist for "..mode..pointName)

            marker.Image = ObjectiveIcons[pointOwner]
            marker.ImageColor3 = ObjectiveColors[pointOwner]

            if billboardMarkers[pointName] then
                billboardMarkers[pointName].ObjectiveNameFrame.ObjectiveName.TextColor3 = ObjectiveColors[pointOwner]
            end
        end
    end))

    self.Cleaner:Add(MessageSignal.OnClientEvent:Connect(function(message)
        local messageLabel = makeMessage(message)
        messageLabel.Parent = self.Root.MessageContainer

        Debris:AddItem(messageLabel, 0.5)
    end))

    self.Cleaner:Add(MarkerSignal.OnClientEvent:Connect(function(markerParent: Instance, markerName: string)
        if billboardMarkers[markerName] then billboardMarkers[markerName]:Destroy() end
        billboardMarkers[markerName] = createObjectiveMarker(markerParent, markerName)
        
        print("created billboard marker")
    end))
end

function ObjectiveUI:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(ObjectiveUI)

return ObjectiveUI