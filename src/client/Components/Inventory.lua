local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts

local Rosyn = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Rosyn"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local Toolbar = require(script.Parent.Parent.Modules.Toolbar)

local Modules = StarterPlayerScripts.Client.Modules
local GunEngine = require(Modules.GunEngine)
local comm = require(Modules.ClientComm)
local MainHUDModule = require(StarterPlayerScripts.Client.Components.UI.MainHUD)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ClientComm = comm.GetClientComm()

local DEFAULT_SKILL_KEYS = {
    Enum.KeyCode.F,
    Enum.KeyCode.H
}

local Inventory = {}
Inventory.__index = Inventory
Inventory.__Tag = "Inventory"

function Inventory.new(root: any)
    return setmetatable({
        Root = root,
    
        Items = {
            Weapons = {},
            Gadgets = {},
            Skills = {}
        },

        Cleaner = Trove.new()
    }, Inventory)
end

function Inventory:Initial()
    self.WeaponsToolbar = Toolbar.new(3) :: typeof(Toolbar)
    self.SkillsToolbar = Toolbar.new(2) :: typeof(Toolbar)
    self.SkillsToolbar:SetKeys(DEFAULT_SKILL_KEYS)

    local MainHUD = PlayerGui:WaitForChild("MainHUD")
    local MainHUDComponent = Rosyn.AwaitComponentInit(MainHUD, MainHUDModule) :: typeof(MainHUDModule)

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

    local SetWeaponSignal = ClientComm:GetSignal("SetWeapon")
    self.Cleaner:Add(SetWeaponSignal:Connect(function(inventoryKey: string, weaponName: string, model: Model)
        local character = self.Root.Character or self.Root.CharacterAdded:Wait()
        if model == nil then
            model = character:FindFirstChild(weaponName)
        end

        if inventoryKey == "Weapons" then
            assert(model, "Model does not exist on character. Look at server and client inventory components")
            local gun = GunEngine:CreateGun(weaponName, model)
            local success = self.WeaponsToolbar:Add(gun)
            if not success then
                print("failed to add weapon " .. weaponName)
            end
        elseif inventoryKey == "Skills" then
            assert(model, "Model does not exist on character. Look at server and client inventory components")
            local skill = GunEngine:CreateSkill(weaponName, model)
            local success = self.SkillsToolbar:Add(skill)
            if not success then
                print("failed to add skill " .. weaponName)
            end
        end
    end))
end

function Inventory:FeedInput(KeyCode: Enum.KeyCode)
    self.WeaponsToolbar:FeedInput(KeyCode)
    self.SkillsToolbar:FeedInput(KeyCode)
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

Rosyn.Register("Player", {Inventory})

return Inventory