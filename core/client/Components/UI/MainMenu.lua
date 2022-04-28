local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local Player = Players.LocalPlayer

local SELECTED_COLOR = Color3.fromRGB(98, 200, 255)
local UNSELECTED_COLOR = Color3.fromRGB(255, 255, 255)

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type MainMenu_T = {
    __index: MainMenu_T,
    Name: string,
    Tag: string,
    CurrentPanel: string,
    Open: boolean,

    Root: {
        SwitcherButtons: {
            Keys: TextButton,
            Stats: TextButton,
            Options: TextButton,
            GetChildren: () -> {TextButton},
            GetDescendants: () -> {any},
        },

        Options: {
            Container: ScrollingFrame,
            Visible: boolean,
        }
    },

    Cleaner: Cleaner_T
}

local MainMenu: MainMenu_T = {}
MainMenu.__index = MainMenu
MainMenu.Name = "MainMenu"
MainMenu.Tag = "MainMenu"
MainMenu.Ancestor = game
MainMenu.Needs = {"Cleaner"}

function MainMenu.new(root: any)
    return setmetatable({
        Root = root,
    }, MainMenu)
end

function MainMenu:Start()
    self.CurrentPanel = "Options"
    self.Open = false
    self:CloseMenu()

    for _, thing in pairs(self.Root.SwitcherButtons:GetChildren()) do
        if thing:IsA("UIListLayout") then continue end
        self.Cleaner:Add(thing.Activated:Connect(function()
            self:OpenPanel(thing.Name)
        end))
    end

    for _, boolOption in pairs(self.Root.Options.Container:GetChildren()) do
        if not boolOption:IsA("Frame") then continue end
        local boolOptionComponent = tcs.get_component(boolOption, "BoolOption") --[[:await()]]
        print(boolOptionComponent)
        if boolOptionComponent ~= nil then
            self.Cleaner:Add(boolOptionComponent.Events.Changed:Connect(function(newStateType)
                Player:SetAttribute(boolOption.Name.."Option", newStateType)
            end))

            local state = Player:GetAttribute(boolOption.Name.."Option")

            assert(typeof(state) == "boolean", "Attribute "..boolOption.Name.."Option does not exist on local player")
            boolOptionComponent:SetState(state)
        end
    end
end

function MainMenu:OpenPanel(panel: string)
    self.Root[panel].Visible = true
    self.Root[self.CurrentPanel].Visible = false
    self.SwitcherButtons[panel].OptionText.TextColor = SELECTED_COLOR
    self.SwitcherButtons[self.CurrentPanel].OptionText.TextColor = UNSELECTED_COLOR
    self.CurrentPanel = panel
end

-- can worry about making a fancy tween transition later
function MainMenu:OpenMenu()
    self.Open = true
    self.Root.Visible = true
end

function MainMenu:CloseMenu()
    self.Open = false
    self.Root.Visible = false
end

function MainMenu:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(MainMenu)

return MainMenu