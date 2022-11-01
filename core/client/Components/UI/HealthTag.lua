local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"):WaitForChild("GenericTypes"))
local ChatStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("ChatStats"))

local NameTagGui = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("NameTagGui") :: BillboardGui

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui") :: PlayerGui

type Cleaner_T = types.Cleaner_T

type Courier_T = types.Courier_T

type HealthTag_T = {
    __index: HealthTag_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local HealthTag: HealthTag_T = {}
HealthTag.__index = HealthTag
HealthTag.Name = "HealthTag"
HealthTag.Tag = "HealthTag"
HealthTag.Ancestor = Players

function HealthTag.new(root: any)
    return setmetatable({
        Root = root,
    }, HealthTag)
end

function HealthTag:Start()
    if self.Root == Player then return end
    self:CreateTag()
end

function HealthTag:CreateTag()
    local character = self.Root.Character or self.Root.CharacterAdded:Wait()
    local head = character:WaitForChild("Head")

    local tag = NameTagGui:Clone()
    tag.Adornee = head
    tag.Name = self.Root.Name
    tag.Parent = PlayerGui
    tag.PlayerNameFrame.PlayerName.Text = self.Root.Name

    local team = tostring(self.Root.TeamColor)
    if ChatStats.TeamColors[team] == nil then team = "Default" end

    local nameFrame = tag:WaitForChild("PlayerNameFrame")
    local nameLabel = nameFrame:WaitForChild("PlayerName")
    nameLabel.Text = self.Root.Name		
    nameLabel.TextColor3 = ChatStats.TeamColors[team].Text
    nameLabel.TextStrokeColor3 = ChatStats.TeamColors[team].Stroke

    local healthBarFrame = tag:WaitForChild("HealthBarFrame")
    self.Root:GetAttributeChangedSignal("TotalHealth"):Connect(function()
        healthBarFrame.HealthBar:TweenSize(UDim2.new(self.Root:GetAttribute("TotalHealth") / self.Root:GetAttribute("TotalMaxHealth"), 0, 1, 0), "Out", "Quad", .2, true)
        if self.Root:GetAttribute("TotalHealth") < self.Root:GetAttribute("TotalMaxHealth") * .30 then
            healthBarFrame.HealthBar.BackgroundColor3 = Color3.fromRGB(255, 78, 96)
        else
            healthBarFrame.HealthBar.BackgroundColor3 = Color3.fromRGB(85, 255, 127)
        end    
    end)

    self.NameTag = tag

    self.Cleaner:Add(self.Root.Changed:Connect(function(prop)
        if prop == "TeamColor" then
            self:UpdateTag()
        end
    end))

    self:DisplayTag(true)
end

function HealthTag:UpdateTag()
    self.NameTag.PlayerNameFrame.PlayerName.TextColor3 = ChatStats.TeamColors[tostring(self.Root.TeamColor)].Text
    self.NameTag.PlayerNameFrame.PlayerName.TextStrokeColor3 = ChatStats.TeamColors[tostring(self.Root.TeamColor)].Stroke

    self:DisplayTag(self:OnTeam())
end

function HealthTag:DisplayTag(shouldDisplay, spot)
    self.NameTag.Size = UDim2.new(0,49,0,24) -- Temporary workaround to fix a gui bug that makes the healthbar use the full screenwidth of a player.
    self.NameTag.Size = UDim2.new(0,50,0,25)

    if shouldDisplay and (self:OnTeam() or spot) then
        self.NameTag.GuiPart:TweenSizeAndPosition(UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0, 13), "Out", "Linear", .2, true)
		task.delay(0.2, function()
            self.NameTag.PlayerNameFrame.PlayerName:TweenPosition(UDim2.new(0, 0, -.1, 0), "Out", "Quad", .2, true)
            self.NameTag.HealthBarFrame:TweenSize(UDim2.new(1, 0, 0, 5), "Out", "Quad", .2, true)
        end)
    else
        self.NameTag.PlayerNameFrame.PlayerName:TweenPosition(UDim2.new(0, 0, 1, 0), "Out", "Quad", .2, true)
        self.NameTag.HealthBarFrame:TweenSize(UDim2.new(1, 0, 0, 0), "Out", "Quad", .2, true)
        
        task.delay(0.2, function()
            self.NameTag.GuiPart:TweenSizeAndPosition(UDim2.new(0, 0, 0, 1), UDim2.new(.5, 0, 0, 13), "Out", "Linear", .2, true)
        end)
    end
end

function HealthTag:OnTeam()
    return self.Root.TeamColor == Player.TeamColor
end

function HealthTag:Destroy()
    if self.NameTag then
        self.NameTag:Destroy()
    end
    self.Cleaner:Clean()
end

tcs.create_component(HealthTag)

return HealthTag