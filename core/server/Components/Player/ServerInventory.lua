local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local Modules = game.ServerScriptService:WaitForChild("Server"):WaitForChild("Modules")
local GunEngine = require(Modules:WaitForChild("GunEngine"))

local Shared = ReplicatedStorage:WaitForChild("Shared")
local InventoryStats = require(Shared:WaitForChild("Configurations"):WaitForChild("InventoryStats"))
local WeaponStats = require(Shared:WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))
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
    print(self.Root, self.Character)

    if self.Root:GetAttribute("Loaded") == false or self.Root:GetAttribute("Loaded") == nil then
        repeat
            task.wait()
        until self.Root:GetAttribute("Loaded") == true and self.Character ~= nil
    end

    print("Inventory loaded")
    
    self:LoadServerInventory(InventoryStats)
end

function ServerInventory:LoadServerInventory(inv: ServerInventoryType)
    print(inv)
    for key, name in pairs(inv) do
        self.ActiveServerInventory[key] = name

        if key == "Primary" or key == "Secondary" then
            local stats = WeaponStats[name]
            local model = WeaponModels[name].Model:Clone() :: Model

            for _, thing in pairs(model:GetChildren()) do
                CollectionService:AddTag(thing, "Ignore")
            end
            
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

            if stats == nil then
                stats = WeaponStats[name]
                if not stats.Type == "Deployable" then
                    stats = nil
                end
            end

            assert(stats, "No Grenade Stats for " .. name)
            self.Root:SetAttribute("EquippedGadget", name)
            self.Root:SetAttribute("GadgetQuantity", stats.Quantity or 2)
            self.Root:SetAttribute("MaxGadgetQuantity", stats.Quantity or 2)
            SetWeaponSignal:FireClient(self.Root, key, name)
        end
    end
end

function ServerInventory:Destroy()

end

tcs.create_component(ServerInventory)

return ServerInventory