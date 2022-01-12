local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local Rosyn = require(Shared:WaitForChild("Rosyn"))
local Signal = require(Shared:WaitForChild("util"):WaitForChild("Signal"))
local Trove = require(Shared:WaitForChild("util"):WaitForChild("Trove"))
local Input = require(Shared:WaitForChild("util", 5):WaitForChild("Input", 5))

local Toolbar = {}
Toolbar.__index = Toolbar

function Toolbar.new(root: any)
    return setmetatable({
        Root = root,

        Slots = table.create(3),
        ToolbarKeys = {
            Enum.KeyCode.One,
            Enum.KeyCode.Two,
            Enum.KeyCode.Three,
        },

        EquippedTool = nil,
        EquippedSlot = nil,

        Events = {
            GetUserToolbarKeys = Signal.new()
        },

        Cleaner = Trove.new() :: typeof(Trove),
        Input = Input.Keyboard.new() :: typeof(Input.Keyboard),

    }, Toolbar)
end

function Toolbar:Initial()
    local cleaner = self.Cleaner :: typeof(Trove)
    local input = self.Input :: typeof(Input.Keyboard)

    cleaner:Add(input.KeyDown:Connect(function(keyCode: Enum.KeyCode)
        local index = table.find(self.ToolbarKeys, keyCode)
        
        if index then
            self.EquippedSlot = index
            self.EquippedTool:Unequip()
            self.EquippedTool = self.Slots[index]
            self.EquippedTool:Equip()
        end
    end))

end

function Toolbar:SetToolbarKeys(keyDict: {[number]: Enum.KeyCode})
    self.ToolbarKeys = keyDict    
end

function Toolbar:Destroy()
    self.Cleaner:Destroy()
end

Rosyn.Register("Toolbar", {Toolbar})

return Toolbar