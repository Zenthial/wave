local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UiAssets = ReplicatedStorage:WaitForChild("Assets", 5).UI
local _SubtextTag = UiAssets:WaitForChild("Tags", 5).SubtextTag

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local TweenService = game:GetService("TweenService")
local TweenInfo1 = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type SubtextTag_T = {
    __index: SubtextTag_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local SubtextTag: SubtextTag_T = {}
SubtextTag.__index = SubtextTag
SubtextTag.Name = "SubtextTag"
SubtextTag.Tag = "SubtextTag"
SubtextTag.Ancestor = game

function SubtextTag.new(root: any)
    return setmetatable({
        Root = root,
        Tag = _SubtextTag:Clone()
    }, SubtextTag)
end

function SubtextTag:Start()
    self.Tag.Parent = self.Root

    local function rootEnable()
        local bool = self.Root:GetAttribute("Enabled")

        if bool then
            self.Tag.TextTransparency = 0
            self.Tag.Frame.Position = UDim2.new(0,0,0,0)
            TweenService:Create(self.Tag.Frame, TweenInfo1, { Position = UDim2.new(1, 0, 0, 0) }):Play()
            return
        end

        local tween = TweenService:Create(self.Tag.Frame, TweenInfo1, { Position = UDim2.new(0, 0, 0, 0) })
        local connection = nil
        connection = tween.Completed:Connect(function()
            connection:Disconnect()
            local newBool = self.Root:GetAttribute("Enabled")
            if newBool then return end

            TweenService:Create(self.Tag.Frame, TweenInfo1, { Position = UDim2.new(-1, 0, 0, 0) }):Play()
            self.Tag.TextTransparency = 1
        end)

        tween:Play()
    end

    self.Cleaner:Add(self.Root:GetAttributeChangedSignal("Enabled"):Connect(rootEnable))
    rootEnable()
end

function SubtextTag:SetText(str : string)
    self.Tag.Text = str
end

function SubtextTag:Destroy()
    self.Cleaner:Clean()
    self.Tag:Destroy()
end

tcs.create_component(SubtextTag)

return SubtextTag