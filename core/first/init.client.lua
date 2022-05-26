local StarterGui = game:GetService("StarterGui")
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)


local player = game.Players.LocalPlayer
player:SetAttribute("ReplicatedFirstClient", true)