local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local GenericClassHandler = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Modules"):WaitForChild("GenericClassHandler"))
local Classes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("ClassConfigurations"))

local ClassHandler = {}

function ClassHandler:Start()
    print("loading classes")
    for className, classInfoTable in Classes do
        GenericClassHandler:RegisterClass(className, classInfoTable)
    end
end

return ClassHandler
