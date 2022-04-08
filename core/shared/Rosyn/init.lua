--!nonstrict
type ComponentInstance = any
type ComponentClass = {
    __Tag: string?,

    new: (Instance) -> ComponentInstance,
    Initial: () -> (),
    Destroy: () -> (),
}

type InstanceToComponents = {[Instance]: {[ComponentClass]: ComponentInstance}}
type ComponentClassToInstances = {[ComponentClass]: {[Instance]: boolean}}
type ComponentClassToComponents = {[ComponentClass]: {[ComponentInstance]: boolean}}

type ComponentClassAddedEvents = {[ComponentClass]: {[any]: any}}
type ComponentClassRemovedEvents = {[ComponentClass]: {[any]: any}}
type ComponentClassInitializedEvents = {[ComponentClass]: {[any]: any}}

local TestService = game:GetService("TestService")
local CollectionService = game:GetService("CollectionService")

local CheckYield = require(script:WaitForChild("CheckYield"))
local Cleaner = require(script.Parent.util:WaitForChild("Cleaner"))
local Signal = require(script.Parent.util:WaitForChild("Signal"))

local ERR_NO_INITIAL = "Component %s on %s does not contain an 'Initial' method"
local ERR_INIT_FAILED = "Component %s Initial call failed on %s\n%s\n"
local ERR_WAIT_TIMEOUT = "Component %s on %s with tag %s timed out"
local ERR_NO_TAG_GIVEN = "No tag given!"
local ERR_NO_OBJECT_GIVEN = "No object given!"
local ERR_NO_COMPONENT_LIST = "No component class list given!"
local ERR_OBJECT_NOT_INSTANCE = "Object was not an Instance!"
local ERR_EMPTY_COMPONENT_LIST = "Empty component class list given!"
local ERR_COMPONENT_NEW_YIELDED = "Component constructor %s yielded or threw an error on %s"
local ERR_COMPONENT_NOT_PRESENT = "Component %s not present on %s"
local ERR_ITEM_ALREADY_DESTROYED = "Already destroyed!"
local ERR_NO_COMPONENT_CLASS_GIVEN = "No component class given!"
local ERR_COMPONENT_ALREADY_PRESENT = "Component %s already present on %s"
local ERR_COMPONENT_DESTROY_YIELDED = "Component destructor %s yielded or threw an error on %s"
local ERR_COMPONENT_CLASS_NOT_TABLE = "ComponentClass was not an table!"
local ERR_TYPE_FIELD_INCORRECT_TYPE = "Type field in component should be a string"
local WARN_COMPONENT_LIFECYCLE_ALREDY_ENDED = "Component lifecycle ended before Initial call completed - %s on %s"

local WARN_MULTIPLE_REGISTER = "Register attempted to create duplicate component: %s\n\n%s"
local WARN_NO_DESTROY_METHOD = "No Destroy method found on component %s - make sure Destroy cleans up any potential connections to events"
local WARN_TAG_DESTROY_CREATE = "CollectionService reported a destroyed tag before it was created: %s"
local WARN_COMPONENT_NOT_FOUND = "Component not found: %s"
local WARN_COMPONENT_INFINITE_WAIT = "Potential infinite wait on (\n\tObject = '%s';\n\tComponent = '%s';\n)\n%s"

local DEFAULT_TIMEOUT = 10
local FORCE_RELEASE_REFS = true
local TIMEOUT_WARN_MULTIPLIER = 1/6
local WRAP_FUNCTIONS_WITH_MEMORY_TAGS = "Initial"

local _InstanceToComponents: InstanceToComponents = {}
local _ComponentClassToInstances: ComponentClassToInstances = {}
local _ComponentClassToComponents: ComponentClassToComponents = {}

local _ComponentClassAddedEvents: ComponentClassAddedEvents = {}
local _ComponentClassRemovedEvents: ComponentClassRemovedEvents = {}
local _ComponentClassInitializedEvents: ComponentClassInitializedEvents = {}

--[[--
    Rosyn is an extension of CollectionService.
    Components are composed over Instances and any Instance
    can have multiple components. Multiple components of
    the same class/type cannot exist concurrently on an
    Instance.
    @classmod Rosyn

    @todo Optional "GetRegistry" approach with generics per component class
    @todo Detect circular dependencies on AwaitComponentInit
    @todo Add generics to GetComponent functions & similar
]]
local Rosyn = {
    -- Associations between Instances, component classes, and component instances, to ensure immediate lookup

    --- Map of tagged Instances as keys with values of Array<ComponentClass>
    -- @usage InstanceToComponents = {Instance = {ComponentClass1 = ComponentInstance1, ComponentClass2 = ComponentInstance2, ...}, ...}
    InstanceToComponents = _InstanceToComponents;
    --- Map of ComponentClasses as keys with values of Array<Instance>
    -- @usage ComponentClassToInstances = {ComponentClass = {Instance1 = true, Instance2 = true, ...}, ...}
    ComponentClassToInstances = _ComponentClassToInstances;
    --- Map of Uninitialized Component Classes as keys with values of Array<individual Class Instances>
    -- @usage ComponentClassToComponents = {ComponentClass = {ComponentInstance1 = true, ComponentInstance2 = true, ...}, ...}
    ComponentClassToComponents = _ComponentClassToComponents;

    -- Events related to component classes

    --- Map of initialized Component Classes with values of Component Added Signals
    -- @usage ComponentClassAddedEvents = {ComponentClass1 = Event1, ...}
    ComponentClassAddedEvents = _ComponentClassAddedEvents;
    --- Map of initialized Component Classes with values of Component Removed Signals
    -- @usage ComponentClassRemovedEvents = {ComponentClass1 = Event1, ...}
    ComponentClassRemovedEvents = _ComponentClassRemovedEvents;
    --- Map of initialized Component Classes with values of Component Initialized Signals
    -- @usage ComponentClassInitializedEvents = {ComponentClass1 = Event1, ...}
    ComponentClassInitializedEvents = _ComponentClassInitializedEvents;
    --- Signal for failed Component Class initialization
    -- @usage ComponentClassInitializationFailed:Fire(ComponentClassName: string, Instance: Instance, Error: string)
    ComponentClassInitializationFailed = Signal.new();
};

--[[
    Attempts to get a unique ID from the component class or instance passed. A Type field in all component classes is the recommended approach.
    @param Component The component instance or class to obtain the name from.
]]
function Rosyn.GetComponentName(Component: ComponentInstance | ComponentClass): string
    -- Also works on component classes if you write things properly
    if (Component.Type) then
        assert(typeof(Component.Type) == "string", ERR_TYPE_FIELD_INCORRECT_TYPE)
    end

    return Component.Type or tostring(Component)
end


local GlobalRegisteredTable = {}
--[[--
    Registers component(s) to be automatically associated with instances with a certain tag.
    @param Tag The string of the CollectionService tag
    @param Components An array of ComponentClasses
    @param AncestorTarget The instance to look if any descendants added to it have the given Tag
]]
function Rosyn.Register(Tag: string, Components: {ComponentClass}, AncestorTarget: Instance?)
    assert(Tag, ERR_NO_TAG_GIVEN)
    assert(Components, ERR_NO_COMPONENT_LIST)
    assert(#Components > 0, ERR_EMPTY_COMPONENT_LIST)

    AncestorTarget = AncestorTarget or game

    -- We can wrap methods in memory tags to help diagnose memory leaks
    if (WRAP_FUNCTIONS_WITH_MEMORY_TAGS == "*") then
        for _, Component in ipairs(Components) do
            for Key, Value in pairs(Component) do
                if (type(Value) ~= "function") then
                    continue
                end

                local MemoryTag = Rosyn.GetComponentName(Component) .. ":" .. Key .. "(...)"

                Component[Key] = function(...)
                    debug.setmemorycategory(MemoryTag)
                    local Results = {Value(...)}
                    debug.resetmemorycategory()
                    return unpack(Results)
                end
            end
        end
    elseif (WRAP_FUNCTIONS_WITH_MEMORY_TAGS == "Initial") then
        for _, Component in ipairs(Components) do
            local MemoryTag = Rosyn.GetComponentName(Component) .. ":Initial()"
            local OldInitial = Component.Initial

            Component.Initial = function(self)
                debug.setmemorycategory(MemoryTag)
                OldInitial(self)
                debug.resetmemorycategory()
            end
        end
    end

    -- Wrap class using Cleaner for memory safety unless user specifies not to
    -- Verify classes have Destroy methods
    for _, Component in ipairs(Components) do
        if (Component.Destroy == nil) then
            warn(WARN_NO_DESTROY_METHOD:format(Rosyn.GetComponentName(Component)))
        end

        if (not Component._DO_NOT_WRAP and not Cleaner.IsWrapped(Component)) then
            Cleaner.Wrap(Component)
        end

        if (GlobalRegisteredTable[Component.__Tag] == nil) then
            GlobalRegisteredTable[Component.__Tag] = {}
        end
    end

    local Registered = {}
    local Trace = debug.traceback()

    local function HandleCreation(Item: Instance)
        if (Registered[Item]) then
            -- Sometimes GetTagged and GetInstanceAddedSignal can activate on the same frame, so debounce to prevent duplicate component warnings
            -- Thanks Roblox
            return
        end
        
        assert(Item.Parent ~= nil, ERR_ITEM_ALREADY_DESTROYED)
        
        if (not AncestorTarget:IsAncestorOf(Item)) then
            return
        end
        
        Registered[Item] = true
        
        for Index = 1, #Components do
            local ComponentClass = Components[Index]
            print(GlobalRegisteredTable)
            if table.find(GlobalRegisteredTable[ComponentClass.__Tag], Item) then
                continue
            else
                print(string.format("Binding %s to %s with parent %s", Components[1].__Tag, Item.Name, Item.Parent.Name))
                table.insert(GlobalRegisteredTable[ComponentClass.__Tag], Item)
            end

            if (Rosyn.GetComponent(Item, ComponentClass)) then
                warn(WARN_MULTIPLE_REGISTER:format(Rosyn.GetComponentName(ComponentClass), Trace))
                continue
            end

            Rosyn._AddComponent(Item, ComponentClass)
        end
    end

    -- Pick up existing tagged Instances
    for _, Item in pairs(CollectionService:GetTagged(Tag)) do
        task.spawn(HandleCreation, Item)
    end

    -- Creation
    CollectionService:GetInstanceAddedSignal(Tag):Connect(HandleCreation)

    -- Destruction
    CollectionService:GetInstanceRemovedSignal(Tag):Connect(function(Item)
        if (not AncestorTarget:IsAncestorOf(Item)) then
            return
        end

        Registered[Item] = nil

        local ComponentsForInstance = Rosyn.GetComponentsFromInstance(Item)

        if (ComponentsForInstance == nil or next(ComponentsForInstance) == nil) then
            warn(WARN_TAG_DESTROY_CREATE:format(Tag))
        end

        for Index = 1, #Components do
            local ComponentClass = Components[Index]

            if (not Rosyn.GetComponent(Item, ComponentClass)) then
                warn(WARN_COMPONENT_NOT_FOUND:format(Rosyn.GetComponentName(ComponentClass)))
                continue
            end

            Rosyn._RemoveComponent(Item, ComponentClass)
        end
    end)
end

--[[--
    Attempts to obtain a specific component from an Instance given a component class.
    @param Object The Instance to check for the passed ComponentClass
    @param ComponentClass The uninitialized ComponentClass to check for
    @return ComponentInstance or nil
]]
function Rosyn.GetComponent(Object: Instance, ComponentClass: ComponentClass): ComponentInstance
    assert(Object, ERR_NO_OBJECT_GIVEN)
    assert(typeof(Object) == "Instance", ERR_OBJECT_NOT_INSTANCE)

    assert(ComponentClass, ERR_NO_COMPONENT_CLASS_GIVEN)
    assert(type(ComponentClass) == "table", ERR_COMPONENT_CLASS_NOT_TABLE)

    local ComponentsForObject = Rosyn.InstanceToComponents[Object]
    return ComponentsForObject and ComponentsForObject[ComponentClass] or nil
end

--[[
    Waits for a component instance's construction on a given Instance and returns it. Throws errors for timeout and target Instance deparenting to prevent memory leaks.
    @todo Add exit code 3 -> component was removed from the Instance while waiting (can help user debug things better)
]]
function Rosyn.AwaitComponent(Object: Instance, ComponentClass: ComponentClass, Timeout: number?): ComponentInstance?
    assert(Object, ERR_NO_OBJECT_GIVEN)
    assert(typeof(Object) == "Instance", ERR_OBJECT_NOT_INSTANCE)

    assert(ComponentClass, ERR_NO_COMPONENT_CLASS_GIVEN)
    assert(type(ComponentClass) == "table", ERR_COMPONENT_CLASS_NOT_TABLE)

    -- Best case - it's created already
    local Got = Rosyn.GetComponent(Object, ComponentClass)

    if (Got) then
        return Got
    end

    -- Alternate case - wait for construction or timeout or deparenting
    Timeout = Timeout or DEFAULT_TIMEOUT

    local Proxy = Signal.new()
    local Trace = debug.traceback()
    local ComponentName = Rosyn.GetComponentName(ComponentClass)

    local AddedConnection; AddedConnection = Rosyn._GetAddedEvent(ComponentClass):Connect(function(TargetInstance: Instance)
        if (TargetInstance ~= Object) then
            return
        end

        Proxy:Fire(1)
    end)

    local Result

    task.delay(Timeout * TIMEOUT_WARN_MULTIPLIER, function()
        if (not Result) then
            warn(WARN_COMPONENT_INFINITE_WAIT:format(Object:GetFullName(), ComponentName, Trace))
        end
    end)

    task.delay(Timeout, function()
        if (not Result) then
            Proxy:Fire(2)
        end
    end)

    Result = Proxy:Wait()
    AddedConnection:Disconnect()

    assert(Result == 1,
            Result == 2 and ERR_WAIT_TIMEOUT:format(ComponentName, Object:GetFullName(), ComponentClass.__Tag))

    return Rosyn.GetComponent(Object, ComponentClass)
end

--[[
    Waits for a component instance's asynchronous Initial method to complete and returns it. Throws errors for timeout and target Instance deparenting to prevent memory leaks.
    @todo Re-work to get rid of the _INITIALIZED field approach and use key associations in another table
    @todo Add exit code 3 -> component was removed from the Instance while waiting (can help user debug things better)
]]
function Rosyn.AwaitComponentInit(Object: Instance, ComponentClass: ComponentClass, Timeout: number?): ComponentInstance?
    assert(Object, ERR_NO_OBJECT_GIVEN)
    assert(typeof(Object) == "Instance", ERR_OBJECT_NOT_INSTANCE)

    assert(ComponentClass, ERR_NO_COMPONENT_CLASS_GIVEN)
    assert(type(ComponentClass) == "table", ERR_COMPONENT_CLASS_NOT_TABLE)

    -- Best case - it's registered AND initialized already
    local Got = Rosyn.GetComponent(Object, ComponentClass)

    if (Got and Got._INITIALIZED) then
        return Got
    end

    -- Alternate case - wait for init or timeout or deparenting
    Timeout = Timeout or DEFAULT_TIMEOUT

    local Trace = debug.traceback()
    local Proxy = Signal.new()
    local ComponentName = Rosyn.GetComponentName(ComponentClass)

    local InitializedConnection; InitializedConnection = Rosyn._GetInitializedEvent(ComponentClass):Connect(function(TargetInstance: Instance)
        if (TargetInstance ~= Object) then
            return
        end

        Proxy:Fire(1)
    end)

    local Result

    task.delay(Timeout * TIMEOUT_WARN_MULTIPLIER, function()
        if (not Result) then
            warn(WARN_COMPONENT_INFINITE_WAIT:format(Object:GetFullName(), ComponentName, Trace))
        end
    end)

    task.delay(Timeout, function()
        if (not Result) then
            Proxy:Fire(2)
        end
    end)

    Result = Proxy:Wait()
    InitializedConnection:Disconnect()

    assert(Result == 1,
            Result == 2 and ERR_WAIT_TIMEOUT:format(ComponentName, Object:GetFullName(), ComponentClass.__Tag))

    return Rosyn.GetComponent(Object, ComponentClass)
end

--[[
    Obtains a component instance from an Instance or any of its ascendants.
]]
function Rosyn.GetComponentFromDescendant(Object: Instance, ComponentClass: ComponentClass): ComponentInstance?
    assert(Object, ERR_NO_OBJECT_GIVEN)

    assert(ComponentClass, ERR_NO_COMPONENT_CLASS_GIVEN)
    assert(type(ComponentClass) == "table", ERR_COMPONENT_CLASS_NOT_TABLE)

    while (Object.Parent) do
        local Component = Rosyn.GetComponent(Object, ComponentClass)

        if (Component) then
            return Component
        end

        Object = Object.Parent
    end

    return nil
end

--[[--
    Obtains Map of all Instances for which there exists a given component class on.
    @todo Think of an efficient way to prevent external writes to the returned table.
]]
function Rosyn.GetInstancesOfClass(ComponentClass: ComponentClass): {[Instance]: boolean}
    assert(ComponentClass, ERR_NO_COMPONENT_CLASS_GIVEN)
    assert(type(ComponentClass) == "table", ERR_COMPONENT_CLASS_NOT_TABLE)

    return Rosyn.ComponentClassToInstances[ComponentClass] or {}
end

--[[--
    Obtains Map of all components of a particular class.
    @todo Think of an efficient way to prevent external writes to the returned table.
]]
function Rosyn.GetComponentsOfClass(ComponentClass: ComponentClass): {[ComponentInstance]: boolean}
    assert(ComponentClass, ERR_NO_COMPONENT_CLASS_GIVEN)
    assert(type(ComponentClass) == "table", ERR_COMPONENT_CLASS_NOT_TABLE)

    return Rosyn.ComponentClassToComponents[ComponentClass] or {}
end

--[[--
    Obtains all components of any class which are associated to a specific Instance.
    @todo Think of an efficient way to prevent external writes to the returned table.
]]
function Rosyn.GetComponentsFromInstance(Object: Instance): {[ComponentClass]: ComponentInstance}
    assert(Object, ERR_NO_OBJECT_GIVEN)
    assert(typeof(Object) == "Instance", ERR_OBJECT_NOT_INSTANCE)

    return Rosyn.InstanceToComponents[Object] or {}
end

------------------------------------------- Internal -------------------------------------------

--[[--
    Creates and wraps a component around an Instance, given a component class.
    @usage Private Method
]]
function Rosyn._AddComponent(Object: Instance, ComponentClass: ComponentClass)
    assert(Object, ERR_NO_OBJECT_GIVEN)
    assert(typeof(Object) == "Instance", ERR_OBJECT_NOT_INSTANCE)

    assert(ComponentClass, ERR_NO_COMPONENT_CLASS_GIVEN)
    assert(type(ComponentClass) == "table", ERR_COMPONENT_CLASS_NOT_TABLE)

    local ComponentName = Rosyn.GetComponentName(ComponentClass)
    local DiagnosisTag = "Component." .. ComponentName
    assert(Rosyn.GetComponent(Object, ComponentClass) == nil, ERR_COMPONENT_ALREADY_PRESENT:format(ComponentName, Object:GetFullName()))

    debug.profilebegin(DiagnosisTag)
        ---------------------------------------------------------------------------------------------------------
        local Yielded, NewComponent = CheckYield(function()
            return ComponentClass.new(Object)
        end)
        assert(not Yielded, ERR_COMPONENT_NEW_YIELDED:format(ComponentName, Object:GetFullName()))

        local InstanceToComponents = Rosyn.InstanceToComponents
        local ComponentClassToInstances = Rosyn.ComponentClassToInstances
        local ComponentClassToComponents = Rosyn.ComponentClassToComponents

        -- InstanceToComponents = {Instance = {ComponentClass1 = ComponentInstance1, ComponentClass2 = ComponentInstance2, ...}, ...}
        local ExistingComponentsForInstance = InstanceToComponents[Object]

        if (not ExistingComponentsForInstance) then
            ExistingComponentsForInstance = {}
            InstanceToComponents[Object] = ExistingComponentsForInstance
        end

        ExistingComponentsForInstance[ComponentClass] = NewComponent

        -- ComponentClassToInstances = {ComponentClass = {Instance1 = true, Instance2 = true, ...}, ...}
        local ExistingInstancesForComponentClass = ComponentClassToInstances[ComponentClass]

        if (not ExistingInstancesForComponentClass) then
            ExistingInstancesForComponentClass = {}
            ComponentClassToInstances[ComponentClass] = ExistingInstancesForComponentClass
        end

        ExistingInstancesForComponentClass[Object] = true

        -- ComponentClassToComponents = {ComponentClass = {ComponentInstance1 = true, ComponentInstance2 = true, ...}, ...}
        local ExistingComponentsForComponentClass = ComponentClassToComponents[ComponentClass]

        if (not ExistingComponentsForComponentClass) then
            ExistingComponentsForComponentClass = {}
            ComponentClassToComponents[ComponentClass] = ExistingComponentsForComponentClass
        end

        ExistingComponentsForComponentClass[NewComponent] = true
        ---------------------------------------------------------------------------------------------------------
    debug.profileend()

    Rosyn._GetAddedEvent(ComponentClass):Fire(Object)

    -- Initialise component in separate coroutine
    task.spawn(function()
        -- We can't use microprofiler tags because Initial is allowed to yield.
        -- Monitor for memory issues instead, because Initial is likely to contain various event connections.
        assert(NewComponent.Initial, ERR_NO_INITIAL:format(ComponentName, Object:GetFullName()))

        local Success, Result = pcall(function()
            NewComponent:Initial()
        end)

        if (table.isfrozen(NewComponent)) then
            warn(WARN_COMPONENT_LIFECYCLE_ALREDY_ENDED:format(ComponentName, Object:GetFullName()))
            return
        end

        NewComponent._INITIALIZED = true
        Rosyn._GetInitializedEvent(ComponentClass):Fire(Object)

        if (not Success) then
            Rosyn.ComponentClassInitializationFailed:Fire(ComponentName, Object, Result)
            TestService:Error(ERR_INIT_FAILED:format(ComponentName, Object:GetFullName(), Result))
        end
        -- TODO: maybe we pcall and timeout the Initial and ensure Destroy is always called after
        -- Otherwise we have to use the "retroactive" cleaner pattern
    end)
end

--[[--
    Removes a component from an Instance, given a component class. Calls Destroy on component.
    @usage Private Method
]]
function Rosyn._RemoveComponent(Object: Instance, ComponentClass: ComponentClass)
    assert(Object, ERR_NO_OBJECT_GIVEN)
    assert(typeof(Object) == "Instance", ERR_OBJECT_NOT_INSTANCE)

    assert(ComponentClass, ERR_NO_COMPONENT_CLASS_GIVEN)
    assert(type(ComponentClass) == "table", ERR_COMPONENT_CLASS_NOT_TABLE)

    local ComponentName = Rosyn.GetComponentName(ComponentClass)
    local DiagnosisTag = "Component." .. ComponentName
    local ExistingComponent = Rosyn.GetComponent(Object, ComponentClass)
    assert(ExistingComponent, ERR_COMPONENT_NOT_PRESENT:format(ComponentName, Object:GetFullName()))

    debug.profilebegin(DiagnosisTag)
        ---------------------------------------------------------------------------------------------------------
        local InstanceToComponents = Rosyn.InstanceToComponents
        local ComponentClassToInstances = Rosyn.ComponentClassToInstances
        local ComponentClassToComponents = Rosyn.ComponentClassToComponents

        -- InstanceToComponents = {Instance = {ComponentClass1 = ComponentInstance1, ComponentClass2 = ComponentInstance2, ...}, ...}
        local ExistingComponentsForInstance = InstanceToComponents[Object]

        if (not ExistingComponentsForInstance) then
            ExistingComponentsForInstance = {}
            InstanceToComponents[Object] = ExistingComponentsForInstance
        end

        ExistingComponentsForInstance[ComponentClass] = nil

        if (next(ExistingComponentsForInstance) == nil) then
            InstanceToComponents[Object] = nil
        end

        -- ComponentClassToInstances = {ComponentClass = {Instance1 = true, Instance2 = true, ...}, ...}
        local ExistingInstancesForComponentClass = ComponentClassToInstances[ComponentClass]
        ExistingInstancesForComponentClass[Object] = nil

        if (next(ExistingInstancesForComponentClass) == nil) then
            ComponentClassToInstances[ComponentClass] = nil
        end

        -- ComponentClassToComponents = {ComponentClass = {ComponentInstance1 = true, ComponentInstance2 = true, ...}, ...}
        local ExistingComponentsForComponentClass = ComponentClassToComponents[ComponentClass]
        ExistingComponentsForComponentClass[ExistingComponent] = nil

        if (next(ExistingComponentsForComponentClass) == nil) then
            ComponentClassToComponents[ComponentClass] = nil
        end
        ---------------------------------------------------------------------------------------------------------
    debug.profileend()

    Rosyn._GetRemovedEvent(ComponentClass):Fire(Object)

    -- Destroy component to let it clean stuff up
    debug.profilebegin(DiagnosisTag .. ".Destroy")

    if (ExistingComponent.Destroy) then
        local Yielded = CheckYield(function()
            ExistingComponent:Destroy()
        end)
        assert(not Yielded, ERR_COMPONENT_DESTROY_YIELDED:format(ComponentName, Object:GetFullName()))
    end

    debug.profileend()
end

--[[
    Obtains or creates a Signal which will fire when a component has been instantiated.
    @todo Refactor these 3 since they have a lot of repeated code
    @usage Private Method
]]
function Rosyn._GetAddedEvent(ComponentClass)
    assert(ComponentClass, ERR_NO_COMPONENT_CLASS_GIVEN)
    assert(type(ComponentClass) == "table", ERR_COMPONENT_CLASS_NOT_TABLE)

    local ComponentClassAddedEvents = Rosyn.ComponentClassAddedEvents
    local AddedEvent = ComponentClassAddedEvents[ComponentClass]

    if (not AddedEvent) then
        AddedEvent = Signal.new()
        ComponentClassAddedEvents[ComponentClass] = AddedEvent
    end

    return AddedEvent
end

--[[--
    Obtains or creates a Signal which will fire when a component has been destroyed.
    @usage Private Method
]]
function Rosyn._GetRemovedEvent(ComponentClass: ComponentClass)
    assert(ComponentClass, ERR_NO_COMPONENT_CLASS_GIVEN)
    assert(type(ComponentClass) == "table", ERR_COMPONENT_CLASS_NOT_TABLE)

    local ComponentClassRemovedEvents = Rosyn.ComponentClassRemovedEvents
    local RemovedEvent = ComponentClassRemovedEvents[ComponentClass]

    if (not RemovedEvent) then
        RemovedEvent = Signal.new()
        ComponentClassRemovedEvents[ComponentClass] = RemovedEvent
    end

    return RemovedEvent
end

--[[--
    Obtains or creates a Signal which will fire when a component has passed its initialization phase.
    @usage Private Method
]]
function Rosyn._GetInitializedEvent(ComponentClass: ComponentClass)
    assert(ComponentClass, ERR_NO_COMPONENT_CLASS_GIVEN)
    assert(type(ComponentClass) == "table", ERR_COMPONENT_CLASS_NOT_TABLE)

    local ComponentClassInitializedEvents = Rosyn.ComponentClassInitializedEvents
    local InitializedEvent = ComponentClassInitializedEvents[ComponentClass]

    if (not InitializedEvent) then
        InitializedEvent = Signal.new()
        ComponentClassInitializedEvents[ComponentClass] = InitializedEvent
    end

    return InitializedEvent
end

--[[--
    Condition which should be true at all times. For test writing. Ensures component counts for all registered components are equivalent in all associations.
    @usage Private Method
]]
function Rosyn._Invariant()
    local Counts = {}

    for Item in pairs(Rosyn.InstanceToComponents) do
        local Components = Rosyn.GetComponentsFromInstance(Item)

        if (not Components) then
            continue
        end

        for _, Component in pairs(Components) do
            Component = Component._COMPONENT_REF
            Counts[tostring(Component)] = (Counts[tostring(Component)] or 0) + 1
        end
    end

    -- Ensure it matches
    local OtherCounts = {}

    for ComponentClass, Instances in pairs(Rosyn.ComponentClassToComponents) do
        for _ in pairs(Instances) do
            OtherCounts[tostring(ComponentClass)] = (OtherCounts[tostring(ComponentClass)] or 0) + 1
        end
    end

    for Key, Value in pairs(OtherCounts) do
        local SameObjectCount = Counts[Key]

        if (SameObjectCount) then
            if (SameObjectCount ~= Value) then
                return false
            end
        end
    end

    return true
end

--- Provides backwards compatibility, deprecated in favor of AwaitComponent
-- @usage DEPRECATED
-- @function WaitForComponent
Rosyn.WaitForComponent = Rosyn.AwaitComponent -- Backward compatibility

return Rosyn