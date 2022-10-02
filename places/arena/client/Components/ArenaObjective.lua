local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type ArenaObjective_T = {
    __index: ArenaObjective_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local ArenaObjective: ArenaObjective_T = {}
ArenaObjective.__index = ArenaObjective
ArenaObjective.Name = "ArenaObjective"
ArenaObjective.Tag = "ArenaObjective"
ArenaObjective.Ancestor = PlayerGui

function ArenaObjective.new(root: any)
    return setmetatable({
        Root = root,
    }, ArenaObjective)
end

function ArenaObjective:Start()
    repeat
        task.wait(1)
    until Player.Team.Name ~= "Intermission"
    
    self.Root.Visible = true

    local myTeam = Player.Team.Name
    local otherTeam = if myTeam == "Red" then "Blue" else "Red"
    local roundAttributes = ReplicatedStorage:WaitForChild("RoundAttributesFolder")

    self.Cleaner:Add(roundAttributes:GetAttributeChangedSignal(myTeam.."Alive"):Connect(function()
        self.Root.MyTeam.Counter.Amount.Text = tostring(roundAttributes:GetAttribute(myTeam.."Alive"))
    end))
    
    self.Cleaner:Add(roundAttributes:GetAttributeChangedSignal(otherTeam.."Alive"):Connect(function()
        self.Root.OtherTeam.Counter.Amount.Text = tostring(roundAttributes:GetAttribute(otherTeam.."Alive"))
    end))

    self.Cleaner:Add(roundAttributes:GetAttributeChangedSignal(myTeam.."Score"):Connect(function()
        self.Root.MyTeamScore.Text = tostring(roundAttributes:GetAttribute(myTeam.."Score"))
    end))
    
    self.Cleaner:Add(roundAttributes:GetAttributeChangedSignal(otherTeam.."Score"):Connect(function()
        self.Root.OtherTeamScore.Text = tostring(roundAttributes:GetAttribute(otherTeam.."Score"))
    end))
    
    self.Root.MyTeamScore.Text = tostring(roundAttributes:GetAttribute(myTeam.."Alive"))
    self.Root.OtherTeamScore.Text = tostring(roundAttributes:GetAttribute(otherTeam.."Alive"))
end

function ArenaObjective:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(ArenaObjective)

return ArenaObjective