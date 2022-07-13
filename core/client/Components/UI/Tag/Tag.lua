local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UiAssets = ReplicatedStorage:WaitForChild("Assets", 5).UI
local _Tag = UiAssets:WaitForChild("Tags", 5).Tag

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type Tag_T = {
    __index: Tag_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local Tag: Tag_T = {}
Tag.__index = Tag
Tag.Name = "Tag"
Tag.Tag = "Tag"
Tag.Ancestor = game

function Tag.new(root: any)
    return setmetatable({
        Root = root,
        Tag = _Tag:Clone()
    }, Tag)
end

function Tag:Start()
    self.Tag.Parent = self.Root
    self.Tag:SetAttribute("Enabled", false)
    self.Tag:SetAttribute("PrimaryColor", Color3.fromRGB(255,255,255))
    self.Tag:SetAttribute("SecondaryColor", Color3.fromRGB(255,255,255))
    self.Tag.Enabled = true
    self:SetAdornee(self.Root)
end

function Tag:SetAdornee(instance: Instance)
	self.Tag.Adornee = instance
end

function Tag:SetColor(healthColor: Color3, nameTagColor: Color3)

end

function Tag:Enable()
    self.Tag:SetAttribute("Enabled", true)
end

function Tag:Disable()
    self.Tag:SetAttribute("Enabled", false)
end

function Tag:Destroy()
    self.Cleaner:Clean()
    self.Tag:Destroy()
end

tcs.create_component(Tag)

return Tag