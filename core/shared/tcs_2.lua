local CollectionService = game:GetService("CollectionService")

local TIMEOUT = 8
local DEBUG_PRINT = false
local DEBUG_WARN = true
local INJECT_FUNCTION = function(component_instance) end

export type ComponentInstance = {
	__Initialized: boolean,

	Name: string,
	Tag: string,

	Start: (ComponentClass) -> (),
	Destroy: (ComponentClass) -> (),
}

export type ComponentClass = {
	Name: string, -- The name of the component
	Tag: string, -- The tag that collection service should bind to
	Ancestor: Instance?,

	new: (Instance) -> ComponentInstance, -- constructor

    __Instances: {[Instance]: ComponentInstance}
}

local component_map: {[string]: ComponentClass} = {}

local tcs = {}

function tcs._wait_for_class(component_name: string)
    local class = component_map[component_name:lower()]
  
    local start = tick()
    while class == nil do
        class = component_map[component_name:lower()]

        if tick() - start > TIMEOUT then
            error("POTENTIAL INFINITE TIMEOUT FOR COMPONENT "..component_name .. "! Did you pass the wrong component name?")
        end 
        task.wait()
    end

    return class
end

function tcs._wait_for_instance(instance: Instance, component_name: string, component_instance: ComponentInstance)
	local start = tick()
	while component_instance == nil do
		component_instance = tcs.get_component(instance, component_name)

		if tick() - start > TIMEOUT then
			return nil
		end 
        task.wait()
	end

	return component_instance
end

function tcs.has_component(instance: Instance, component_name: string)
	if instance == nil then error("instance is nil") end
    local class = component_map[component_name:lower()]
	if class == nil then
		return false
	end
	
    local component_instance = class.__Instances[instance]
	
    return component_instance ~= nil
end

function tcs.get_component(instance: Instance, component_name: string)
	if instance == nil then error("instance is nil") end
    local class = component_map[component_name:lower()]
	if class == nil then
		if DEBUG_PRINT then print("waiting for class "..component_name) end
		class = tcs._wait_for_class(component_name)
		if DEBUG_PRINT then print("got "..component_name) end
	end
    assert(class, "No component class named "..component_name)
	
    local component_instance = class.__Instances[instance]
    -- assert(component_instance, "No component instance for instance "..instance.Name.." on class "..component_name)
	
    return component_instance
end

function tcs.await_component(instance: Instance, component_name: string)
	local component_instance = tcs.get_component(instance, component_name)

	if component_instance == nil then
		return tcs._wait_for_instance(instance, component_name, component_instance)
	end

	return component_instance
end

function tcs.create(instance: Instance, component: ComponentClass)
	local component_instance = component.new(instance) :: ComponentInstance -- .new is ran synchronously
	if DEBUG_PRINT then print("Registering "..component.Name.." on "..instance.Name) end

    if component.__Instances[instance] ~= nil then
        return
    end

    component.__Instances[instance] = component_instance

	INJECT_FUNCTION(component_instance)

	if DEBUG_PRINT then print("starting "..component_instance.Name.." on "..instance.Name) end
	task.spawn(function()
		component_instance.__Initialized = false
		component_instance:Start()
		component_instance.__Initialized = true
	end)
end

function tcs.destroy(instance: Instance, component: ComponentClass)
    local component_instance = tcs.get_component(instance, component.Name)
	if component_instance then
		component_instance:Destroy()
		component.__Instances[instance] = nil
	end
end

function tcs.create_component(component: ComponentClass)
    assert(component.Tag ~= nil, "Missing Tag property")
	assert(component.Name ~= nil, "Missing Name property on component with tag " .. component.Tag)
	assert(component.new ~= nil, "Missing constructor on " .. component.Name)
    assert(component.Destroy ~= nil, "Missing destructor function on " .. component.Name)
	if component.Start == nil then
		component.Start = function() end
	end
	if DEBUG_PRINT then print("called create_component with "..component.Name.." and tag "..component.Tag) end
		
	debug.setmemorycategory("create_component")

    local ancestor = component.Ancestor
	if ancestor == nil then
		ancestor = game
	end
		
	component_map[component.Name:lower()] = component
    component.__Instances = {}
	
	for _, thing in ipairs(CollectionService:GetTagged(component.Tag)) do
		if DEBUG_PRINT then print("getTagged "..component.Tag, thing) end
		if ancestor:IsAncestorOf(thing) then
			tcs.create(thing, component)	
		end
	end

    -- wait a frame to avoid double firing
	task.wait()

    CollectionService:GetInstanceAddedSignal(component.Tag):Connect(function(instance)
		if DEBUG_PRINT then print("instance added "..component.Tag, instance) end
		if ancestor:IsAncestorOf(instance) then
			tcs.create(instance, component)
		else
			if DEBUG_WARN then warn(string.format("Instance %s is not under the passed ancestor %s by component %s", instance.Name, component.Ancestor.Name, component.Name)) end
		end
	end)
	
	CollectionService:GetInstanceRemovedSignal(component.Tag):Connect(function(instance)
        tcs.destroy(instance, component)
	end)
	
    debug.resetmemorycategory()
end

function tcs.set_debug(print_: boolean, warn_: boolean)
	DEBUG_PRINT = print_
	DEBUG_WARN = warn_
end

function tcs.set_timeout(timeout: number)
	TIMEOUT = timeout
end

function tcs.set_inject_function(inject_function: (ComponentInstance) -> ())
	INJECT_FUNCTION = inject_function
end

return tcs