local CollectionService = game:GetService("CollectionService")
local Shields = game.ReplicatedStorage.Shared.Assets.Shields

for _, thing in pairs(Shields:GetChildren()) do
	CollectionService:AddTag(thing, "Ignore")
end

local weld = require(script.Parent.weld)

-- ripped from wace
return function(chr: Model)
	if not chr or chr:FindFirstChild("shieldModel") then return end
	
    local shieldModel = Instance.new("Model")
	shieldModel.Name = "shieldModel"
	shieldModel.Parent = chr
	
	local realHead = chr["Head"]
	local realTorso = chr["Torso"]
	local realLeftArm = chr["Left Arm"]	
	local realLeftLeg = chr["Left Leg"]
	local realRightArm = chr["Right Arm"]
	local realRightLeg = chr["Right Leg"]
	
	local head = Shields.HeadShield:Clone()
		head.Name = "HeadShield"
		head.Parent = shieldModel
	local torso = Shields.TorsoShield:Clone()
		torso.Name = "TorsoShield"
		torso.Parent = shieldModel
	local rarm = Shields.LimbShield:Clone()
		rarm.Name = "RightArmShield"
		rarm.Parent = shieldModel
	local rleg = Shields.LimbShield:Clone()
		rleg.Name = "RightLegShield"
		rleg.Parent = shieldModel
	local larm = Shields.LimbShield:Clone()
		larm.Name = "LeftArmShield"
		larm.Parent = shieldModel
	local lleg = Shields.LimbShield:Clone()
		lleg.Name = "LeftLegShield"
		lleg.Parent = shieldModel
	local holo = Shields.Hologram:Clone()
		holo.Parent = chr
	
	weld(realHead, head, "Weld", CFrame.new())
	weld(realTorso, torso, "Weld", CFrame.new())
	weld(realLeftArm, larm, "Weld", CFrame.new())	
	weld(realLeftLeg, lleg, "Weld", CFrame.new())	
	weld(realRightArm, rarm, "Weld", CFrame.new())	
	weld(realRightLeg, rleg, "Weld", CFrame.new())	
	weld(holo, larm, "Weld", CFrame.new())
	
	return shieldModel
end