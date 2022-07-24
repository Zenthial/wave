local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local Player = Players.LocalPlayer

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type ArmoryChecker_T = {
    __index: ArmoryChecker_T,
    Name: string,
    Tag: string,

    Root: Part,

    Cleaner: Cleaner_T
}

local ArmoryChecker: ArmoryChecker_T = {}
ArmoryChecker.__index = ArmoryChecker
ArmoryChecker.Name = "ArmoryChecker"
ArmoryChecker.Tag = "Armory"
ArmoryChecker.Ancestor = workspace
ArmoryChecker.Needs = {"Cleaner"}

function ArmoryChecker.new(root: any)
    return setmetatable({
        Root = root,
    }, ArmoryChecker)
end

function ArmoryChecker:Start()
    local character = Player.Character or Player.CharacterAdded:Wait()

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
                print("left ArmoryChecker")
            end
        else
            if Player:GetAttribute("InArmory") == false then
                Player:SetAttribute("InArmory", true)
                print("entered ArmoryChecker")
            end
        end

        task.wait(.5)
    end
end

function ArmoryChecker:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(ArmoryChecker)

return ArmoryChecker