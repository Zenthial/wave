export type CleanableObject = Instance -- Instances
                                | RBXScriptConnection -- Signal connections
                                | Cleaner -- Other Cleaners
                                | thread -- Coroutines
                                | ( () -> () ) -- Functions
                                | { Destroy: ( () -> () ) } -- Objects with Destroy method
                                | { Disconnect: ( () -> () ) } -- Objects with Disconnect method
                                | { CleanableObject } -- Array of any CleanableObjects

export type Cleaner = {
    _Index: number,
    _DidClean: boolean,
    _CleanList: { CleanableObject }
}

local ERR_CLEANER_SELF_REFERENCE = "A Cleaner object was added to itself"
local ERR_CLASS_ALREADY_WRAPPED = "Class already wrapped"
local ERR_UNSUPPORTED_TYPE = "Unsupported type in Cleaner: %s"
local ERR_OBJECT_FINISHED = "Object lifecycle ended, but key %s was indexed"
local ERR_INVALID_OBJECT = "Object passed was an unsupported type"
local ERR_NOT_A_CLASS = "Table passed was not a valid class"
local ERR_NO_OBJECT = "No object given"
local ERR_NO_CLASS = "No class given"

local TYPE_SCRIPT_CONNECTION = "RBXScriptConnection"
local TYPE_INSTANCE = "Instance"
local TYPE_FUNCTION = "function"
local TYPE_THREAD = "thread"
local TYPE_TABLE = "table"

local OBJECT_FINALIZED_MT = {
    __index = function(_, Key)
        error(ERR_OBJECT_FINISHED:format(tostring(Key)))
    end;
}

--- New object & utility functions for handling the lifecycles of Lua objects, aims to help prevent memory leaks
local Cleaner: Cleaner = {}
Cleaner.__index = Cleaner
Cleaner._Supported = {}
Cleaner._Validators = {}

Cleaner._Validators[TYPE_TABLE] = function(Item, self)
    assert(Item ~= self, ERR_CLEANER_SELF_REFERENCE)
    assert(Item.Disconnect ~= nil or Item.Destroy ~= nil or Item.Clean ~= nil or Item[1] ~= nil, ERR_INVALID_OBJECT)

    if Item[1] ~= nil then
        local Validators = Cleaner._Validators

        for _, Value in ipairs(Item) do
            assert(Value ~= self, ERR_CLEANER_SELF_REFERENCE)
            local ValueType = typeof(Value)
            local TargetValidator = Validators[ValueType]
            assert(TargetValidator, ERR_UNSUPPORTED_TYPE:format(ValueType))
            TargetValidator(Value)
        end
    end
end

Cleaner._Validators[TYPE_THREAD] = function() end
Cleaner._Validators[TYPE_INSTANCE] = function() end
Cleaner._Validators[TYPE_FUNCTION] = function() end
Cleaner._Validators[TYPE_SCRIPT_CONNECTION] = function() end

Cleaner._Supported[TYPE_TABLE] = function(Item)
    -- Custom Signal libraries
    if Item.Disconnect then
        Item:Disconnect()
    end

    -- Lua objects with standard lifecycle denoted by Destroy
    if Item.Destroy then
        Item:Destroy()
    end

    -- Single cleaner
    if Item.Clean then
        Item:Clean()
    end

    -- Array of cleanables (can include other Cleaners)
    if Item[1] then
        local NextCleaner = Cleaner.new()

        for _, Value in ipairs(Item) do
            NextCleaner:Add(Value)
        end

        NextCleaner:Clean()
    end
end

Cleaner._Supported[TYPE_THREAD] = function(Item)
    coroutine.close(Item)
end

Cleaner._Supported[TYPE_FUNCTION] = task.spawn

Cleaner._Supported[TYPE_SCRIPT_CONNECTION] = function(Item)
    Item:Disconnect()
end

Cleaner._Supported[TYPE_INSTANCE] = function(Item)
    Item:Destroy()
end

function Cleaner.new()
    return setmetatable({
        _DidClean = false;
        _CleanList = {};
        _Index = 1;
    }, Cleaner)
end

--- Adds an object to this Cleaner. Object must be one of the following:
--- - Cleaner
--- - Function
--- - Coroutine
--- - Roblox Instance
--- - Roblox Event Connection
--- - Table of cleanable objects
--- - Table containing one of the following methods:
---   - Object:Clean()
---   - Object:Destroy()
---   - Object:Disconnect()
function Cleaner:Add(...: CleanableObject)
    local Validators = Cleaner._Validators
    local CleanList = self._CleanList

    -- Verify types & push onto array
    for _, Item in ipairs({...}) do
        local Type = typeof(Item)
        local Validator = Validators[Type]
        assert(Validator, ERR_UNSUPPORTED_TYPE:format(Type))

        if Validator then
            Validator(Item, self)
        end

        CleanList[self._Index] = Item
        self._Index += 1
    end

    -- Add after Clean called? Likely result of bad yielding, so clean up whatever is doing this.
    if self._DidClean then
        self:Clean()
    end
end
Cleaner.add = Cleaner.Add

--- Cleans and locks this Cleaner preventing it from being used again. If an object is added to the Cleaner after it has been locked, it will be cleaned immediately.
function Cleaner:Clean()
    local Supported = Cleaner._Supported
    local CleanList = self._CleanList

    for Index, Item in ipairs(CleanList) do
        Supported[typeof(Item)](Item)
        CleanList[Index] = nil
    end

    self._Index = 1
    self._DidClean = true
end
Cleaner.clean = Cleaner.Clean

--- Adds whatever coroutine called this method to the Cleaner
function Cleaner:AddContext()
    self:Add(coroutine.running())
end
Cleaner.addContext = Cleaner.AddContext

local function CleanerSpawn(self, Call, ...)
    self:AddContext()
    Call(...)
end

--- Spawns a coroutine & adds to the Cleaner
function Cleaner:Spawn(Callback, ...)
    task.spawn(CleanerSpawn, self, Callback, ...)
end
Cleaner.spawn = Cleaner.Spawn

local function CleanerDelay(Duration, Call, ...)
    task.wait(Duration)
    Call()
end

--- Delays a spawned coroutine & adds to cleaner
function Cleaner:Delay(Time, Callback, ...)
    self:Spawn(CleanerDelay, Time, Callback, ...)
end
Cleaner.delay = Cleaner.Delay

-- Standalone functions --

--- Permanently locks down an object once finished
function Cleaner.Lock(Object)
    assert(Object, ERR_NO_OBJECT)

    for Key in pairs(Object) do
        Object[Key] = nil
    end

    setmetatable(Object, OBJECT_FINALIZED_MT)
    table.freeze(Object)
end
Cleaner.lock = Cleaner.Lock

--- Wraps the class to ensure more lifecycle safety, including auto-lock on Destroy
function Cleaner.Wrap(Class)
    assert(Class, ERR_NO_CLASS)
    assert(not Cleaner.IsWrapped(Class), ERR_CLASS_ALREADY_WRAPPED)
    assert(Class.__index ~= nil and Class.new ~= nil, ERR_NOT_A_CLASS)

    -- Creation --
    local OriginalNew = Class.new

    Class.new = function(...)
        local Object = OriginalNew(...)
        Object.Cleaner = Object.Cleaner or Cleaner.new()
        return Object
    end

    -- Destruction --
    local OriginalDestroy = Class.Destroy

    Class.Destroy = function(self, ...)
        if OriginalDestroy then
            OriginalDestroy(self, ...)
        end

        Cleaner.Lock(self)
    end

    Class._CLEANER_WRAPPED = true

    return Class
end
Cleaner.wrap = Cleaner.Wrap

--- Determines if a class is already wrapped
function Cleaner.IsWrapped(Class)
    return Class._CLEANER_WRAPPED ~= nil
end
Cleaner.isWrapped = Cleaner.IsWrapped

return Cleaner