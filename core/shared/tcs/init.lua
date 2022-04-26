local CollectionService = game:GetService("CollectionService")

local Trove = require(script.Trove)

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

local function get_component(instance: Instance, component_name: string)
    local class = component_name_to_class_module[component_name:lower()]
    assert(class, "No component class named "..component_name)

    local component_instance = class.__Instances[instance]
    assert(component_instance, "No component instance for instance "..instance.Name.." on class "..component_name)

    return component_instance
end

local function create(instance: Instance, component: ComponentClass)
	local component_instance = component.new(instance) :: ComponentInstance -- .new is ran synchronously
    
    if component.__Instances[instance] ~= nil then
        component.__Instances[instance]:Destroy()
    end

    component.__Instances[instance] = component_instance
    
end

local function destroy(instance: Instance, component: ComponentClass) -- destruction method wrapper
    local component_instance = get_component(instance, component)
	component.__Instances[component_instance] = nil
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
		
	component_name_to_class_module[component.Name:lower()] = component
    component.__Instances = {}
	
	for i, thing in ipairs(CollectionService:GetTagged(component.Tag)) do
		-- print("Existing", component.Name, component.Tag, thing, i)
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
			warn(string.format("Instance %s is not under the passed ancestor %s by component %s", instance.Name, component.Ancestor.Name, component.Name))
		end
	end)
	
	CollectionService:GetInstanceRemovedSignal(component.Tag):Connect(function(instance)
        destroy(instance, component)
	end)
	
    debug.resetmemorycategory()
end

local function start()
    for _component_name, component_class in pairs(component_name_to_class_module) do
        for _instance, component_instance in pairs(component_class.__Instances) do
            task.spawn(function()
                if component_instance.Needs then
                    for _, need in pairs(component_instance.Needs) do -- loop through the needs
                        if need == "Cleaner" then
                            component_instance.Cleaner = Trove.new() -- create a cleaner and throw it into the component_instance
                        end
                    end
                end

                component_instance.__Initialized = false
                component_instance:Start()
                component_instance.__Initialized = true
            end)
        end
    end
end

return {
    start = start,
    create_component = create_component
}