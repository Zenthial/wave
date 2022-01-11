-- By Preston (seliso)
-- 1/11/2022
---------------------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared", 5)

local Rosyn = require(Shared:WaitForChild("Rosyn", 5))
local Trove = require(Shared:WaitForChild("util", 5):WaitForChild("Trove", 5))
local Input = require(Shared:WaitForChild("util", 5):WaitForChild("Input", 5))


local Roll = {}
Roll._index = Roll


function Roll.new()
    return setmetatable({}, Roll)
end

function Roll:Initial()

end

function Roll:Destroy() 

end


Rosyn.Register("Roll", {Roll})

return Roll