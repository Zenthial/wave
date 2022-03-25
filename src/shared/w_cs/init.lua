local CollectionService = game:GetService("CollectionService")

local Signal = require(script.Signal)
local Trove = require(script.Trove)

local COMPONENT_START_TIMEOUT = 5

type ComponentInstance = {
    __Initialized: boolean,
    __InitializedSignal: typeof(Signal),

    Name: string,
    Tag: string,

    CreateDependencies: () -> {[string]: Instance},
    Start: () -> (),
    Destroy: () -> (),
}

type ComponentClass = {
    Name: string,
    Tag: string,
    Needs: {string},
    
    new: (Instance) -> ComponentInstance,
    CreateDependencies: () -> {[string]: Instance},
    Start: () -> (),
    Destroy: () -> (),
}

local instances_on_components: {[Instance]: {[ComponentClass]: ComponentInstance}} = {}
local component_names_on_components: {[string]: ComponentClass}

local function _create_signal()
    return Instance.new("BindableEvent")
end

local function _get_instance_components(instance: Instance, component: ComponentClass)
    return instances_on_components[instance] and instances_on_components[instance][component] or nil
end

local function get_component(instance: Instance, component_name: string): ComponentInstance
    local component_class = component_names_on_components[component_name]
    for _, component_instance in ipairs(_get_instance_components(instance, component_class)) do
        if component_instance.Name == component_class.Name then
            if component_instance.__Initialized == true then
                return component_instance
            else
                local proxy = Signal.new()
                local initialized = false
                local initialized_connection = component_instance.__InitializedSignal:Connect(function()
                    initialized = true
                    proxy:Fire(0)
                end)

                task.delay(COMPONENT_START_TIMEOUT, function()
                    if initialized == false then
                        proxy:Fire(1)
                    end
                end)

                local result = proxy:Wait()
                initialized_connection:Destroy()

                if result == 0 then
                    return component_instance
                elseif result == 1 then
                    error("Initialization failed on " .. component_instance.Name)
                end
            end
        end
    end

    return nil
end

local function _create(instance: Instance, component: ComponentClass)
    if instances_on_components[instance] == nil then
        instances_on_components[instance] = {}
    end

    if instances_on_components[instance][component] == nil then
        instances_on_components[instance][component] = {}
    end

    local component_instance = component.new(instance) :: ComponentClass
    local initialized_signal = _create_signal()
    table.insert(instances_on_components[instance][component], component_instance)
    task.spawn(function()
        component_instance.__Initialized = false
        component_instance.__InitializedSignal = initialized_signal

        for componentName, componentRoot in pairs(component_instance:CreateDependencies()) do
            component_instance[componentName] = get_component(componentRoot, componentName)
        end

        for _, need in pairs(component_instance.Needs) do
            if need == "Cleaner" then
                component_instance.Cleaner = Trove.new()
            end
        end

        component_instance:Start()
        component_instance.__Initialized = true
        initialized_signal:Fire()
    end)

    return component_instance
end

local function _destroy(component: ComponentInstance)
    component:Destroy()
end

local function create_component(component: ComponentClass, ancestor: Instance?)
    assert(component.Tag ~= nil, "Missing Tag property on " .. component)
    assert(component.Name ~= nil, "Missing Name property on " .. component .. " with tag " .. component.Tag)
    assert(component.new ~= nil, "Missing constructor on " .. component.Name)
    assert(component.Initial ~= nil, "Missing initial function on " .. component.Name)
    assert(component.Destroy ~= nil, "Missing destructor function on " .. component.Name)

    if ancestor == nil then
        ancestor = game
    end

    component_names_on_components[component.Name] = component

    for _, thing in ipairs(CollectionService:GetTagged(component.Tag)) do
        _create(thing, component)
    end

    task.wait()

    CollectionService:GetInstanceAddedSignal(component.Tag):Connect(function(instance)
        _create(instance, component)
    end)

    CollectionService:GetInstanceRemovedSignal(component.Tag):Connect(function(instance)
        for _, component_instance in ipairs(_get_instance_components(instance, component)) do
            if component_instance.Name == component.Name then
                _destroy(component_instance)
            end
        end
    end)
end

return {
    create_component,
    get_component
}