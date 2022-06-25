local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local getFlavorText = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("functions"):WaitForChild("getFlavorText"))

local ObjectiveEndSignal = ReplicatedStorage:WaitForChild("ObjectiveEndSignal") :: RemoteEvent
local GameStateSignal = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameStateSignal") :: RemoteFunction

local DETAIL_SIZE = UDim2.new(0.831, 0, 0.002, 0)
local BACKGROUND_TRANSPARENCY = 0.25
local TEXT_TRANSPARENCY = 0.25

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type VictoryUI_T = {
    __index: VictoryUI_T,
    Name: string,
    Tag: string,
    Root: Frame & {
        PlayerList: Frame & {UIGridLayout: UIGridLayout},
        GuiPart: Frame,
        Code: TextLabel,
        Flavor: TextLabel,
        Title: TextLabel
    },

    Cleaner: Cleaner_T
}

local VictoryUI: VictoryUI_T = {}
VictoryUI.__index = VictoryUI
VictoryUI.Name = "VictoryUI"
VictoryUI.Tag = "VictoryUI"
VictoryUI.Ancestor = game

function VictoryUI.new(root: any)
    return setmetatable({
        Root = root,
    }, VictoryUI)
end

function VictoryUI:Start()
    self.Root.Visible = false

    self.Cleaner:Add(ObjectiveEndSignal.OnClientEvent:Connect(function(winner)
        self:ShowUI(winner)
    end))
end

function VictoryUI:ShowUI(winner: string)
    self.Root.Visible = true

    TweenService:Create(self.Root.GuiPart, TweenInfo.new(0.25), {Size = DETAIL_SIZE}):Play()
    TweenService:Create(self.Root, TweenInfo.new(0.25), {BackgroundTransparency = BACKGROUND_TRANSPARENCY}):Play()

    for _, thing in pairs(self.Root:GetChildren()) do
        if thing:IsA("TextLabel") then
            TweenService:Create(thing, TweenInfo.new(0.25), {TextTransparency = TEXT_TRANSPARENCY}):Play()
        end
    end

    self.Root.Title.Text = ""
    self.Root.Code.Text = string.lower(winner .. " wins!")
    self.Root.Flavor.Text = getFlavorText()

    task.wait(5)

    GameStateSignal:InvokeServer("Leave")

    self.Root.Visible = false
    self.Root.GuiPart.Size = UDim2.new(0, 0, 0.002, 0)
    self.Root.BackgroundTransparency = 1
    

    for _, thing in pairs(self.Root:GetChildren()) do
        if thing:IsA("TextLabel") then
            thing.TextTransparency = 1
        end
    end
end

function VictoryUI:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(VictoryUI)

return VictoryUI