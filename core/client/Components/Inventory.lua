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

        VehicleTurret = nil,
        VehicleTurretMutableStats = nil,
        TurretModel = nil,

        EquippedWeaponCleaner = nil,
    }, Inventory)
end

function Inventory:Start()
    self.MainHUD = tcs.get_component(PlayerGui:WaitForChild("MainHUD"), "MainHUD")

    local MainHUDComponent = self.MainHUD

    self.Cleaner:Add(SetWeaponSignal.OnClientEvent:Connect(function(inventoryKey: string, weaponName: string, model: Model, equip: boolean)
        if not equip then
            self["Equipped"..inventoryKey] = nil

            if inventoryKey == "Gadget" then
                MainHUDComponent:DeleteItem(LocalPlayer.Keybinds:GetAttribute("Gadget"))
            elseif inventoryKey == "Skill" then
                MainHUDComponent:DeleteItem(LocalPlayer.Keybinds:GetAttribute("Skill"))
            elseif inventoryKey == "Primary" or inventoryKey == "Secondary" then
                if self.EquippedWeapon ~= nil and self.EquippedWeapon == self["Equipped"..inventoryKey] then 
                    self.MainHUD:UpdateEquippedWeapon(nil, nil, nil)
                end
            end

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
        elseif inventoryKey == "Skill" or inventoryKey == "Skills" then
            assert(model, "Model does not exist on character. Look at server and client inventory components")
            local skill = SkillEngine.CreateSkill(weaponName, model)
            self.EquippedSkill = skill
            local skillCleaner = Trove.new()
            self.EquippedSkill.Cleaner = skillCleaner

            MainHUDComponent:UpdateItem(LocalPlayer.Keybinds:GetAttribute("Skill"), false, skill.Energy)
            skillCleaner:Add(skill.EnergyChanged:Connect(function(energy)
                MainHUDComponent:UpdateItem(LocalPlayer.Keybinds:GetAttribute("Skill"), false, energy)
            end))
        elseif inventoryKey == "Gadget" or inventoryKey == "Gadgets" then
            assert(model == nil, "Why does the grenade have a model?")
            
            local gadgetStats = GadgetStats[weaponName]

            if gadgetStats == nil then
                gadgetStats = WeaponStats[weaponName]
            end

            self.EquippedGadgetStats = gadgetStats
            self.EquippedGadget = weaponName

            MainHUDComponent:UpdateItem(LocalPlayer.Keybinds:GetAttribute("Gadget"), true, LocalPlayer:GetAttribute("GadgetQuantity"))
        end
    end))

    self.Cleaner:Add(LocalPlayer:GetAttributeChangedSignal("GadgetQuantity"):Connect(function()
        self.MainHUD:UpdateItem(LocalPlayer.Keybinds:GetAttribute("Gadget"), true, LocalPlayer:GetAttribute("GadgetQuantity"))
    end))

    self.Cleaner:Add(LocalPlayer:GetAttributeChangedSignal("CurrentTurret"):Connect(function()
        local currentTurret = LocalPlayer:GetAttribute("CurrentTurret")

        if currentTurret == "" then
            self.VehicleTurret = nil
            self.VehicleTurretMutableStats = nil
            self.MainHUD:UpdateEquippedWeapon(nil, nil, nil)

            if self.EquippedWeaponCleaner then
                self.EquippedWeaponCleaner:Clean()
            end
        else
            if self.EquippedWeaponCleaner then
                self.EquippedWeaponCleaner:Clean()
            end
            
            self.EquippedWeaponCleaner = Trove.new()
            local mutableStats = GunEngine.GetMutableStats(WeaponStats[currentTurret])
        
            if mutableStats then
                self.EquippedWeaponCleaner:Add(mutableStats.HeatChanged:Connect(function(heat: number)
                    self.MainHUD:UpdateHeat(heat, mutableStats.Overheated)
                end))
        
                self.EquippedWeaponCleaner:Add(mutableStats.BatteryChanged:Connect(function(battery: number)
                    self.MainHUD:UpdateBattery(battery)
                end))
        
                self.EquippedWeaponCleaner:Add(mutableStats.OverheatChanged:Connect(function(overheat: boolean)
                    self.MainHUD:SetOverheated(overheat)
                end))
            end

            self.VehicleTurret = WeaponStats[currentTurret]
            self.VehicleTurretMutableStats = mutableStats
            self.MainHUD:UpdateEquippedWeapon(WeaponStats[currentTurret], self.VehicleTurretMutableStats, nil)
        end
    end))
end

function Inventory:HandleWeapon(weaponStats, model: Model, mutableStats)
    if self.EquippedWeapon == weaponStats then
        if GunEngine.UnequipWeapon(weaponStats, mutableStats, model) == false then return end
        self.EquippedWeapon = nil
        self.EquippedStats = nil
        self.EquippedWeaponModel = nil
    elseif self.EquippedWeapon == nil then
        if GunEngine.EquipWeapon(weaponStats, mutableStats, model) == false then return end
        self.EquippedWeapon = weaponStats
        self.EquippedStats = mutableStats
        self.EquippedWeaponModel = model
    elseif self.EquippedWeapon ~= weaponStats then
        if GunEngine.UnequipWeapon(self.EquippedWeapon, self.EquippedStats, self.EquippedWeaponModel) == false then return end
        task.wait(0.35)
        self.EquippedWeapon = weaponStats
        self.EquippedStats = mutableStats
        self.EquippedWeaponModel = model
        if GunEngine.EquipWeapon(weaponStats, mutableStats, model) == false then return end
    end

    if self.EquippedWeaponCleaner then
        self.EquippedWeaponCleaner:Clean()
    end
    
    self.EquippedWeaponCleaner = Trove.new()

    if mutableStats then
        self.EquippedWeaponCleaner:Add(mutableStats.HeatChanged:Connect(function(heat: number)
            self.MainHUD:UpdateHeat(heat, mutableStats.Overheated)
        end))

        self.EquippedWeaponCleaner:Add(mutableStats.BatteryChanged:Connect(function(battery: number)
            self.MainHUD:UpdateBattery(battery)
        end))

        self.EquippedWeaponCleaner:Add(mutableStats.OverheatChanged:Connect(function(overheat: boolean)
            self.MainHUD:SetOverheated(overheat)
        end))
    end

    if self.EquippedWeapon ~= nil then
        self.MainHUD:UpdateEquippedWeapon(weaponStats, mutableStats, weaponStats == self.EquippedPrimary)
    else
        if mutableStats.CurrentHeat > 0 then
            repeat
                task.wait(.1)
            until mutableStats.CurrentHeat == 0
        end

        self.MainHUD:UpdateEquippedWeapon(nil, nil, nil)
    end
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
    elseif KeyCode == Enum.KeyCode[LocalPlayer.Keybinds:GetAttribute("VehicleInteract")] and LocalPlayer:GetAttribute("CurrentTurret") ~= "" and self.TurretModel ~= nil then
        GunEngine.StrikerAttack(self.VehicleTurret, self.VehicleTurretMutableStats, self.TurretModel)
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
    elseif LocalPlayer:GetAttribute("CurrentTurret") ~= "" and self.TurretModel ~= nil and self.TurretModel.Name ~= "Striker" then
        GunEngine.TurretAttack(self.VehicleTurret, self.VehicleTurretMutableStats, self.TurretModel)
    end
end

function Inventory:MouseUp()
    if self.EquippedWeapon then
        GunEngine.MouseUp(self.EquippedWeapon, self.EquippedStats)
    elseif LocalPlayer:GetAttribute("CurrentTurret") ~= "" and self.TurretModel ~= nil then
        GunEngine.MouseUp(self.VehicleTurret, self.VehicleTurretMutableStats)
    end
end

function Inventory:SetTurretModel(turretModel: Model)
    self.TurretModel = turretModel
end

function Inventory:Destroy()
    self.Cleaner:Destroy()
end

tcs.create_component(Inventory)
print("creating inventory")

return Inventory