local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local Signal = require(Shared:WaitForChild("util"):WaitForChild("Signal"))
local Trove = require(Shared:WaitForChild("util"):WaitForChild("Trove"))

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
Toolbar.__Tag = "Toolbar"

function Toolbar.new(size: number)
    local self = {
        Slots = table.create(size),
        ToolbarKeys = {
            Enum.KeyCode.One,
            Enum.KeyCode.Two,
            Enum.KeyCode.Three,
        },

        EquippedTool = nil,
        EquippedSlot = nil,

        Events = {
            GetUserToolbarKeys = Signal.new(),
            ToolChanged = Signal.new()
        },

        Cleaner = Trove.new() :: typeof(Trove),
    }

    for i = 1, size do
        self.Slots[i] = false
    end

    return setmetatable(self, Toolbar)
end

function Toolbar:SetKeys(keys)
    self.ToolbarKeys = keys
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
            if v == false then
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

function Toolbar:FeedInput(keyCode: Enum.KeyCode)
    local index = table.find(self.ToolbarKeys, keyCode)

    if index then
        if self.EquippedTool ~= nil then
            if self.EquippedTool.Unequip ~= nil then
                self.EquippedTool:Unequip()
            end
            self.EquippedTool = nil
            self.Events.ToolChanged:Fire(nil)
        end

        if self.EquippedSlot ~= index and self.Slots[index] ~= false then
            self.EquippedSlot = index
            self.EquippedTool = self.Slots[index]
            self.Events.ToolChanged:Fire(self.EquippedTool)
            if self.EquippedTool.Equip ~= nil then
                self.EquippedTool:Equip()
            end
        else
            self.EquippedSlot = nil
            self.Events.ToolChanged:Fire(nil)
        end
    end
end

function Toolbar:MouseDown()
    if self.EquippedTool ~= nil and self.EquippedTool["MouseDown"] then
        self.EquippedTool:MouseDown()
    end
end

function Toolbar:MouseUp()
    if self.EquippedTool ~= nil and self.EquippedTool["MouseUp"] then
        self.EquippedTool:MouseUp()
    end
end

function Toolbar:Destroy()
    self.Cleaner:Destroy()
end

return Toolbar