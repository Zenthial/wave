local Players = game:GetService("Players")

local Util = {}

function CFrameAccessoryToCharacter(characterModel, accessory)
	local accessoryAttachment = accessory:FindFirstChildWhichIsA("Attachment", true)
	if not accessoryAttachment then
		warn("No attachments found in accessory. Accessory was not attached.")
		return
	end

	local attachmentName = accessoryAttachment.Name
	local attachTo: Attachment = characterModel:FindFirstChild(attachmentName, true)
	if not attachTo or not attachTo:IsA("Attachment") then
		warn(string.format("No attachment named %s found in character. Accessory was not attached.", attachmentName))
		return
	end

	local handle = accessory:FindFirstChild("Handle")
	if not handle then
		warn("Attachment has no handle. Accessory was not attached.")
		return
	end

	handle.Anchored = true
    handle.CFrame = attachTo.WorldCFrame * accessoryAttachment.CFrame:Inverse()

	accessory.Parent = characterModel
end

function Util:ResetCharacterAppearance(avatarModel: Model)
    local humanoid: Humanoid = avatarModel:FindFirstChild("Humanoid")
    if not humanoid then return end

    for _, object in pairs(avatarModel:GetDescendants()) do
        local className = object.ClassName
        if className == "Part" then
            object.BrickColor = BrickColor.new("Medium stone grey")
        elseif className == "Body Colors" then
            object:Destroy()
        elseif className == "Pants" then
            object:Destroy()
        elseif className == "Shirt" then
            object:Destroy()
        elseif className == "Accessory" then
            object:Destroy()
        elseif className == "Decal" then
            object:Destroy()
        end
    end

    avatarModel.Head.Transparency = 1
    avatarModel["Left Arm"].Transparency = 1
    avatarModel["Right Arm"].Transparency = 1
    avatarModel["Left Leg"].Transparency = 1
    avatarModel["Right Leg"].Transparency = 1
    avatarModel.Torso.Transparency = 1

    avatarModel.Name = avatarModel:GetAttribute("OriginalName")
end

-- puts a character's appearance on a character model
function Util:LoadCharacterAppearance(player: Player, avatarModel: Model, overwriteName: string)
    local humanoid: Humanoid = avatarModel:FindFirstChild("Humanoid")
    local head = avatarModel:FindFirstChild("Head")
    if not humanoid then return end
    if not head then return end
    
    avatarModel.Name = overwriteName or player.Name

    local description = (player.UserId > 0 and Players:GetHumanoidDescriptionFromUserId(player.UserId)) or Players:GetHumanoidDescriptionFromUserId(9345226)
    avatarModel.Humanoid:ApplyDescription(description)
end

return Util