local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local bluejay = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("bluejay"))

local Player = Players.LocalPlayer

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Armory_T = {
    __index: Armory_T,
    Name: string,
    Tag: string,

    Root: Part,

    Cleaner: Cleaner_T
}

local Armory: Armory_T = {}
Armory.__index = Armory
Armory.Name = "Armory"
Armory.Tag = "Armory"
Armory.Ancestor = game
Armory.Needs = {"Cleaner"}

function Armory.new(root: any)
    return setmetatable({
        Root = root,
    }, Armory)
end

function Armory:CreateDependencies()
    return {}
end

function Armory:Start()
    local character = Player.Character or Player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")

    local distance = self.Root.Size / 2

    local active = true
    self.Cleaner:Add(function()
        active = false
    end)

    while active do
        local params = OverlapParams.new()
        params.FilterDescendantsInstances = {character}
        params.FilterType = Enum.RaycastFilterType.Whitelist
        params.MaxParts = 1

        local objects = workspace:GetPartsInPart(self.Root, params)
        if #objects == 0 then
            if Player:GetAttribute("InArmory") == true then
                Player:SetAttribute("InArmory", false)
                print("left armory")
            end
        else
            if Player:GetAttribute("InArmory") == false then
                Player:SetAttribute("InArmory", true)
                print("entered armory")
            end
        end

        task.wait(.5)
    end
end

function Armory:Destroy()
    self.Cleaner:Clean()
end

bluejay.create_component(Armory)

return Armory