local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UiAssets = ReplicatedStorage:WaitForChild("Assets", 5).UI
local _PlayerInfoTag = UiAssets:WaitForChild("Tags", 5).PlayerInfoTag

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local TweenService = game:GetService("TweenService")
local TweenInfo1 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type PlayerInfoTag_T = {
    __index: PlayerInfoTag_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local PlayerInfoTag: PlayerInfoTag_T = {}
PlayerInfoTag.__index = PlayerInfoTag
PlayerInfoTag.Name = "PlayerInfoTag"
PlayerInfoTag.Tag = "PlayerInfoTag"
PlayerInfoTag.Ancestor = game

function PlayerInfoTag.new(root: any)
    local _tag = _PlayerInfoTag:Clone()
    return setmetatable({
        Root = root,
        Tag = _tag,
        NameText = _tag.Frame.NameText,
        LevelText = _tag.Frame.LevelText
    }, PlayerInfoTag)
end

function PlayerInfoTag:Start()
    self.Tag.Parent = self.Root
    self.Tag.Frame.Position = UDim2.new(1,0,0,0)

    local function rootEnable()
        local bool = self.Root:GetAttribute("Enabled")
        if bool then
            self:Enable()
            return
        end
        self:Disable()
    end

    self.Cleaner:Add(self.Root:GetAttributeChangedSignal("Enabled"):Connect(rootEnable))
    rootEnable()
end

function PlayerInfoTag:ConnectTo(subject : Instance)
    self.NameText.Text = subject.DisplayName
    self.LevelText.Text = "[LVL 1]"
end

function PlayerInfoTag:Enable()
    TweenService:Create(self.Tag.Frame, TweenInfo1, { Position = UDim2.new(0, 0, 0, 0) }):Play()
end

function PlayerInfoTag:Disable()
    TweenService:Create(self.Tag.Frame, TweenInfo1, { Position = UDim2.new(1, 0, 0, 0) }):Play()
end

function PlayerInfoTag:SetColor(color : Color3)
    
end

function PlayerInfoTag:Destroy()
    self:Disable()
    self.Cleaner:Clean()
    task.delay(0.5, function() 
        self.Tag:Destroy()
    end)
end

tcs.create_component(PlayerInfoTag)

return PlayerInfoTag