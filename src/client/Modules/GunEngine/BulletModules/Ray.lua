local Trove = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

type GunModelAdditionalInfo = {
    Barrel: Part,
    Grip: Part
}
type GunModel = Model & GunModelAdditionalInfo

local Ray = {}
Ray.__index = Ray

function Ray.new(gunModel: GunModel)
    local self = setmetatable({
        Model = gunModel,

        Cleaner = Trove.new()
    }, Ray)
    return self
end

function Ray:Hitscan()
    
end

function Ray:Destroy()
    self.Cleaner:Destroy()
end

return Ray