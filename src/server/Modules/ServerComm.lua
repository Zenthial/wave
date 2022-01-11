-- By Preston (seliso)
-- 1/11/2022
-----------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared", 5)
local Util = Shared:WaitForChild("Util", 5)

local _comm = require(Util:WaitForChild("comm", 5))

local ServerComm = {
    Comm = _comm.new(ReplicatedStorage)
}

-----------------------------------------------------------------------------

return {
    GetComm = function() 
        return ServerComm.Comm;
    end,

    GetServerComm = function() 
        return ServerComm.Comm;
    end,
}