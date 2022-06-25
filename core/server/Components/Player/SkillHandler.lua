local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local RemoteFolder = Instance.new("Folder")
RemoteFolder.Name = "SkillRemoteFolder"
RemoteFolder.Parent = ReplicatedStorage

local function setTableTransparency(player, objTable, transparency)
	if transparency then
		for i,v in pairs(objTable) do
			v.Transparency = transparency
		end
	else
		for i,v in pairs(objTable) do
			if v:IsA("Decal") then
				v.Transparency = 0
			else
				if string.sub(v.Name, 1, 8) == "Hologram" then
					v.Transparency = 0.25
				elseif string.sub(v.Name, 1, 5) == "Blade" or string.sub(v.Name, 1, 7) == "Battery" or v.Name == "Reactor" then
					v.Transparency = 0
				elseif string.sub(v.Name, 1, 5) == "Glass" then
					v.Transparency = 0.75
					v.Material = "SmoothPlastic"
				elseif string.sub(v.Name, 1, 6) == "Bottle" then
					v.Transparency = 0.5
					v.Material = "Neon"
				elseif string.sub(v.Name, 1, 5) == "Three" and (v.Parent.Name == "STUN" or v.Parent.Name == "TAG") then
					v.Transparency = 0.75
				else 
					v.Transparency = 0
					v.Material = "SmoothPlastic"
				end
			end
		end
	end
end

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
    }, SkillHandler)
end

function SkillHandler:Start()
    local InvisRemote = Instance.new("RemoteEvent")
    InvisRemote.Name = self.Root.Name.."_InvisRemote"
    InvisRemote.Parent = RemoteFolder

    self.Cleaner:Add(InvisRemote.OnServerEvent:Connect(function(player, objTable, transparency)
        if player ~= self.Root then player:Kick() end
        
        if player:GetAttribute("EquippedSkill") == "INVI-C" then
            setTableTransparency(player, objTable, transparency)
        end
    end))
end

function SkillHandler:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(SkillHandler)

return SkillHandler