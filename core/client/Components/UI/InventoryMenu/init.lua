local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local bluejay = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("bluejay"))
local ViewportModel = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ViewportModel"))
local Weapons = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Weapons")
local Skills = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Skills")
local Gadgets = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Gadgets")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local function initializeWeapon(frame: ViewportFrame, model: Model)
    model.Parent = frame
    
    local camera = Instance.new("Camera")
    camera.FieldOfView = 70
    camera.Parent = frame

    frame.CurrentCamera = camera

    local vpfModel = ViewportModel.new(frame, camera)
    local cf, _ = model:GetBoundingBox()
	
	vpfModel:SetModel(model)
	
	local theta = 0
	local orientation = CFrame.new()
	local distance = vpfModel:GetFitDistance(cf.Position)
	
	local con = RunService.RenderStepped:Connect(function(dt)
		theta = theta + math.rad(30 * dt)
		orientation = CFrame.fromEulerAnglesYXZ(0, theta, 0)
		camera.CFrame = CFrame.new(cf.Position) * orientation * CFrame.new(0, 0, distance)
	end)

    return con
end

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

-- this type is kinda large, sorry for any other readers, just skip down to the code
type InventoryMenu_T = {
    __index: InventoryMenu_T,
    Name: string,
    Tag: string,
    Root: {
        Inventory: Frame & {
            Weapons: Frame & {
                Primary: Frame & {
                    ViewportFrame: ViewportFrame,
                    Detail: Frame,
                    Button: ImageButton,
                    Title: TextLabel
                },

                Secondary: Frame & {
                    ViewportFrame: ViewportFrame,
                    Detail: Frame,
                    Button: ImageButton,
                    Title: TextLabel
                }
            },

            Utility: Frame & {
                Skill: Frame & {
                    ViewportFrame: ViewportFrame,
                    Detail: Frame,
                    Button: ImageButton,
                    Title: TextLabel
                },

                Gadget: Frame & {
                    ViewportFrame: ViewportFrame,
                    Detail: Frame,
                    Button: ImageButton,
                    Title: TextLabel
                }
            },
        },

        Shop: Frame & {
            BackButton: ImageButton,
            Title: TextLabel,
            Container: Frame & {
                UIListLayout: UIListLayout
            }
        }
    },

    State: {
        OpenPanel: Frame,
    },

    Cleaner: Cleaner_T
}

local InventoryMenu: InventoryMenu_T = {}
InventoryMenu.__index = InventoryMenu
InventoryMenu.Name = "InventoryMenu"
InventoryMenu.Tag = "InventoryMenu"
InventoryMenu.Ancestor = PlayerGui
InventoryMenu.Needs = {"Cleaner"}

function InventoryMenu.new(root: any)
    return setmetatable({
        Root = root,
    }, InventoryMenu)
end

function InventoryMenu:CreateDependencies()
    return {}
end

function InventoryMenu:Start()
    self:InitializeWeapons()
    self:InitializeUtilities()
end

function InventoryMenu:InitializeWeapons()
    local primary = Player:GetAttribute("EquippedPrimary")
    local secondary = Player:GetAttribute("EquippedSecondary")

    local primaryFrame = self.Root.Inventory.Weapons.Primary.ViewportFrame
    local secondaryFrame = self.Root.Inventory.Weapons.Secondary.ViewportFrame

    primaryFrame:ClearAllChildren()
    secondaryFrame:ClearAllChildren()

    self.Cleaner:Add(initializeWeapon(primaryFrame, Weapons[primary].Model:Clone()))
    self.Cleaner:Add(initializeWeapon(secondaryFrame, Weapons[secondary].Model:Clone()))
end

function InventoryMenu:InitializeUtilities()
    local skill = Player:GetAttribute("EquippedSkill")
    local gadget = Player:GetAttribute("EquippedGadget")

    local skillFrame = self.Root.Inventory.Utility.Skill.ViewportFrame
    local gadgetFrame = self.Root.Inventory.Utility.Gadget.ViewportFrame

    skillFrame:ClearAllChildren()
    gadgetFrame:ClearAllChildren()

    self.Cleaner:Add(initializeWeapon(skillFrame, Skills[skill]:Clone()))

    local projModel = Instance.new("Model")
    Gadgets[gadget].Projectile:Clone().Parent = projModel

    self.Cleaner:Add(initializeWeapon(gadgetFrame, projModel))
end

function InventoryMenu:Destroy()
    self.Cleaner:Clean()
    print("cleaned inventory menu")
end

bluejay.create_component(InventoryMenu)

return InventoryMenu