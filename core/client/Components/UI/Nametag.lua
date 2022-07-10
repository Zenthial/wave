local ReplicatedStorage = game:GetService("ReplicatedStorage")

local uiAssets = ReplicatedStorage:WaitForChild("Assets", 5).UI
local nameTag = uiAssets:WaitForChild("NameTag", 5)

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type NameTag_T = {
    __index: NameTag_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local NameTag: NameTag_T = {}
NameTag.__index = NameTag
NameTag.Name = "NameTag"
NameTag.Tag = "NameTag"
NameTag.Ancestor = game

function NameTag.new(root: any)
    return setmetatable({
        Root = root,
        Tag = nameTag:Clone()
    }, NameTag)
end

function NameTag:Start()
	self.Tag.Parent = self.Root
	self.Tag:SetAttribute("Enabled", false)
	self.Tag:SetAttribute("LastTick", 0)

	--blah blah blah this should be inside of destroy but who cares
	--this looks really nice though
	self.Cleaner:Add(function() 
		self.Tag:Destroy()
	end)
end

function NameTag:SetAdornee(int: any)
	self.Tag.Adornee = int
end

function NameTag:SetName(str: string)
	self.Tag.TagText.Text = str
end

function NameTag:SetColor(healthColor: Color3, nameTagColor: Color3)
	self.Tag.Bar.Frame.BackgroundColor3 = healthColor
	self.Tag.TagText.TextColor3 = nameTagColor
end

function NameTag:Enable()
	self.Tag.Enabled = true
end

function NameTag:Disable()
	self.Tag.Enabled = false
end

function NameTag:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(NameTag)

return NameTag