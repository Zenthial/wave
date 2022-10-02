local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type DeathTracker_T = {
    __index: DeathTracker_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local DeathTracker: DeathTracker_T = {}
DeathTracker.__index = DeathTracker
DeathTracker.Name = "DeathTracker"
DeathTracker.Tag = "DeathTracker"
DeathTracker.Ancestor = Player:WaitForChild("PlayerGui")

function DeathTracker.new(root: any)
    return setmetatable({
        Root = root,
        TrackerCleaner = Trove.new()
    }, DeathTracker)
end

function DeathTracker:Start()
    self.Cleaner:Add(Player:GetAttributeChangedSignal("Dead"):Connect(function()
        local isDead = Player:GetAttribute("Dead")
        if isDead then
            self:Enable()
        else
            self:Disable()
        end
    end))
end

function DeathTracker:Enable()
    local myTeam = Player.Team
    local teammates = myTeam:GetPlayers()
    table.remove(teammates, table.find(teammates, Player))

    local currentPlayerIndex = 1
    local currentPlayer = teammates[currentPlayerIndex]
    
    local function updateCamera()
        if currentPlayerIndex == 0 then
            currentPlayerIndex = #teammates
        elseif currentPlayerIndex > #teammates then
            currentPlayerIndex = 0
        end

        currentPlayer = teammates[currentPlayerIndex]
        Camera.CameraSubject = currentPlayer.Character
    end

    local function updateSpectating()
        self.Root.Spectating.Text = currentPlayer.Name
    end

    for _, teammate in teammates do
        self.TrackerCleaner:Add(teammate:GetAttributeChangedSignal("Dead"):Connect(function()
            local index = table.find(teammates, teammate)
            if index ~= nil then
                table.remove(teammates, index)
            end
        end))
    end

    self.Root.Visible = true
    local imageButtonsAndIncrements = {{ImageButton = self.Root.Forward :: ImageButton, Increment = 1}, {ImageButton = self.Root.Backward :: ImageButton, Increment = -1}}
    for _, info in imageButtonsAndIncrements do
        self.TrackerCleaner:Add(info.ImageButton.MouseButton1Click:Connect(function()
            currentPlayerIndex += info.Increment
            updateCamera()
            updateSpectating()
        end)) 
    end

    updateCamera()
end

function DeathTracker:Disable()
    self.TrackerCleaner:Clean()
    Camera.CameraSubject = Player.Character
    self.Root.Visible = false
end

function DeathTracker:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(DeathTracker)

return DeathTracker