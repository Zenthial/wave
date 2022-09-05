local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts

local Courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))
local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))
local GadgetStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("GadgetStats"))
local WeaponStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))

local Modules = StarterPlayerScripts.Client.Modules
local GunEngine = require(Modules.GunEngine)
local SkillEngine = require(Modules.SkillEngine)
local DeployableEngine = require(Modules.DeployableEngine)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local SetWeaponSignal = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SetWeapon")

local DEFAULT_SKILL_KEYS = {
    Enum.KeyCode.F,
    Enum.KeyCode.H
}

local Inventory = {}
Inventory.__index = Inventory
Inventory.Name = "Inventory"
Inventory.Tag = "Inventory"
Inventory.Needs = {"Cleaner"}
Inventory.Ancestor = Players

function Inventory.new(root: any)
    return setmetatable({
        Root = root,

        EquippedGadgetStats = nil,
        EquippedGadget = nil,
        EquippedSkill = nil, 
        EquippedWeapon = nil,
        EquippedPrimary = nil,
        EquippedSecondary = nil,

        EquippedWeaponCleaner = nil,
    }, Inventory)
end

function Inventory:Start()
    self.MainHUD = tcs.get_component(PlayerGui:WaitForChild("MainHUD"), "MainHUD") --[[:await()]]

    local MainHUDComponent = self.MainHUD
    local skillCleaner = Trove.new() :: typeof(Trove)

    self.Cleaner:Add(SetWeaponSignal.OnClientEvent:Connect(function(inventoryKey: string, weaponName: string, model: Model, equip: boolean)
        if not equip then
            self["Equipped"..inventoryKey] = nil
            return
        end
        
        local character = self.Root.Character or self.Root.CharacterAdded:Wait()
        if model == nil and weaponName ~= nil then
            model = character:FindFirstChild(weaponName)
        end

        if inventoryKey == "Primary" or inventoryKey == "Secondary" then
            assert(model, "Model does not exist on character. Look at server and client inventory components")
            local weaponStats = WeaponStats[weaponName]
            self["Equipped"..inventoryKey] = weaponStats
            self["Equipped"..inventoryKey.."MutableStats"] = GunEngine.GetMutableStats(weaponStats)
            self["Equipped"..inventoryKey.."Model"] = model

            task.spawn(function()
                GunEngine.LoadAnimations(weaponStats)
            end)
        elseif inventoryKey == "Skill" then
            assert(model, "Model does not exist on character. Look at server and client inventory components")
            local skill = SkillEngine.CreateSkill(weaponName, model)
            self.EquippedSkill = skill
        elseif inventoryKey == "Gadget" then
            assert(model == nil, "Why does the grenade have a model?")
            
            local gadgetStats = GadgetStats[weaponName]

            if gadgetStats == nil then
                gadgetStats = WeaponStats[weaponName]
            end

            self.EquippedGadgetStats = gadgetStats
            self.EquippedGadget = weaponName
        end
    end))
end

function Inventory:HandleWeapon(weaponStats, model: Model, mutableStats)
    if self.EquippedWeapon == weaponStats then
        GunEngine.UnequipWeapon(weaponStats, model)
        self.EquippedWeapon = nil
        self.EquippedStats = mutableStats
    elseif self.EquippedWeapon == nil then
        self.EquippedWeapon = weaponStats
        self.EquippedStats = mutableStats
        GunEngine.EquipWeapon(weaponStats, model)
    elseif self.EquippedWeapon ~= weaponStats then
        GunEngine.UnequipWeapon(weaponStats, model)
        self.EquippedWeapon = weaponStats
        self.EquippedStats = mutableStats
        GunEngine.EquipWeapon(weaponStats, model)
    end

    if self.EquippedWeaponCleaner then
        self.EquippedWeaponCleaner:Clean()
    end
    
    self.EquippedWeaponCleaner = Trove.new()

    -- if self.EquippedWeapon then
    --     self.EquippedWeaponCleaner:Add(self.EquippedWeapon.Events.AmmoChanged:Connect(function(heat: number)
    --         self.MainHUD:UpdateHeat(heat)
    --     end))

    --     self.EquippedWeaponCleaner:Add(self.EquippedWeapon.Events.Fired:Connect(function(trigDelay: number)
    --         self.MainHUD:UpdateTriggerBar(trigDelay)
    --     end))
    -- end

    local name = self.EquippedWeapon and self.EquippedWeapon.Name or nil
    self.MainHUD:UpdateEquippedWeapon(name)
end

function Inventory:FeedKeyDown(KeyCode: Enum.KeyCode)
    if KeyCode == Enum.KeyCode[LocalPlayer.Keybinds:GetAttribute("Gadget")] and self.EquippedGadget ~= nil and LocalPlayer:GetAttribute("GadgetQuantity") > 0 then
        if self.EquippedGadgetStats.Type == "Projectile" then
            GunEngine:RenderGrenadeForLocalPlayer(self.EquippedGadget)
        elseif self.EquippedGadgetStats.Type == "Deployable" then
            DeployableEngine:RenderDeployable(self.EquippedGadgetStats, self.EquippedWeapon)
        end
    elseif KeyCode == Enum.KeyCode[LocalPlayer.Keybinds:GetAttribute("Skill")] and self.EquippedSkill ~= nil then
        SkillEngine.Use(self.EquippedSkill, not self.EquippedSkill.Active)
    else
        if KeyCode == Enum.KeyCode.One and self.EquippedPrimary ~= nil then
            self:HandleWeapon(self.EquippedPrimary, self.EquippedPrimaryModel, self.EquippedPrimaryMutableStats)
        elseif KeyCode == Enum.KeyCode.Two and self.EquippedSecondary ~= nil then
            self:HandleWeapon(self.EquippedSecondary, self.EquippedSecondaryModel, self.EquippedSecondaryMutableStats)
        end
    end
end

function Inventory:FeedKeyUp(KeyCode: Enum.KeyCode)
    if KeyCode == Enum.KeyCode[LocalPlayer.Keybinds:GetAttribute("Gadget")] and self.EquippedGadget ~= nil and LocalPlayer:GetAttribute("GadgetQuantity") > 0 then
        if self.EquippedGadgetStats.Type == "Deployable" then
            DeployableEngine:CancelDeployable()
        end
    end
end

function Inventory:MouseDown()
    if self.EquippedWeapon then
        GunEngine.MouseDown(self.EquippedWeapon, self.EquippedStats)
    end
end

function Inventory:MouseUp()
    if self.EquippedWeapon then
        GunEngine.MouseUp(self.EquippedWeapon, self.EquippedStats)
    end
end

function Inventory:Destroy()
    self.Cleaner:Destroy()
end

tcs.create_component(Inventory)
print("creating inventory")

return Inventory