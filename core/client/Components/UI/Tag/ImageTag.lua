local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UiAssets = ReplicatedStorage:WaitForChild("Assets", 5).UI
local _ImageTag = UiAssets:WaitForChild("Tags", 5).ImageTag

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type ImageTag_T = {
    __index: ImageTag_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local ImageTag: ImageTag_T = {}
ImageTag.__index = ImageTag
ImageTag.Name = "ImageTag"
ImageTag.Tag = "ImageTag"
ImageTag.Ancestor = game

function ImageTag.new(root: any)
    return setmetatable({
        Root = root,
        Tag = _ImageTag:Clone()
    }, ImageTag)
end

function ImageTag:Start()
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


function ImageTag:SetImage(id: number)
    self.Tag.ImageLabel = id
end

function ImageTag:Destroy()
    self.Cleaner:Clean()
    self.Tag:Destroy()
end

tcs.create_component(ImageTag)

return ImageTag