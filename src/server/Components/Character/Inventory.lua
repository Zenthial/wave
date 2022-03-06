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
Inventory.__Tag = "Inventory"

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
    self.Character = self.Root.Character or self.Root.CharacterAdded:Wait()

    print(self.Character)
    if self.Root:GetAttribute("Loaded") == false or self.Root:GetAttribute("Loaded") == nil then
        repeat
            task.wait()
        until self.Root:GetAttribute("Loaded") == true and self.Character ~= nil
    end

    print(self.Root:GetAttribute("Loaded") == true and self.Character ~= nil)

    self:LoadInventory(InventoryStats)
end

function Inventory:LoadInventory(inv: InventoryType)
    for key, val in pairs(inv) do
        self.ActiveInventory[key] = val

        if key == "Weapons" then
            for _, name in pairs(val) do
                local stats = WeaponStats[name]
                local model = WeaponModels[name]:Clone() :: Model
                model.Parent = self.Character

                print(model)
    
                assert(stats, "No Weapon Stats for " .. name)
                assert(model, "No model for " .. name)
    
                local success = GunEngine:WeldWeapon(self.Character, model, true)
                if not success then
                    error("failed to weld")
                end
                print(self.Character, key, name, model, model.Parent)
                SetWeaponSignal:Fire(self.Root, key, name, model)
            end
        end
    end
end

function Inventory:Destroy()

end

Rosyn.Register("Player", {Inventory})

return Inventory