local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local ObjectiveConfigurations = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("ObjectiveConfigurations"))

local Assets = ReplicatedStorage:WaitForChild("Assets")
local UI = Assets:WaitForChild("UI")
local ObjectiveMarker = UI:WaitForChild("ObjectiveMarker") :: ImageLabel & {Point: TextLabel}

local ObjectiveSignal = ReplicatedStorage:WaitForChild("ObjectiveSignal") :: RemoteEvent
local OwnershipSignal = ReplicatedStorage:WaitForChild("OwnershipSignal") :: RemoteEvent
local ObjectiveStartSignal = ReplicatedStorage:WaitForChild("ObjectiveStartSignal") :: RemoteEvent
local ObjectiveEndSignal = ReplicatedStorage:WaitForChild("ObjectiveEndSignal") :: RemoteEvent
local TimerSignal = ReplicatedStorage:WaitForChild("TimerSignal") :: RemoteEvent

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
        Timer: TextLabel
    },

    Cleaner: Cleaner_T
}

local ObjectiveUI: ObjectiveUI_T = {}
ObjectiveUI.__index = ObjectiveUI
ObjectiveUI.Name = "ObjectiveUI"
ObjectiveUI.Tag = "ObjectiveUI"
ObjectiveUI.Ancestor = game

function ObjectiveUI.new(root: any)
    return setmetatable({
        Root = root,

        ObjectiveMarkers = {}
    }, ObjectiveUI)
end

function ObjectiveUI:Start()
    for modeName, modeInfo in ObjectiveConfigurations.ModeInfo do
        for _, pointString in modeInfo.Points do
            self.ObjectiveMarkers[modeName] = createModeMarker(modeName, pointString, self.Root.Container)
        end
    end

    self.Cleaner:Add(ObjectiveStartSignal.OnClientEvent:Connect(function(mode)
        for modeName, markers in self.ObjectiveMarkers do
            for _, marker in markers do
                marker.Visible = modeName == mode
            end
        end
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
            TweenService:Create(teamFrame.Fill, TweenInfo.new(0.5, {Size = UDim2.new(teamPoints/maxScore, 0, 0.75, 0)})):Play()
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
        end
    end))
end

function ObjectiveUI:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(ObjectiveUI)

return ObjectiveUI