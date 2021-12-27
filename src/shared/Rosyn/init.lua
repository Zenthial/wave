--!nonstrict
type ComponentInstance = any
type ComponentClass = {
    Type: string?,

    new: (Instance) -> ComponentInstance,
    Initial: () -> (),
    Destroy: () -> (),
}

type InstanceToComponents = {[Instance]: {[ComponentClass]: ComponentInstance}}
type ComponentClassToInstances = {[ComponentClass]: {[Instance]: boolean}}
type ComponentClassToComponents = {[ComponentClass]: {[ComponentInstance]: boolean}}

type ComponentClassAddedEvents = {[ComponentClass]: BindableEvent}
type ComponentClassRemovedEvents = {[ComponentClass]: BindableEvent}
type ComponentClassInitializedEvents = {[ComponentClass]: BindableEvent}

local TestService = game:GetService("TestService")
local CollectionService = game:GetService("CollectionService")

local CheckYield = require(script:WaitForChild("CheckYield"))

local ERR_NO_INITIAL = "Component %s on %s does not contain an 'Initial' method"
local ERR_INIT_FAILED = "Component %s Initial call failed on %s\n%s\n"
local ERR_WAIT_TIMEOUT = "Component %s on %s timed out"
local ERR_NO_TAG_GIVEN = "No tag given!"
local ERR_NO_OBJECT_GIVEN = "No object given!"
local ERR_NO_COMPONENT_LIST = "No component class list given!"
local ERR_EMPTY_COMPONENT_LIST = "Empty component class list given!"
local ERR_COMPONENT_NEW_YIELDED = "Component constructor %s yielded on %s"
local ERR_COMPONENT_NOT_PRESENT = "Component %s not present on %s"
local ERR_ITEM_ALREADY_DESTROYED = "Already destroyed!"
local ERR_NO_COMPONENT_CLASS_GIVEN = "No component class given!"
local ERR_COMPONENT_ALREADY_PRESENT = "Component %s already present on %s"

local WARN_MULTIPLE_REGISTER = "Register attempted to create duplicate component: %s\n\n%s"
local WARN_TAG_DESTROY_CREATE = "CollectionService reported a destroyed tag before it was created: %s"
local WARN_COMPONENT_NOT_FOUND = "Component not found: %s"
local WARN_COMPONENT_INFINITE_WAIT = "Potential infinite wait on (\n\tObject = '%s';\n\tComponent = '%s';\n)\n%s"

local DEFAULT_TIMEOUT = 60
local TIMEOUT_WARN_MULTIPLIER = 1/6

local _InstanceToComponents: InstanceToComponents = {}
local _ComponentClassToInstances: ComponentClassToInstances = {}
local _ComponentClassToComponents: ComponentClassToComponents = {}

local _ComponentClassAddedEvents: ComponentClassAddedEvents = {}
local _ComponentClassRemovedEvents: ComponentClassRemovedEvents = {}
local _ComponentClassInitializedEvents: ComponentClassInitializedEvents = {}

--[[
    Rosyn is an Instance-Lua object connector, and an extension
    of CollectionService. "Components" are composed over Instances
    and any Instance can have multiple components of different
    types.

    @todo Optional "GetRegistry" approach with generics per component class
    @todo Detect circular dependencies on AwaitComponentInit
    @todo Add generics to GetComponent functions & similar
]]
local Rosyn = {
    -- Associations between Instances, component classes, and component instances, to ensure immediate lookup
    InstanceToComponents = _InstanceToComponents; -- InstanceToComponents = {Instance = {ComponentClass1 = ComponentInstance1, ComponentClass2 = ComponentInstance2, ...}, ...}
    ComponentClassToInstances = _ComponentClassToInstances; -- ComponentClassToInstances = {ComponentClass1 = {Instance1 = true, Instance2 = true, ...}, ...}
    ComponentClassToComponents = _ComponentClassToComponents; -- ComponentClassToComponents = {ComponentClass1 = {ComponentInstance1 = true, ComponentInstance2 = true, ...}, ...}

    -- Events related to component classes
    ComponentClassAddedEvents = _ComponentClassAddedEvents; -- ComponentClassAddedEvents = {ComponentClass1 = Event1, ...}
    ComponentClassRemovedEvents = _ComponentClassRemovedEvents; -- ComponentClassRemovedEvents = {ComponentClass1 = Event1, ...}
    ComponentClassInitializedEvents = _ComponentClassInitializedEvents; -- ComponentClassInitializedEvents = {ComponentClass1 = Event1, ...}
};

--[[
    @function GetComponentName

    Attempts to get a unique ID from the component
    class or instance passed. A Type field in all
    component classes is the recommended approach.
]]
function Rosyn.GetComponentName(Component: ComponentInstance | ComponentClass): string
    assert(Component, "No component instance given!")

    return Component.Type or tostring(Component)
end

--[[
    @function Register

    Registers component(s) to be automatically associated
    with instances with a certain tag.
]]
function Rosyn.Register(Tag: string, Components: {ComponentClass}, AncestorTarget: Instance?)
    assert(Tag, ERR_NO_TAG_GIVEN)
    assert(Components, ERR_NO_COMPONENT_LIST)
    assert(#Components > 0, ERR_EMPTY_COMPONENT_LIST)

    AncestorTarget = AncestorTarget or game

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

--[[
    @function GetComponent

    Attempts to obtain a specific component from an Instance given
    a component class.
]]
function Rosyn.GetComponent(Object: Instance, ComponentClass: ComponentClass): ComponentInstance
    assert(Object, ERR_NO_OBJECT_GIVEN)
    assert(ComponentClass, ERR_NO_COMPONENT_CLASS_GIVEN)

    local ComponentsForObject = Rosyn.InstanceToComponents[Object]
    return ComponentsForObject and ComponentsForObject[ComponentClass] or nil
end

--[[
    @function AwaitComponent
    @todo Add exit code 3 -> component was removed from the Instance while waiting (can help user debug things better)

    Waits for a component instance's construction on a
    given Instance and returns it. Throws errors for
    timeout and target  Instance deparenting to prevent
    memory leaks.
]]
function Rosyn.AwaitComponent(Object: Instance, ComponentClass: ComponentClass, Timeout: number?): ComponentInstance?
    assert(Object, ERR_NO_OBJECT_GIVEN)
    assert(ComponentClass, ERR_NO_COMPONENT_CLASS_GIVEN)

    -- Best case - it's created already
    local Got = Rosyn.GetComponent(Object, ComponentClass)

    if (Got) then
        return Got
    end

    -- Alternate case - wait for construction or timeout or deparenting
    Timeout = Timeout or DEFAULT_TIMEOUT

    local Trace = debug.traceback()
    local Proxy = Instance.new("BindableEvent")
    local ComponentName = Rosyn.GetComponentName(ComponentClass)

    local AddedConnection; AddedConnection = Rosyn._GetAddedEvent(ComponentClass).Event:Connect(function(TargetInstance: Instance)
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

    Result = Proxy.Event:Wait()
    AddedConnection:Disconnect()

    assert(Result == 1,
            Result == 2 and ERR_WAIT_TIMEOUT:format(ComponentName, Object:GetFullName()))

    return Rosyn.GetComponent(Object, ComponentClass)
end

--[[
    @function AwaitComponentInit
    @todo Re-work to get rid of the _INITIALIZED field approach and use key associations in another table
    @todo Add exit code 3 -> component was removed from the Instance while waiting (can help user debug things better)

    Waits for a component instance's asynchronous
    Initial method to complete and returns it.
    Throws errors for timeout and target Instance
    deparenting to prevent memory leaks.
]]
function Rosyn.AwaitComponentInit(Object: Instance, ComponentClass: ComponentClass, Timeout: number?): ComponentInstance?
    assert(Object, ERR_NO_OBJECT_GIVEN)
    assert(ComponentClass, ERR_NO_COMPONENT_CLASS_GIVEN)

    -- Best case - it's registered AND initialized already
    local Got = Rosyn.GetComponent(Object, ComponentClass)

    if (Got and Got._INITIALIZED) then
        return Got
    end

    -- Alternate case - wait for init or timeout or deparenting
    Timeout = Timeout or DEFAULT_TIMEOUT

    local Trace = debug.traceback()
    local Proxy = Instance.new("BindableEvent")
    local ComponentName = Rosyn.GetComponentName(ComponentClass)

    local InitializedConnection; InitializedConnection = Rosyn._GetInitializedEvent(ComponentClass).Event:Connect(function(TargetInstance: Instance)
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

    Result = Proxy.Event:Wait()
    InitializedConnection:Disconnect()

    assert(Result == 1,
            Result == 2 and ERR_WAIT_TIMEOUT:format(ComponentName, Object:GetFullName()))

    return Rosyn.GetComponent(Object, ComponentClass)
end

--[[
    @function GetComponentFromDescendant

    Obtains a component instance from an Instance or any
    of its ascendants.
]]
function Rosyn.GetComponentFromDescendant(Object: Instance, ComponentClass: ComponentClass): ComponentInstance?
    assert(Object, ERR_NO_OBJECT_GIVEN)
    assert(ComponentClass, ERR_NO_COMPONENT_CLASS_GIVEN)

    while (Object.Parent) do
        local Component = Rosyn.GetComponent(Object, ComponentClass)

        if (Component) then
            return Component
        end

        Object = Object.Parent
    end

    return nil
end

--[[
    @function GetInstancesOfClass
    @todo Think of an efficient way to prevent external writes to the returned table.

    Obtains a map of all Instances for which there
    exists a given component class on.
]]
function Rosyn.GetInstancesOfClass(ComponentClass: ComponentClass): {[Instance]: boolean}
    assert(ComponentClass, ERR_NO_COMPONENT_CLASS_GIVEN)

    return Rosyn.ComponentClassToInstances[ComponentClass] or {}
end

--[[
    @function GetComponentsOfClass
    @todo Think of an efficient way to prevent external writes to the returned table.

    Obtains a map of all components of a particular class.
]]
function Rosyn.GetComponentsOfClass(ComponentClass: ComponentClass): {[ComponentInstance]: boolean}
    assert(ComponentClass, ERR_NO_COMPONENT_CLASS_GIVEN)

    return Rosyn.ComponentClassToComponents[ComponentClass] or {}
end

--[[
    @function GetComponentsFromInstance
    @todo Think of an efficient way to prevent external writes to the returned table.

    Obtains all components of any class which are
    associated to a specific Instance.
]]
function Rosyn.GetComponentsFromInstance(Object: Instance): {[ComponentClass]: ComponentInstance}
    assert(Object, ERR_NO_OBJECT_GIVEN)

    return Rosyn.InstanceToComponents[Object] or {}
end

------------------------------------------- Internal -------------------------------------------

--[[
    @function _AddComponent

    Creates and wraps a component around an Instance, given
    a component class.
]]
function Rosyn._AddComponent(Object: Instance, ComponentClass: ComponentClass)
    assert(Object, ERR_NO_OBJECT_GIVEN)
    assert(typeof(Object) == "Instance", "Object was not an Instance!")

    assert(ComponentClass, "No ComponentClass given!")
    assert(type(ComponentClass) == "table", "ComponentClass was not an table!")

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
        debug.setmemorycategory(DiagnosisTag)

        local Success, Result = pcall(function()
            NewComponent:Initial()
        end)

        NewComponent._INITIALIZED = true
        Rosyn._GetInitializedEvent(ComponentClass):Fire(Object)

        if (not Success) then
            TestService:Error(ERR_INIT_FAILED:format(ComponentName, Object:GetFullName(), Result))
        end
        -- TODO: maybe we pcall and timeout the Initial and ensure Destroy is always called after
        -- Otherwise we have to use the "retroactive" cleaner pattern
    end)
end

--[[
    @function _RemoveComponent

    Removes a component from an Instance, given a component
    class. Calls Destroy on component.
]]
function Rosyn._RemoveComponent(Object: Instance, ComponentClass: ComponentClass)
    assert(Object, ERR_NO_OBJECT_GIVEN)
    assert(typeof(Object) == "Instance", "Object was not an Instance!")

    assert(ComponentClass, "No ComponentClass given!")
    assert(type(ComponentClass) == "table", "ComponentClass was not an table!")

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
        CheckYield(function()
            ExistingComponent:Destroy()
        end)
    end

    debug.profileend()
end

--[[
    @function _GetAddedEvent

    Obtains or creates a BindableEvent which will
    fire when a component has been instantiated.
]]
function Rosyn._GetAddedEvent(ComponentClass)
    local ComponentClassAddedEvents = Rosyn.ComponentClassAddedEvents
    local AddedEvent: BindableEvent = ComponentClassAddedEvents[ComponentClass]

    if (not AddedEvent) then
        AddedEvent = Instance.new("BindableEvent")
        ComponentClassAddedEvents[ComponentClass] = AddedEvent
    end

    return AddedEvent
end

--[[
    @function _GetRemovedEvent

    Obtains or creates a BindableEvent which will
    fire when a component has been destroyed.
]]
function Rosyn._GetRemovedEvent(ComponentClass: ComponentClass): BindableEvent
    local ComponentClassRemovedEvents = Rosyn.ComponentClassRemovedEvents
    local RemovedEvent: BindableEvent = ComponentClassRemovedEvents[ComponentClass]

    if (not RemovedEvent) then
        RemovedEvent = Instance.new("BindableEvent")
        ComponentClassRemovedEvents[ComponentClass] = RemovedEvent
    end

    return RemovedEvent
end

--[[
    @function _GetInitializedEvent

    Obtains or creates a BindableEvent which will
    fire when a component has passed its
    initialization phase.
]]
function Rosyn._GetInitializedEvent(ComponentClass: ComponentClass): BindableEvent
    local ComponentClassInitializedEvents = Rosyn.ComponentClassInitializedEvents
    local InitializedEvent: BindableEvent = ComponentClassInitializedEvents[ComponentClass]

    if (not InitializedEvent) then
        InitializedEvent = Instance.new("BindableEvent")
        ComponentClassInitializedEvents[ComponentClass] = InitializedEvent
    end

    return InitializedEvent
end

--[[
    @function _Invariant

    Condition which should be true at all times.
    For test writing. Ensures component counts
    for all registered components are equivalent
    in all associations.
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

Rosyn.WaitForComponent = Rosyn.AwaitComponent -- Backward compatibility

return Rosyn