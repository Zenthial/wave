local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))
local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))

type GenericPoint_T = {
    Root: Model & {Point: BasePart},
    Owner: nil | string,
    Active: boolean,

    Events: {
        OwnerChanged: typeof(Signal)
    },

    Cleaner: typeof(Trove)
}

local GenericPoint: GenericPoint_T = {}
GenericPoint.__index = GenericPoint

function GenericPoint.new(root)
    return setmetatable({
        Root = root,
        
        Owner = nil,
        Active = false,

        Events = {
            OwnerChanged = Signal.new()
        },

        Cleaner = Trove.new()
    }, GenericPoint)
end

function GenericPoint:Start()
    local rootSize = self.Root.Point.Size.Magnitude / 2
    self.Active = true

    task.spawn(function()
        while self.Active do
            local numRed = 0
            local numBlue = 0
    
            for _, player: Player in Players:GetPlayers() do
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    if (player.Character.HumanoidRootPart.Position - self.Root.Point.Position).Magnitude <= rootSize then
                        if player.Team.Name == "Red" then
                            numRed += 1
                        elseif player.Team.Name == "Blue" then
                            numBlue += 1
                        end
                    end
                end
            end
    
            if self.Owner == nil then
                if numRed > numBlue then
                    self.Owner = "Red"
                    self.Events.OwnerChanged:Fire(self.Owner)
                elseif numBlue < numRed then
                    self.Owner = "Blue"
                    self.Events.OwnerChanged:Fire(self.Owner)
                end
            elseif self.Owner == "Blue" and numRed > numBlue then
                self.Owner = "Red"
                self.Events.OwnerChanged:Fire(self.Owner)
            elseif self.Owner == "Red" and numBlue > numRed then
                self.Owner = "Blue"
                self.Events.OwnerChanged:Fire(self.Owner)
            end
    
            task.wait(1)
        end
    end)
end

function GenericPoint:SetActive(active: boolean)
    self.Active = active
end

function GenericPoint:Destroy()
    self.Cleaner:Clean()
end

return GenericPoint