local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))
local GadgetStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("GadgetStats"))
local WeaponStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))

local Modules = StarterPlayerScripts.Client.Modules
local GunEngine = require(Modules.GunEngine)
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

    self.Cleaner:Add(SetWeaponSignal.OnClientEvent:Connect(function(inventoryKey: string, weaponName: string, model: Model)
        local character = self.Root.Character or self.Root.CharacterAdded:Wait()
        if model == nil and weaponName ~= nil then
            model = character:FindFirstChild(weaponName)
        end

        if inventoryKey == "Primary" or inventoryKey == "Secondary" then
            assert(model, "Model does not exist on character. Look at server and client inventory components")
            local gun = GunEngine.CreateGun(weaponName, model)
            self["Equipped"..inventoryKey] = gun
        elseif inventoryKey == "Skill" then
            assert(model, "Model does not exist on character. Look at server and client inventory components")
            local skill = GunEngine.CreateSkill(weaponName, model)
            self.EquippedSkill = skill
            
            if skillCleaner ~= nil then
                skillCleaner:Clean()
                skillCleaner = Trove.new()
            end
            
            skillCleaner:Add(skill.Events.EnergyChanged:Connect(function(currentEnergy: number)
                MainHUDComponent:SkillEnergyChanged(currentEnergy)
            end))

            skillCleaner:Add(skill.Events.FunctionStarted:Connect(function()
                MainHUDComponent:SetSkillActive()
            end))
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

function Inventory:HandleWeapon(gunPointer)
    if self.EquippedWeapon == gunPointer then
        gunPointer:Unequip()
        self.EquippedWeapon = nil
    elseif self.EquippedWeapon == nil then
        self.EquippedWeapon = gunPointer
        gunPointer:Equip()
    elseif self.EquippedWeapon ~= gunPointer then
        self.EquippedWeapon:Unequip()
        self.EquippedWeapon = gunPointer
        gunPointer:Equip()
    end

    if self.EquippedWeaponCleaner then
        self.EquippedWeaponCleaner:Clean()
        self.EquippedWeaponCleaner = nil
    end

    if self.EquippedWeapon then
        self.EquippedWeaponCleaner:Add(self.EquippedWeapon.Events.AmmoChanged:Connect(function(heat: number)
            self.MainHUD:UpdateHeat(heat)
        end))

        self.EquippedWeaponCleaner:Add(self.EquippedWeapon.Events.Fired:Connect(function(trigDelay: number)
            self.MainHUD:UpdateTriggerBar(trigDelay)
        end))
    end

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
        self.EquippedSkill:Equip()
    else
        if KeyCode == Enum.KeyCode.One and self.EquippedPrimary ~= nil then
            self:HandleWeapon(self.EquippedPrimary)
        elseif KeyCode == Enum.KeyCode.Two and self.EquippedSecondary ~= nil then
            self:HandleWeapon(self.EquippedSecondary)
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
    self.WeaponsToolbar:MouseDown()
end

function Inventory:MouseUp()
    self.WeaponsToolbar:MouseUp()
end

function Inventory:Destroy()
    self.Cleaner:Destroy()
end

tcs.create_component(Inventory)
print("creating inventory")

return Inventory