local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))
local ObjectiveConfigurations = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("ObjectiveConfigurations"))

local GameStateSignal = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameStateSignal") :: RemoteFunction

local Assets = ReplicatedStorage:WaitForChild("Assets")
local VoteFrame = Assets:WaitForChild("UI"):WaitForChild("VoteFrame")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local function createListLayout()
    local uIListLayout = Instance.new("UIListLayout")
    uIListLayout.Name = "uIListLayout"
    uIListLayout.Padding = UDim.new(0.025, 0)
    uIListLayout.FillDirection = Enum.FillDirection.Horizontal
    uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uIListLayout.SortOrder = Enum.SortOrder.Name
    uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    return uIListLayout
end

local function createVotingFrame(name: string, voteCount: number)
    local frame = VoteFrame:Clone() :: Frame & {ImageLabel: ImageLabel, Title: TextLabel, Votes: TextLabel, Button: TextButton}
    frame.Name = name
    frame.Title.Text = string.upper(name)
    frame.Votes.Text = "VOTES: "..tostring(voteCount)

    local image = ObjectiveConfigurations.MapImages[name] or ObjectiveConfigurations.ModeImages[name] or ""
    frame.ImageLabel.Image = image

    return frame
end

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Overlay_T = {
    __index: Overlay_T,
    Name: string,
    Tag: string,
    Events: {
        ArmorySelected: typeof(Signal.new())
    },
    Root: {
        Voting: Frame
    },

    Cleaner: Cleaner_T
}

local Overlay: Overlay_T = {}
Overlay.__index = Overlay
Overlay.Name = "Overlay"
Overlay.Tag = "Overlay"
Overlay.Ancestor = PlayerGui

function Overlay.new(root: any)
    return setmetatable({
        Root = root,

        Events = {
            ArmorySelected = Signal.new()
        }
    }, Overlay)
end

function Overlay:Start()
    self.Root.Enabled = true
    local main = self.Root:WaitForChild("Main")
    local voting = self.Root:WaitForChild("Voting")
    main.Visible = true
    voting.Visible = true
    local buttonContainer = main.ButtonContainer
    local armoryButton = buttonContainer.Armory.Button :: TextButton
    local playButton = buttonContainer.Play.Button :: TextButton

    self.Cleaner:Add(armoryButton.MouseButton1Click:Connect(function()
        main.Visible = false
        voting.Visible = false
        self.Events.ArmorySelected:Fire()
    end))

    self.Cleaner:Add(playButton.MouseButton1Click:Connect(function()
        if GameStateSignal:InvokeServer("Join") then
            self.Root.Enabled = false
        end
    end))

    local pollSignal = ReplicatedStorage:WaitForChild("PollSignal") :: RemoteEvent

    local voteCleaner = Trove.new()
    local voteSignal = ReplicatedStorage:WaitForChild("VoteSignal") :: RemoteEvent
    self.Cleaner:Add(voteSignal.OnClientEvent:Connect(function(map: {[string]: number}, timer)
        self.Root.Voting.Container:ClearAllChildren()
        createListLayout().Parent = self.Root.Voting.Container

        if map ~= nil then
            if timer ~= nil then
                task.spawn(function()
                    for i = timer, 1 do
                        self.Root.Alert.Text = "Vote Timer: " .. i .. "s"
                        task.wait(1)
                    end    
                end)
            end

            for name, voteCount in map do
                local frame = createVotingFrame(name, voteCount)
                frame.Parent = self.Root.Voting.Container
    
                voteCleaner:Add(frame.Button.MouseButton1Click:Connect(function()
                    pollSignal:FireServer(name)
                end))
            end
        end
    end))
end

function Overlay:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(Overlay)

return Overlay