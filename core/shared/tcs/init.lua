local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local Trove = require(script.Trove)
local Promise = require(script.Promise)

local TIMEOUT = 5
local DEBUG_PRINT = false
local DEBUG_WARN = true

-- local STATIC_has_started = false -- static in the c sense

export type ComponentInstance = {
	__Initialized: boolean,

	Name: string,
	Tag: string,
	Needs: {string}?, -- The required needs of the component
	Cleaner: typeof(Trove)?,

	CreateDependencies: () -> {[string]: Instance}?,
	Start: () -> (),
	Destroy: () -> (),
}

export type ComponentClass = {
	Name: string, -- The name of the component
	Tag: string, -- The tag that collection service should bind to
	Ancestor: Instance?,
	Needs: {string}?, -- The required needs of the component

	new: (Instance) -> ComponentInstance, -- constructor
	Start: (ComponentClass) -> (), -- ran after .new and :CreateDependencies
	Destroy: (ComponentClass) -> (), -- ran when the entity loses the tag or is destroyed

    __Instances: {[Instance]: ComponentInstance}
}

local component_name_to_class_module: {[string]: ComponentClass} = {}

local function wait_for_class(component_name: string)
    local class = component_name_to_class_module[component_name:lower()]
	local start = tick()
	while class == nil do
		class = component_name_to_class_module[component_name:lower()]

		if tick() - start % TIMEOUT == 0 then
			if DEBUG_WARN then warn("POTENTIAL INFINITE TIMEOUT FOR COMPONENT "..component_name) end
		end 
		task.wait()
	end

	return class
end



local function get_component(instance: Instance, component_name: string)
    local class = component_name_to_class_module[component_name:lower()]
	if class == nil then
		class = wait_for_class(component_name)
	end
    assert(class, "No component class named "..component_name)
	
    local component_instance = class.__Instances[instance]
    -- assert(component_instance, "No component instance for instance "..instance.Name.." on class "..component_name)
	
    return component_instance
end

local function await_component(instance: Instance, component_name: string)
	return Promise.new(function(resolve, reject)
		local component_instance = get_component(instance, component_name)

		if component_instance == nil then
			local start = tick()
			
			while component_instance == nil do
				component_instance = get_component(instance, component_name)
				if tick() - start % TIMEOUT == 0 then
					if DEBUG_WARN then warn("POTENTIAL INFINITE TIMEOUT ON INSTANCE "..instance.Name.." FOR COMPONENT "..component_name) end
				end
				task.wait()
			end

			resolve(component_instance)
		else
			resolve(component_instance)
		end	
	end)
end

local function create(instance: Instance, component: ComponentClass)
	local component_instance = component.new(instance) :: ComponentInstance -- .new is ran synchronously
	if DEBUG_PRINT then print("Registering "..component.Name.." on "..instance.Name) end
    
    if component.__Instances[instance] ~= nil then
        component.__Instances[instance]:Destroy()
    end

    component.__Instances[instance] = component_instance

	component_instance.Cleaner = Trove.new() -- create a cleaner and throw it into the component_instance

	if DEBUG_PRINT then print("starting "..component_instance.Name.." on "..instance.Name) end
	task.spawn(function()
		component_instance.__Initialized = false
		component_instance:Start()
		component_instance.__Initialized = true
	end)
end

local function destroy(instance: Instance, component: ComponentClass) -- destruction method wrapper
    local component_instance = get_component(instance, component.Name)
	component.__Instances[component_instance] = nil
	component_instance:Destroy()
end

local function create_component(component: ComponentClass)
	assert(component.Tag ~= nil, "Missing Tag property")
	assert(component.Name ~= nil, "Missing Name property on component with tag " .. component.Tag)
	assert(component.new ~= nil, "Missing constructor on " .. component.Name)
	assert(component.Start ~= nil, "Missing initial function on " .. component.Name)
    assert(component.Destroy ~= nil, "Missing destructor function on " .. component.Name)
	if DEBUG_PRINT then print("called create_component with "..component.Name.." and tag "..component.Tag) end
		
	debug.setmemorycategory("create_component")
	
	local ancestor = component.Ancestor
	if ancestor == nil then
		ancestor = game
	end
		
	component_name_to_class_module[component.Name:lower()] = component
    component.__Instances = {}
	
	for _, thing in ipairs(CollectionService:GetTagged(component.Tag)) do
		if ancestor:IsAncestorOf(thing) then
			create(thing, component)	
		end
	end
	
	-- wait a frame to avoid double firing
	task.wait()
	
	CollectionService:GetInstanceAddedSignal(component.Tag):Connect(function(instance)
		if ancestor:IsAncestorOf(instance) then
			create(instance, component)
		else
			if DEBUG_WARN then warn(string.format("Instance %s is not under the passed ancestor %s by component %s", instance.Name, component.Ancestor.Name, component.Name)) end
		end
	end)
	
	CollectionService:GetInstanceRemovedSignal(component.Tag):Connect(function(instance)
        destroy(instance, component)
	end)
	
    debug.resetmemorycategory()
end

local function set_debug(print_: boolean, warn_: boolean)
	DEBUG_PRINT = print_
	DEBUG_WARN = warn_
end

return {
    create_component = create_component,
	get_component = await_component,
	debug = set_debug
}