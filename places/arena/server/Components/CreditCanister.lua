local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local ArenaOptions = require(ReplicatedStorage:WaitForChild("ArenaShared"):WaitForChild("Configurations"):WaitForChild("ArenaOptions"))

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type CreditCanister_T = {
    __index: CreditCanister_T,
    Name: string,
    Tag: string,
    Root: Model & {
        CentralCylinder: Part,
        Panel: Part,
    },

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local CreditCanister: CreditCanister_T = {}
CreditCanister.__index = CreditCanister
CreditCanister.Name = "CreditCanister"
CreditCanister.Tag = "CreditCanister"
CreditCanister.Ancestor = workspace

function CreditCanister.new(root: any)
    return setmetatable({
        Root = root,
    }, CreditCanister)
end

function CreditCanister:Start()
    CollectionService:AddTag(self.Root.Panel, "Interactable")
    local interaction = tcs.get_component(self.Root.Panel, "Interactable")
    interaction:SetDistance(15)
    interaction:SetDuration(ArenaOptions.CanisterHoldDuration)

    self.Cleaner:Add(interaction.Activated:Connect(function(player: Player)
        print("here 2")
        for _, plr in player.Team:GetPlayers() do
            local arenaPlayer = tcs.get_component(plr, "ArenaPlayer")
            arenaPlayer:AwardCredits(ArenaOptions.CanisterCreditAward)
        end

        TweenService:Create(self.Root.CentralCylinder, TweenInfo.new(0.5), {Transparency = 1}):Play()
        CollectionService:RemoveTag(self.Root.Panel, "Interactable")
        CollectionService:RemoveTag(self.Root, "CreditCanister")
    end))

    print("connected")
    self.Cleaner:Add(function()
        CollectionService:RemoveTag(self.Root.Panel, "Interactable")
    end)

    self:MakeBillboardUI()
end

function CreditCanister:MakeBillboardUI()
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "BillboardGui"
    billboardGui.Active = true
    billboardGui.AlwaysOnTop = true
    billboardGui.ClipsDescendants = true
    billboardGui.LightInfluence = 1
    billboardGui.Size = UDim2.fromOffset(50, 50)
    billboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Name = "ImageLabel"
    imageLabel.Image = "rbxassetid://11183350907"
    imageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    imageLabel.BackgroundTransparency = 1
    imageLabel.Size = UDim2.fromScale(1, 1)
    imageLabel.Parent = billboardGui

    billboardGui.Parent = self.Root.CentralCylinder
    self.Cleaner:Add(billboardGui)
end

function CreditCanister:Destroy()
    print("here")
    self.Cleaner:Clean()
end

tcs.create_component(CreditCanister)

return CreditCanister