local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local GlobalOptions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("GlobalOptions"))

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type STAS3N_T = {
    __index: STAS3N_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T
}

local STAS3N: STAS3N_T = {}
STAS3N.__index = STAS3N
STAS3N.Name = "ServerSTAS3N"
STAS3N.Tag = "STAS3N"
STAS3N.Ancestor = game

function STAS3N.new(root: any)
    return setmetatable({
        Root = root,
    }, STAS3N)
end

function STAS3N:Start()
    local start, _ = string.find(self.Root.Name, "STAS3N")
    local playerName = self.Root.Name:sub(1, start - 1)
    self.Player = Players:FindFirstChild(playerName) :: Player

    local stationStream = Instance.new("RemoteEvent")
    stationStream.Name = self.Root.Name.."Stream"
    stationStream.Parent = ReplicatedStorage

    self.Cleaner:Add(stationStream.OnServerEvent:Connect(function(player, command: string, ...)
        if player.Name ~= playerName then return end -- probably exploited tbh

        if command == "Destroy" then
            self.Root:Destroy()
        elseif command == "Heal" then
            local healPlayer: Player, heal: number = ...

            local healthComponent = tcs.get_component(healPlayer, "Health")
            healthComponent:TakeDamage(-heal)
        elseif command == "Effect" then
            local thing: {Enabled: boolean}, bool: boolean = ...
            thing.Enabled = bool
        elseif command == "Color" then
            local thing: Part, brickColor: string = ...
            thing.BrickColor = BrickColor.new(brickColor)
        end
    end))

    task.delay(GlobalOptions.DeployableDestroyTime, function()
        if self.Root ~= nil and self.Root.Parent ~= nil then
            self.Root:Destroy()
        end
    end)
end

function STAS3N:Destroy()
    if self.Player then
        local quantity = self.Player:GetAttribute("NumDeployable" .. self.Root.Name)

        if quantity > 0 then
            self.Player:SetAttribute("NumDeployable" .. self.Root.Name, quantity - 1)
        end
    end

    self.Cleaner:Clean()
end

tcs.create_component(STAS3N)

return STAS3N