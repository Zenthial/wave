local Signal = require(script.Parent.Signal)

export type ComponentInstance = {
    __Initialized: boolean,
    __InitializedSignal: typeof(Signal),

    Name: string,
    Tag: string,
    Needs: {string}, -- The required needs of the component

    CreateDependencies: () -> {[string]: Instance},
    Start: () -> (),
    Destroy: () -> (),
}

export type ComponentClass = {
    Name: string, -- The name of the component
    Tag: string, -- The tag that collection service should bind to
    Ancestor: Instance?,
    Needs: {string}, -- The required needs of the component
    
    new: (Instance) -> ComponentInstance, -- constructor
    CreateDependencies: () -> {[string]: Instance}, -- Returns a dictionary where the keys are component names and the values are component roots
    Start: () -> (), -- ran after .new and :CreateDependencies
    Destroy: () -> (), -- ran when the entity loses the tag or is destroyed
}

return {}