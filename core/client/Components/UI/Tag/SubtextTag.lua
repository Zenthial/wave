local ReplicatedStorage = game:GetService("ReplicatedStorage")

local uiAssets = ReplicatedStorage:WaitForChild("Assets", 5).UI
local subtextTag = uiAssets:WaitForChild("Tags", 5).SubtextTag

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

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
        Tag = subtextTag:Clone()
    }, SubtextTag)
end

function SubtextTag:Start()
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
    
    self.Cleaner:Add(function() 
		self.Tag:Destroy()
	end)
end

function SubtextTag:SetText(str : string)
    self.Tag.Text = str
end

function SubtextTag:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(SubtextTag)

return SubtextTag