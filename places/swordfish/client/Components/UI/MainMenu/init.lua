-- 07/11/2022/
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type MainMenu_T = {
    __index: MainMenu_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local MainMenu: MainMenu_T = {}
MainMenu.__index = MainMenu
MainMenu.Name = "MainMenu"
MainMenu.Tag = "MainMenu"
MainMenu.Ancestor = game

function MainMenu.new(root: any)
    return setmetatable({
        Root = root,
    }, MainMenu)
end

function MainMenu:Start()

end

function MainMenu:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(MainMenu)

return MainMenu