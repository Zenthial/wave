
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local APS_HEALTH = 2500

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type APS_T = {
    __index: APS_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T
}

local APS: APS_T = {}
APS.__index = APS
APS.Name = "ServerAPS"
APS.Tag = "APS"
APS.Ancestor = workspace

function APS.new(root: any)
    return setmetatable({
        Root = root,
        Health = APS_HEALTH,
    }, APS)
end

function APS:Start()
    
end

function APS:Destroy()

end

tcs.create_component(APS)
return APS
