local NumericalWrapper = {}
NumericalWrapper.__index = NumericalWrapper

function NumericalWrapper.new(defaultValue: number)
    local self = setmetatable({
        _internalValue = defaultValue,
        _changedFunction = function()
        
        end
    }, NumericalWrapper)

    self.__add = function(tble, value)
        tble._internalValue += value
        tble._changedFunction(tble._internalValue)
    end
    self.__sub = function(tble, value)
        tble._internalValue -= value
        tble._changedFunction(tble._internalValue)
    end
    self.__mul = function(tble, value)
        tble._internalValue *= value
        tble._changedFunction(tble._internalValue)
    end
    self.__div = function(tble, value)
        tble._internalValue /= value
        tble._changedFunction(tble._internalValue)
    end
    self.__mod = function(tble, value)
        tble._internalValue %= value
        tble._changedFunction(tble._internalValue)
    end
    self.__pow = function(tble, value)
        tble._internalValue ^= value
        tble._changedFunction(tble._internalValue)
    end
    self.__eq = function(tble, value)
        return tble._internalValue == value
    end
    self.__lt = function(tble, value)
        return tble._internalValue < value
    end
    self.__le = function(tble, value)
        return tble._internalValue <= value
    end
    return self
end

function NumericalWrapper:SetChangedFunction(fun: () -> ())
    self._changedFunction = fun
end

return NumericalWrapper