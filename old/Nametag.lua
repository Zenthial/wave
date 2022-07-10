local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
	return setmetatable({
		Root = root,
	}, Nametag)
end

function Nametag:Start()

end

function Nametag:Enable()
	print("nametag enabled")
end

function Nametag:Disable()
	print("nametag disabled")
end

function Nametag:Destroy()
	self.Cleaner:Clean()
end

tcs.create_component(Nametag)

return Nametag