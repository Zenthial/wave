local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Overlay_T = {
    __index: Overlay_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T
}

local Overlay: Overlay_T = {}
Overlay.__index = Overlay
Overlay.Name = "Overlay"
Overlay.Tag = "Overlay"
Overlay.Ancestor = PlayerGui

function Overlay.new(root: any)
    return setmetatable({
        Root = root,
    }, Overlay)
end

function Overlay:Start()
    local main = self.Root:WaitForChild("Main")
    local buttonContainer = main.ButtonContainer
    local armoryButton = buttonContainer.Armory.Button :: TextButton

    self.Cleaner:Add(armoryButton.MouseButton1Click:Connect(function()
        CollectionService:AddTag(self.Root, "Armory")
        main.Visible = false
    end))
end

function Overlay:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(Overlay)

return Overlay