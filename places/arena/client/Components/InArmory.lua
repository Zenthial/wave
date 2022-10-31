local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type InArmory_T = {
    __index: InArmory_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local InArmory: InArmory_T = {}
InArmory.__index = InArmory
InArmory.Name = "InArmory"
InArmory.Tag = "InArmory"
InArmory.Ancestor = workspace

function InArmory.new(root: any)
    return setmetatable({
        Root = root,
    }, InArmory)
end

function InArmory:Start()
    Player:SetAttribute("InArenaArmory", false)
    
    self.Cleaner:Add(RunService.RenderStepped:Connect(function()
        if (HRP.Position - self.Root.Position).Magnitude <= 10 then
            if Player:GetAttribute("InArenaArmory") == false then
                Player:SetAttribute("InArenaArmory", true)
            end
        else
            if Player:GetAttribute("InArenaArmory") == true then
                Player:SetAttribute("InArenaArmory", false)
            end        
        end
    end))
end

function InArmory:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(InArmory)

return InArmory