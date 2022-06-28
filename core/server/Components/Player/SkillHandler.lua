local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local skillFunctions = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Helper"):WaitForChild("skillFunctions"))
local setTableTransparency = skillFunctions.setTableTransparency
local createShieldModel = skillFunctions.createShieldModel
local deleteSkillModel = skillFunctions.deleteSkillModel

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type SkillHandler_T = {
    __index: SkillHandler_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T
}

local SkillHandler: SkillHandler_T = {}
SkillHandler.__index = SkillHandler
SkillHandler.Name = "SkillHandler"
SkillHandler.Tag = "SkillHandler"
SkillHandler.Ancestor = game

function SkillHandler.new(root: any)
    return setmetatable({
        Root = root,
	    CurrentSkill = "",
    }, SkillHandler)
end

function SkillHandler:Start()         
    local PlayerFolder = ReplicatedStorage:WaitForChild("PlayerFolders"):WaitForChild(self.Root.Name)    

    local RemoteFolder = Instance.new("Folder")
    RemoteFolder.Name = "SkillRemoteFolder"
    RemoteFolder.Parent = PlayerFolder

    local function createRemote(name: string, playerFolder: Folder)
        local remote = Instance.new("RemoteEvent")
        remote.Name = name
        remote.Parent = RemoteFolder

        return remote
    end

    local SkillEquippedRemote = createRemote(self.Root.Name.."_SkillEquippedRemote")
    self.Cleaner:Add(SkillEquippedRemote.OnServerEvent:Connect(function(player, skillName: string)
        if self.CurrentSkill == "APS" then
            deleteSkillModel(player)
        end

        self.CurrentSkill = skillName
    end))

    local InvisRemote = createRemote(self.Root.Name.."_InvisRemote")
    self.Cleaner:Add(InvisRemote.OnServerEvent:Connect(function(player, objTable, transparency)
        if player ~= self.Root then player:Kick() end
        
        if player:GetAttribute("EquippedSkill") == "INVI-C" then
            setTableTransparency(player, objTable, transparency)
        end
    end))

    local ShieldRemote = createRemote(self.Root.Name.."_ShieldRemote")
    self.Cleaner:Add(ShieldRemote.OnServerEvent:Connect(function(player, request: string)
        request = string.lower(request)
     	if request == "create" then
     	    createShieldModel(player)       
        end
    end))
end

function SkillHandler:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(SkillHandler)

return SkillHandler
