-- By Preston (seliso)
-- 1/11/2022
-----------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared", 5)
local Util = Shared:WaitForChild("util", 5)

local comm = require(Util:WaitForChild("Comm", 5))

local ClientComm = {
    Comm = comm.ClientComm.new(ReplicatedStorage, true)
}

-----------------------------------------------------------------------------

return {
    GetComm = function() 
        return ClientComm.Comm;
    end,

    GetClientComm = function() 
        return ClientComm.Comm;
    end,
}