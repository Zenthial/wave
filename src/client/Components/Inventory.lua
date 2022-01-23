local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts

local Rosyn = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Rosyn"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local Toolbar = require(script.Parent.Toolbar)

local Modules = StarterPlayerScripts.Client.Modules
local GunEngine = require(Modules.GunEngine)
local comm = require(Modules.ClientComm)

local ClientComm = comm.GetClientComm()

local Inventory = {}
Inventory.__index = Inventory

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
    self.WeaponsToolbar = Toolbar.new() :: typeof(Toolbar)
    local SetWeaponSignal = ClientComm:GetSignal("SetWeapon")

    self.Cleaner:Add(SetWeaponSignal:Connect(function(inventoryKey: string, weaponName: string, model: Model)
        if inventoryKey == "Weapons" then
            local gun = GunEngine:CreateGun(weaponName, model)
            self.WeaponsToolbar:Add(gun)
        end
    end))
end

function Inventory:Destroy()
    self.Cleaner:Destroy()
end

Rosyn.Register("Player", {Inventory})

return Inventory