-- should be an overarching setup module
-- after the tech demo, this probably won't need to be touched

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local PLAYER_TAG = "Player"

Players.PlayerAdded:Connect(function(player: Player)
    CollectionService:AddTag(player, PLAYER_TAG)
end)


for _, module in pairs(script:GetDescendants()) do
    if module:IsA("ModuleScript") then
        require(module)
    end
end