local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Courier"))

local GenericClassHandler = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Modules"):WaitForChild("GenericClassHandler"))
local SwordfishClasses = require(ReplicatedStorage:WaitForChild("SwordfishShared"):WaitForChild("Modules"):WaitForChild("SwordfishClasses"))

local SwordfishClassHandler = {}

function SwordfishClassHandler:Start()
    for className, classInfoTable in SwordfishClasses do
        GenericClassHandler:RegisterClass(className, classInfoTable)
    end

    Courier:Listen("RequestClassChange"):Connect(function(player: Player, newClass: string)
        if SwordfishClasses[newClass] == nil then player:Kick(newClass .. " does not exist as a valid swordfish class") end
        if player:GetAttribute("CurrentClass") == newClass then return end

        if GenericClassHandler:CanJoinClass(newClass) then
            GenericClassHandler:ChangeClass(player, newClass, SwordfishClasses[newClass])
        end
    end)
end

return SwordfishClassHandler
