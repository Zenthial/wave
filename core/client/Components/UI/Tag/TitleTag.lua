local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UiAssets = ReplicatedStorage:WaitForChild("Assets", 5).UI
local _TitleTag = UiAssets:WaitForChild("Tags", 5).TitleTag

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

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
            self.Tag.Visible = true
            return
        end

        self.Tag.Visible = false
    end

    self.Cleaner:Add(self.Root:GetAttributeChangedSignal("Enabled"):Connect(rootEnable))
    rootEnable()
end

function TitleTag:SetText(str : string)
    self.Tag.Text = str
end

function TitleTag:Destroy()
    self.Cleaner:Clean()
    self.Tag:Destroy()
end

tcs.create_component(TitleTag)

return TitleTag