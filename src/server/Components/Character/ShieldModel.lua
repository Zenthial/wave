local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Rosyn = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Rosyn"))

local makeShieldModel = require(ServerScriptService.Server.Helper.makeShieldModel)

local ShieldModel = {}
ShieldModel.__index = ShieldModel
ShieldModel.__Tag = "ShieldModel"

function ShieldModel.new(root: any)
    return setmetatable({
        Root = root,
    }, ShieldModel)
end

function ShieldModel:Initial()
    self.Model = makeShieldModel(self.Root)

    self.__call = function()
        return self.Model
    end

    self:UpdateShieldTransparency(1)
end

-- wace relic
function ShieldModel:UpdateShieldTransparency(trans)
    task.spawn(function()
        if not (trans ~= 1 and self.Root and self.Root.Torso.Transparency > 0) then
        
            if self.Model then
                local brickcolor = tostring(self.Model.TorsoShield.BrickColor)
    
                for _, part in pairs(self.Model:GetChildren()) do
                    if not (brickcolor == "Neon orange" or brickcolor == "Bright green") then
                        part.Transparency = trans
                    end
                    
                    if trans < 1 then
                        part.ShieldRegen.Enabled = true
                    else
                        part.ShieldRegen.Enabled = false
                    end
                end
            end
        end
    end)
end

function ShieldModel:ShieldEmpty()
    self.Model.TorsoShield.ShieldEmpty:Play()
    self.Model.TorsoShield.ShieldExplosion.Enabled = true

    self:UpdateShieldTransparency(0)

    task.delay(0.2, function()
        self:UpdateShieldTransparency(1)
        self.Model.TorsoShield.ShieldExplosion.Enabled = false
    end)
end

function ShieldModel:Destroy()
    self.Model:Destroy()
end

Rosyn.Register("ShieldModel", {ShieldModel}, workspace)

return ShieldModel