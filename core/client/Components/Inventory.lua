local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts

local bluejay = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("bluejay"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local Toolbar = require(script.Parent.Parent.Modules.Toolbar)

local Modules = StarterPlayerScripts.Client.Modules
local GunEngine = require(Modules.GunEngine)

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
    
        Items = {
            Weapons = {},
            Gadgets = {},
            Skills = {}
        },

    }, Inventory)
end

function Inventory:CreateDependencies()
    return {
        ["MainHUD"] = PlayerGui:WaitForChild("MainHUD")
    }
end

function Inventory:Start()
    self.WeaponsToolbar = Toolbar.new(3) :: typeof(Toolbar)
    self.SkillsToolbar = Toolbar.new(2) :: typeof(Toolbar)
    self.SkillsToolbar:SetKeys(DEFAULT_SKILL_KEYS)
    self.EquippedGadget = nil

    local MainHUDComponent = self.MainHUD

    self.Cleaner:Add(SetWeaponSignal.OnClientEvent:Connect(function(inventoryKey: string, weaponName: string, model: Model)
        print(inventoryKey, weaponName)
        local character = self.Root.Character or self.Root.CharacterAdded:Wait()
        if model == nil then
            model = character:FindFirstChild(weaponName)
        end

        if inventoryKey == "Primary" or inventoryKey == "Secondary" then
            assert(model, "Model does not exist on character. Look at server and client inventory components")
            local gun = GunEngine:CreateGun(weaponName, model)
            local success = self.WeaponsToolbar:Add(gun)
            if not success then
                print("failed to add weapon " .. weaponName)
            end
        elseif inventoryKey == "Skill" then
            assert(model, "Model does not exist on character. Look at server and client inventory components")
            local skill = GunEngine:CreateSkill(weaponName, model)
            local success = self.SkillsToolbar:Add(skill)
            if not success then
                print("failed to add skill " .. weaponName)
            end
        elseif inventoryKey == "Gadget" then
            assert(model == nil, "Why does the grenade have a model?")
            self.EquippedGadget = weaponName
        end
    end))

    local equippedWeaponCleaner = nil :: typeof(Trove)
    self.Cleaner:Add(self.WeaponsToolbar.Events.ToolChanged:Connect(function(tool)
        if equippedWeaponCleaner ~= nil then
            equippedWeaponCleaner:Clean()
        end
        MainHUDComponent:UpdateEquippedWeapon(tool)

        if tool ~= nil then
            equippedWeaponCleaner = Trove.new()
            equippedWeaponCleaner:Add(tool.Events.AmmoChanged:Connect(function(heat: number)
                MainHUDComponent:UpdateHeat(heat)
            end))

            equippedWeaponCleaner:Add(tool.Events.Fired:Connect(function(trigDelay: number)
                MainHUDComponent:UpdateTriggerBar(trigDelay)
            end))
        end
    end))

    self.Cleaner:Add(self.SkillsToolbar.Events.ToolChanged:Connect(function(tool)
        -- maybe do something idk
    end))
end

function Inventory:FeedInput(KeyCode: Enum.KeyCode)
    self.WeaponsToolbar:FeedInput(KeyCode)
    self.SkillsToolbar:FeedInput(KeyCode)

    if KeyCode == Enum.KeyCode[LocalPlayer:GetAttribute("GadgetKeybind")] and self.EquippedGadget ~= nil then
        GunEngine:RenderGrenadeForLocalPlayer(self.EquippedGadget)
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

bluejay.create_component(Inventory)
print("creating inventory")

return Inventory