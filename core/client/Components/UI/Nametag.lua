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

type Nametag_T = {
	__index: Nametag_T,
	Name: string,
	Tag: string,

	Cleaner: Cleaner_T,
	Courier: Courier_T
}

local Nametag: Nametag_T = {}
Nametag.__index = Nametag
Nametag.Name = "Nametag"
Nametag.Tag = "Nametag"
Nametag.Ancestor = game

function Nametag.new(root: any)
	local folder = nameTag:Clone()

	return setmetatable({
		Root = root,
		NameTag = folder,
		HealthUI = folder.HealthUI,
		Highlight = folder.Highlight
	}, Nametag)
end

function Nametag:Start()
	self.NameTag.Parent = self.Root
	self.NameTag:SetAttribute("Enabled", false)
	self.NameTag:SetAttribute("LastTick", 0)

	self:SetAdornee(self.Root)
	self:Enable()

	--blah blah blah this should be inside of destroy but who cares
	--this looks really nice though
	self.Cleaner:Add(function() 
		self.NameTag:Destroy()
	end)
end

function Nametag:SetAdornee(int: any)
	self.HealthUI.Adornee = int
	self.Highlight.Adornee = int
end

function Nametag:SetColor(healthColor: Color3, nameTagColor: Color3)
	print("color change")

end

function Nametag:Enable()
	print("nametag enabled")

	self.HealthUI.Enabled = true
	self.Highlight.Enabled = true
end

function Nametag:Disable()
	print("nametag disabled")

	self.HealthUI.Enabled = false
	self.Highlight.Enabled = false
end

function Nametag:Destroy()
	self.Cleaner:Clean()
end

tcs.create_component(Nametag)

return Nametag