local NumericalWrapper = {}

local mt = {
    __add = function(tble, value)
        tble._internalValue += value
        tble._changedFunction(tble._internalValue)
    end,
    __sub = function(tble, value)
        tble._internalValue -= value
        tble._changedFunction(tble._internalValue)
    end,
    __mul = function(tble, value)
        tble._internalValue *= value
        tble._changedFunction(tble._internalValue)
    end,
    __div = function(tble, value)
        tble._internalValue /= value
        tble._changedFunction(tble._internalValue)
    end,
    __mod = function(tble, value)
        tble._internalValue %= value
        tble._changedFunction(tble._internalValue)
    end,
    __pow = function(tble, value)
        tble._internalValue ^= value
        tble._changedFunction(tble._internalValue)
    end,
    __eq = function(tble, value)
        return tble._internalValue == value
    end,
    __lt = function(tble, value)
        return tble._internalValue < value
    end,
    __le = function(tble, value)
        return tble._internalValue <= value
    end
}

function NumericalWrapper.new(defaultValue: number)
    return setmetatable({
        _internalValue = defaultValue,
        _changedFunction = function()
        
        end,

        SetChangedFunction = function(self, fun: () -> ())
            self._changedFunction = fun
        end
    }, mt)
end

return NumericalWrapper