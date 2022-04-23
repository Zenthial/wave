local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local bluejay = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("bluejay"))

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

type ServerInventoryType = InventoryStats.Inventory

local SetWeaponSignal = Instance.new("RemoteEvent")
SetWeaponSignal.Name = "SetWeapon"
SetWeaponSignal.Parent = ReplicatedStorage.Shared

local ServerInventory = {}
ServerInventory.__index = ServerInventory
ServerInventory.Name = "ServerInventory"
ServerInventory.Tag = "Player"
ServerInventory.Ancestor = Players

function ServerInventory.new(root: any)
    return setmetatable({
        Root = root,

        ActiveServerInventory = {
            Primary = "",
            Secondary = "",
            Gadgets = "",
            Skills = ""
        } :: ServerInventoryType
    }, ServerInventory)
end

function ServerInventory:Start()
    self.Character = self.Root.Character or self.Root.CharacterAdded:Wait()

    if self.Root:GetAttribute("Loaded") == false or self.Root:GetAttribute("Loaded") == nil then
        repeat
            task.wait()
        until self.Root:GetAttribute("Loaded") == true and self.Character ~= nil
    end

    print("Inventory loaded")
    
    self:LoadServerInventory(InventoryStats)
end

function ServerInventory:LoadServerInventory(inv: ServerInventoryType)
    for key, name in pairs(inv) do
        self.ActiveServerInventory[key] = name

        if key == "Primary" or key == "Secondary" then
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

            self.Root:SetAttribute("Equipped"..key, name)
            SetWeaponSignal:FireClient(self.Root, key, name, model)
        elseif key == "Skill" then
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
            SetWeaponSignal:FireClient(self.Root, key, name, model)
        elseif key == "Gadget" then
            local stats = GadgetStats[name]

            assert(stats, "No Grenade Stats for " .. name)
            self.Root:SetAttribute("EquippedGadget", name)
            SetWeaponSignal:FireClient(self.Root, key, name)
        end
    end
end

function ServerInventory:Destroy()

end

bluejay.create_component(ServerInventory)

return ServerInventory