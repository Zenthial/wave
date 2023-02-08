local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local WeaponStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))
local courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type C4_T = {
    __index: C4_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local C4: C4_T = {}
C4.__index = C4
C4.Name = "C4"
C4.Tag = "C4"
C4.Ancestor = workspace

function C4.new(root: any)
    return setmetatable({
        Root = root,
    }, C4)
end

function C4:Start()
    courier:Listen("C4Damage"):Connect(function(player: Player, playerTable: {Player})
        if player:GetAttribute("EquippedGadget") == "C4" then
            for _, plr in pairs(playerTable) do
                task.spawn(function()
                    if plr.Character then
                        local playerHealthComponent = tcs.get_component(plr, "Health")
                        playerHealthComponent:TakeDamage(WeaponStats["C4"].CalculateDamage(WeaponStats["C4"].Damage, (plr.Character.HumanoidRootPart.Position - self.Root.Handle.Position).Magnitude))
                    end
                end)
            end
        end
    end)
end

function C4:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(C4)

return C4