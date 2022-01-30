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
    self.WeaponsToolbar = Toolbar.new(3) :: typeof(Toolbar)
    local SetWeaponSignal = ClientComm:GetSignal("SetWeapon")

    self.Cleaner:Add(SetWeaponSignal:Connect(function(inventoryKey: string, weaponName: string, model: Model)
        print(inventoryKey, weaponName, model)

        local character = self.Root.Character or self.Root.CharacterAdded:Wait()
        if inventoryKey == "Weapons" then
            if model == nil then
                model = character:FindFirstChild(weaponName)
            end

            assert(model, "Model does not exist on character. Look at server and client inventory components")
            local gun = GunEngine:CreateGun(weaponName, model)
            print(gun)
            local success = self.WeaponsToolbar:Add(gun)
            if not success then
                print("failed to add weapon")
            end
        end
    end))
end

function Inventory:Destroy()
    self.Cleaner:Destroy()
end

Rosyn.Register("Player", {Inventory})

return Inventory