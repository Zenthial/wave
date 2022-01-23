local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rosyn = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Rosyn"))

local Modules = game.ServerScriptService.Server.Modules
local GunEngine = require(Modules.GunEngine)

local Shared = ReplicatedStorage:WaitForChild("Shared")
local InventoryStats = require(Shared:WaitForChild("Configurations"):WaitForChild("InventoryStats"))
local WeaponStats = require(Shared:WaitForChild("Configurations"):WaitForChild("WeaponStats"))
local comm = require(Modules.ServerComm)

local WeaponModels = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Weapons")

type InventoryType = InventoryStats.Inventory

local ServerComm = comm.GetComm()
local SetWeaponSignal = ServerComm:CreateSignal("SetWeapon")

local Inventory = {}
Inventory.__index = Inventory

function Inventory.new(root: any)
    print("inventory")
    return setmetatable({
        Root = root,

        ActiveInventory = {
            Weapons = {},
            Gadgets = {},
            Skills = {}
        } :: InventoryType
    }, Inventory)
end

function Inventory:Initial()
    self:LoadInventory(InventoryStats)
end

function Inventory:LoadInventory(inv: InventoryType)
    for key, val in pairs(inv) do
        self.ActiveInventory[key] = val

        if key == "Weapons" then
            for _, name in pairs(val) do
                local stats = WeaponStats[name]
                local model = WeaponModels[name]:Clone() :: Model
                model.Parent = self.Root.Character

                print(model)
    
                assert(stats, "No Weapon Stats for " .. name)
                assert(model, "No model for " .. name)
    
                GunEngine:WeldWeapon(self.Root, model, true)
                
                if self.Root:GetAttribute("PlayerLoaded") == false then
                    repeat
                        task.wait()
                    until self.Root:GetAttribute("PlayerLoaded")
                
                end
                SetWeaponSignal:Fire(self.Root, key, name, model)
            end
        end
    end
end

function Inventory:Destroy()

end

Rosyn.Register("Player", {Inventory})

return Inventory