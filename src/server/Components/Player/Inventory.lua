local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rosyn = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Rosyn"))

local Modules = game.ServerScriptService.Server.Modules
local GunEngine = require(Modules.GunEngine)

local Shared = ReplicatedStorage:WaitForChild("Shared")
local InventoryStats = require(Shared:WaitForChild("Configurations"):WaitForChild("InventoryStats"))
local WeaponStats = require(Shared:WaitForChild("Configurations"):WaitForChild("WeaponStats"))
local SkillStats = require(Shared:WaitForChild("Configurations"):WaitForChild("SkillStats"))
local GadgetStats = require(Shared:WaitForChild("Configurations"):WaitForChild("GadgetStats"))
local comm = require(Modules.ServerComm)

local WeaponModels = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Weapons")
local SkillModels = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Skills")

type InventoryType = InventoryStats.Inventory

local ServerComm = comm.GetComm()
local SetWeaponSignal = ServerComm:CreateSignal("SetWeapon")

local Inventory = {}
Inventory.__index = Inventory
Inventory.__Tag = "Inventory"

function Inventory.new(root: any)
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

    if self.Root:GetAttribute("Loaded") == false or self.Root:GetAttribute("Loaded") == nil then
        repeat
            task.wait()
        until self.Root:GetAttribute("Loaded") == true and self.Character ~= nil
    end

    self.Root:SetAttribute("EquippedWeapon", "") -- on the toolbars, have an event that fires when equipped and unequipped to increment the thing
    self.Root:SetAttribute("EquippedSkill", "") -- on the toolbars, have an event that fires when equipped and unequipped to increment the thing

    self:LoadInventory(InventoryStats)
end

function Inventory:LoadInventory(inv: InventoryType)
    for key, val in pairs(inv) do
        self.ActiveInventory[key] = val

        if key == "Weapons" then
            for _, name in pairs(val) do
                local stats = WeaponStats[name]
                local model = WeaponModels[name].Model:Clone() :: Model
                model.Name = name
                model.Parent = self.Character
    
                assert(stats, "No Weapon Stats for " .. name)
                assert(model, "No model for " .. name)
    
                local success = GunEngine:WeldWeapon(self.Character, model, true)
                if not success then
                    error("failed to weld")
                end

                SetWeaponSignal:Fire(self.Root, key, name, model)
            end
        elseif key == "Skills" then
            for _, name in pairs(val) do
                local stats = SkillStats[name]
                local model = SkillModels[name]:Clone() :: Model
                model.Name = name
                model.Parent = self.Character

                assert(stats, "No Skill Stats for " .. name)
                assert(model, "No model for " .. name)

                local success = GunEngine:WeldWeapon(self.Character, model, true)
                if not success then
                    error("failed to weld")
                end

                self.Root:SetAttribute("EquippedSkill", name)
                SetWeaponSignal:Fire(self.Root, key, name, model)
            end
        elseif key == "Gadgets" then
            for _, name in pairs(val) do
                local stats = GadgetStats[name]

                assert(stats, "No Grenade Stats for " .. name)
                self.Root:SetAttribute("EquippedGrenade", name)
                SetWeaponSignal:Fire(self.Root, key, name)
            end
        end
    end
end

function Inventory:Destroy()

end

Rosyn.Register("Player", {Inventory})

return Inventory