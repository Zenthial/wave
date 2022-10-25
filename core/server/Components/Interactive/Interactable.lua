local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type Interactable_T = {
    __index: Interactable_T,
    Name: string,
    Tag: string,
    Prompt: ProximityPrompt,

    Activated: typeof(Signal),

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local Interactable: Interactable_T = {}
Interactable.__index = Interactable
Interactable.Name = "Interactable"
Interactable.Tag = "Interactable"
Interactable.Ancestor = workspace

-- this tag should never be added in studio, it should be extended upon by other components
function Interactable.new(root: any)
    return setmetatable({
        Root = root,
    }, Interactable)
end

function Interactable:Start()

    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Interact"
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.MaxActivationDistance = 10
    prompt.HoldDuration = 3
    prompt.RequiresLineOfSight = false
    prompt.Parent = self.Root

    self.Cleaner:Add(prompt.Triggered:Connect(function(player)
        print(player)
    end))

    self.Cleaner:Add(prompt)
    
    self.Activated = prompt.Triggered

    self.Prompt = prompt
end

function Interactable:SetDuration(time: number)
    self.Prompt.HoldDuration = time    
end

function Interactable:SetText(text: string)
    self.Prompt.ActionText = text
end

function Interactable:SetDistance(distance: number)
    self.Prompt.MaxActivationDistance = distance
end

function Interactable:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(Interactable)

return Interactable