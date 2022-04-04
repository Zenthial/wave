-- By Preston (seliso)
-- 1/11/2022
-- AnimationData is meant to be more of a read-only data struct meant for organization of the animationid and the marker events
-- Pass this into the Animation Component with :Load() (after that remove all ref of the struct for it to be garbge collected)
-- Example of what a struct is: https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/builtin-types/struct
--[[
    EXAMPLE:

    ```lua
    local rollAnimationData = AnimationData.new(name: string id: number)
    rollAnimationData.MarkerSignals["ShakeCamera"] = function(paramString: string)
        --do stuff
    end
    ```

    DATATYPE:  

    ```lua
    export type AnimationDataTab = { 
        Name: string,
        TrackId: number,
        MarkerSignals: {[string]: () -> ()}
    }
    ```
]]

------------------------------------------------------------------------

local AnimationData = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared", 5)
local Types = require(Shared:WaitForChild("Types"))

function AnimationData.new(name: string, id: number)
    local self: Types.AnimationData = {
        Name = name,
        TrackId = id,
        MarkerSignals = {},
    }
    return self;
end

return AnimationData