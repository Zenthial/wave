local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local WeaponStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))

local LocalPlayer = Players.LocalPlayer

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Port: string) -> {Connect: RBXScriptSignal},
    Send: (Port: string, ...any) -> ()
}

type C4_T = {
    __index: C4_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local C4: C4_T = {}
C4.__index = C4
C4.Name = "C4"
C4.Tag = "C4"
C4.Ancestor = game

function C4.new(root: any)
    return setmetatable({
        Root = root,
        Active = false,
    }, C4)
end

function C4:Start()
    self.Active = true
    local gadgetStats = WeaponStats["C4"]

end

function C4:Destroy()
    self.Active = false
    self.Cleaner:Clean()
end

tcs.create_component(C4)

return C4
