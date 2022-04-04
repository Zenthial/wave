--[[
    Checks if a function yields. If a function
    yields, the coroutine it's spawned in won't
    return immediately.
]]
local function CheckYield(Call): (() -> (...any)) -> (boolean, ...any)
    local Yielded = true
    local Results = {}

    task.spawn(function()
        Results = {Call()}
        Yielded = false
    end)

    return Yielded, unpack(Results)
end

return CheckYield