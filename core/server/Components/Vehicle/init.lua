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

type Vehicle_T = {
    __index: Vehicle_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local Vehicle: Vehicle_T = {}
Vehicle.__index = Vehicle
Vehicle.Name = "Vehicle"
Vehicle.Tag = "Vehicle"
Vehicle.Ancestor = workspace

function Vehicle.new(root: any)
    return setmetatable({
        Root = root,
    }, Vehicle)
end

function Vehicle:Start()

end

function Vehicle:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(Vehicle)

return Vehicle