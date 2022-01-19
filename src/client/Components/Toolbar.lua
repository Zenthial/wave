local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local Rosyn = require(Shared:WaitForChild("Rosyn"))
local Signal = require(Shared:WaitForChild("util"):WaitForChild("Signal"))
local Trove = require(Shared:WaitForChild("util"):WaitForChild("Trove"))
local Input = require(Shared:WaitForChild("util", 5):WaitForChild("Input", 5))

local function shiftTable(tble: table, startIndex: number)
    if startIndex ~= #tble then
        for i = startIndex+1, #tble do
            local v = tble[i]
            tble[i - 1] = v
            tble[i] = nil
        end
    end
end

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

function Toolbar:Add(item: any, slot: number?): boolean
    local bool = false

    if slot and slot <= #self.Slots then
        self.Slots[slot] = item
        bool = true
    elseif slot and slot > #self.Slots then
        bool = false
    else
        local tableFull = true
        local freeSlot = -1
        for i, v in ipairs(self.Slots) do
            if v == nil then
                tableFull = false
                freeSlot = i
                break;
            end
        end

        if not tableFull then
            self.Slots[freeSlot] = item
            bool = true
        else
            bool = false
        end
    end

    return bool
end

function Toolbar:RemoveItem(item: any): boolean
    for i, v in ipairs(self.Slots) do
        if v == item then
            self.Slots[i] = nil
            shiftTable(self.Slots, i)
            return true
        end
    end
    
    return false
end

function Toolbar:RemoveIndex(index: number): any
    local oldVal = self.Slots[index]
    self.Slots[index] = nil
    shiftTable(self.Slots, index)
    
    return oldVal
end

function Toolbar:SetToolbarKeys(keyDict: {[number]: Enum.KeyCode})
    self.ToolbarKeys = keyDict    
end

function Toolbar:Destroy()
    self.Cleaner:Destroy()
end

Rosyn.Register("Toolbar", {Toolbar})

return Toolbar