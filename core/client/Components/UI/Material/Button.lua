local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Themes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("Themes"))
local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type Button_T = {
    __index: Button_T,
    Name: string,
    Tag: string,
    Root: Frame & {
        Fill: Frame,
        Button: TextButton & {
            UIStroke: UIStroke,
            UICorner: UICorner,
            Shadow: Frame & {
                UICorner: UICorner
            }
        },
        TextLabel: TextLabel
    },
    Selected: boolean,
    Hovered: boolean,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local Button: Button_T = {}
Button.__index = Button
Button.Name = "MaterialUI"
Button.Tag = "Button"
Button.Ancestor = PlayerGui

function Button.new(root: Frame)
    return setmetatable({
        Root = root,
    }, Button)
end

function Button:Start()
    self.Cleaner:Add(self.Root.Button.MouseButton1Click:Connect(function()
        -- HANDLE CLICKS        
    end))

    self.Cleaner:Add(self.Root.Button.MouseEnter:Connect(function()
        self:SetHovered(true)
    end))

    self.Cleaner:Add(self.Root.Button.MouseLeave:Connect(function()    
        self:SetHovered(false)
    end))
end

function Button:ChangeTheme(newTheme: number)
    self.Theme = newTheme

    self:UpdateAppearance()
end

function Button:UpdateAppearance()
    -- This should utilize the associated color themes of the button
end

function Button:SetHovered(hovered: boolean)
    self.Hovered = hovered
    self:UpdateAppearance()
end

function Button:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(Button)

return Button