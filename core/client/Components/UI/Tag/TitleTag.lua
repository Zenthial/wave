local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UiAssets = ReplicatedStorage:WaitForChild("Assets", 5).UI
local _TitleTag = UiAssets:WaitForChild("Tags", 5).TitleTag

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

type TitleTag_T = {
    __index: TitleTag_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local TitleTag: TitleTag_T = {}
TitleTag.__index = TitleTag
TitleTag.Name = "TitleTag"
TitleTag.Tag = "TitleTag"
TitleTag.Ancestor = game

function TitleTag.new(root: any)
    return setmetatable({
        Root = root,
        Tag = _TitleTag:Clone()
    }, TitleTag)
end

function TitleTag:Start()
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

function TitleTag:SetText(str : string)
    self.Tag.Text = str
end

function TitleTag:SetColor(color : Color3)
    self.Tag.TextColor3 = color
end


function TitleTag:Destroy()
    self.Cleaner:Clean()
    self.Tag:Destroy()
end

tcs.create_component(TitleTag)

return TitleTag