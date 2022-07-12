local ReplicatedStorage = game:GetService("ReplicatedStorage")

local uiAssets = ReplicatedStorage:WaitForChild("Assets", 5).UI
local arrowTag = uiAssets:WaitForChild("Tags", 5).ArrowTag

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type ArrowTag_T = {
    __index: ArrowTag_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local ArrowTag: ArrowTag_T = {}
ArrowTag.__index = ArrowTag
ArrowTag.Name = "ArrowTag"
ArrowTag.Tag = "ArrowTag"
ArrowTag.Ancestor = game

function ArrowTag.new(root: any)
    return setmetatable({
        Root = root,
        Tag = arrowTag:Clone()
    }, ArrowTag)
end

function ArrowTag:Start()
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

function ArrowTag:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(ArrowTag)

return ArrowTag