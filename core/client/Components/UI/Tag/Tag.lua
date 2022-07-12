local ReplicatedStorage = game:GetService("ReplicatedStorage")

local uiAssets = ReplicatedStorage:WaitForChild("Assets", 5).UI
local tag = uiAssets:WaitForChild("Tags", 5).Tag

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
        Tag = tag:Clone()
    }, Tag)
end

function Tag:Start()
    self.Tag.Parent = self.Root
    self.Tag:SetAttribute("Enabled", false)
    self.Tag:SetAttribute("PrimaryColor", Color3.fromRGB(255,255,255))
    self.Tag:SetAttribute("SecondaryColor", Color3.fromRGB(255,255,255))
    self.Tag.Enabled = true
    self:SetAdornee(self.Root)
    
    --blah blah blah this should be inside of destroy but who cares
	--this looks really nice though
	self.Cleaner:Add(function() 
		self.Tag:Destroy()
	end)
end

function Tag:SetAdornee(int: any)
	self.Tag.Adornee = int
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
end

tcs.create_component(Tag)

return Tag