--!nonstrict

local CollectionService = game:GetService("CollectionService")

local Signal = require(script.Signal)
local Trove = require(script.Trove)

local Types = require(script.Types)

local COMPONENT_START_TIMEOUT = 5
local NAME_TIMEOUT = 5

type ComponentInstance = Types.ComponentInstance
type ComponentClass = Types.ComponentClass

local instances_on_components: {[Instance]: {[ComponentClass]: ComponentInstance}} = {}
local component_names_on_components: {[string]: ComponentClass} = {}

local function _get_instance_component(instance: Instance, component: ComponentClass): ComponentInstance | nil
	if instances_on_components[instance] ~= nil then
		if instances_on_components[instance][component] ~= nil then
			return instances_on_components[instance][component]
		else
			local start = tick()
			
			while tick() - start < COMPONENT_START_TIMEOUT do
				if instances_on_components[instance][component] ~= nil then
					return instances_on_components[instance][component]
				end
				task.wait(.1)
			end
		end
	else
		local start = tick()

		while tick() - start < COMPONENT_START_TIMEOUT do
			if instances_on_components[instance] ~= nil then
				return _get_instance_component(instance, component)
			end
			task.wait(.1)
		end
	end

	return nil
end

local function get_component_with_class(instance: Instance, component_class: ComponentClass): CommandInstance | nil
	local component_instance = _get_instance_component(instance, component_class)
	print(instance, component_class, component_class.Name, instances_on_components[instance])
	if component_instance ~= nil then
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
			initialized_connection:Disconnect()

			if result == 0 or component_instance.__Initialized == true then
				return component_instance
			elseif result == 1 then
				error("Initialization failed on " .. component_instance.Name)
			end
		end
	else
		error("Component " .. component_class.Name .. " does not exist on ".. instance.Name)
	end

	return nil
end

local function await_get_class_from_name(component_name: string)
	local start = tick()
	while tick() - start < NAME_TIMEOUT do
		if component_names_on_components[component_name:lower()] ~= nil then
			return component_names_on_components[component_name:lower()]
		end
		task.wait(.1)
	end

	return nil
end

local function get_component(instance: Instance, component_name: string): ComponentInstance | nil
	assert(instance, "No instance provided")
	assert(component_name, "No component name provided")
	assert(typeof(instance) == "Instance", "Instance provided is not an instance")
	assert(typeof(component_name) == "string", "Component name provided is not a string")

	local component_class = component_names_on_components[component_name:lower()]
	if component_class == nil then
		component_class = await_get_class_from_name(component_name)
	end
	assert(component_class, "Component " .. component_name .. " is not registered")

	return get_component_with_class(instance, component_class)
end

local function _create(instance: Instance, component: ComponentClass)
	if instances_on_components[instance] == nil then
		instances_on_components[instance] = {}
	end

	-- print(instances_on_components[instance])
	if instances_on_components[instance][component] ~= nil then
		return
	end

	local component_instance = component.new(instance) :: ComponentInstance -- .new is ran syncronously
	instances_on_components[instance][component] = component_instance
    component_instance.__Initialized = false
    local initialized_signal = Signal.new()
    component_instance.__InitializedSignal = initialized_signal

	task.spawn(function() -- spawn a new thread to handle 
		if component_instance.CreateDependencies then
			for componentName, componentRoot in pairs(component_instance:CreateDependencies()) do -- loop through the dependencies table
				local inst = get_component(componentRoot, componentName) -- add each dependency into the component_instance
				component_instance[componentName] = inst
			end
		end

		if component_instance.Needs then
			for _, need in pairs(component_instance.Needs) do -- loop through the needs
				if need == "Cleaner" then
					component_instance.Cleaner = Trove.new() -- create a cleaner and throw it into the component_instance
				end
			end
		end

		component_instance.__Initialized =  true -- set the initialized variable to true and fire the event
		initialized_signal:Fire()
		component_instance:Start() -- start the component sync'd in the thread
	end)

	return component_instance
end

local function _destroy(instance: Instance, component: ComponentClass, component_instance: ComponentInstance) -- destruction method wrapper
	instances_on_components[instance][component] = nil
	component_instance:Destroy()
end

local function create_component(component: ComponentClass)
	assert(component.Tag ~= nil, "Missing Tag property")
	assert(component.Name ~= nil, "Missing Name property on component with tag " .. component.Tag)
	assert(component.new ~= nil, "Missing constructor on " .. component.Name)
	assert(component.Start ~= nil, "Missing initial function on " .. component.Name)
    assert(component.Destroy ~= nil, "Missing destructor function on " .. component.Name)
    
    debug.setmemorycategory("create_component")
            
	local ancestor = component.Ancestor
	if ancestor == nil then
		ancestor = game
	end

	component_names_on_components[component.Name:lower()] = component

	for i, thing in ipairs(CollectionService:GetTagged(component.Tag)) do
		-- print("Existing", component.Name, component.Tag, thing, i)
		if ancestor:IsAncestorOf(thing) then
			_create(thing, component)	
		end
	end

	-- wait a frame to avoid double firing
	task.wait(.1)

	CollectionService:GetInstanceAddedSignal(component.Tag):Connect(function(instance)
		-- print("Instance added", component.Name, component.Tag, instance)
		if ancestor:IsAncestorOf(instance) then
			_create(instance, component)
		end
	end)

	CollectionService:GetInstanceRemovedSignal(component.Tag):Connect(function(instance)
		local component_instance = _get_instance_component(instance, component)
		if component_instance ~= nil then
			_destroy(instance, component, component_instance)
		end
	end)

    debug.resetmemorycategory()
end

return {
	create_component = create_component,
	get_component = get_component,
}