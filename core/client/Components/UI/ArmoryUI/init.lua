local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local Types = require(script.Types)

local SELECTED_FRAME_SIZE = UDim2.new(0.9, 0, 0.1, 0)

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type ArmoryUI_T = {
    __index: ArmoryUI_T,
    Name: string,
    Tag: string,
    Root: Types.Root,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local ArmoryUI: ArmoryUI_T = {}
ArmoryUI.__index = ArmoryUI
ArmoryUI.Name = "ArmoryUI"
ArmoryUI.Tag = "ArmoryUI"
ArmoryUI.Ancestor = game

function ArmoryUI.new(root: any)
    return setmetatable({
        Root = root,
    }, ArmoryUI)
end

function ArmoryUI:Start()
    
end

function ArmoryUI:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(ArmoryUI)

return ArmoryUI