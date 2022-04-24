local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeaponStats_V2 = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))
local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))
local initializeWeaponViewport = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("functions"):WaitForChild("initializeWeaponViewport"))

local Weapons = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Weapons")

type Bar = Frame & {
    Fill: Frame
}

type StatValue = Frame & {
    Bar: Bar,
    Label: TextLabel,
    Number: TextLabel
}

type InspectGui = {
    ViewportFrame: ViewportFrame,

    ItemCost: TextLabel,
    ItemDescription: TextLabel,
    ItemName: TextLabel,

    Accuracy: StatValue,
    FireRate: StatValue,
    HeatRate: StatValue,

    Damage: Frame & {
        Amount: TextLabel,
        Label: TextLabel
    },

    Purchase: TextButton,
    BackButton: TextButton,
    Back: ImageLabel,
}

return function(itemName: string, inspectGui: InspectGui, slot: number): typeof(Signal)
    local weaponStats = WeaponStats_V2[itemName]

    local model
    if slot == 1 or slot == 2 then
        if Weapons:FindFirstChild(itemName) ~= nil and Weapons[itemName]:FindFirstChild("Model") ~= nil then
            model = Weapons[itemName].Model:Clone()
        end
    end

    if model == nil then return end
    initializeWeaponViewport(inspectGui.ViewportFrame, model)

    inspectGui.ItemName.Text = weaponStats.Name
    inspectGui.ItemDescription.Text = weaponStats.Description
    inspectGui.ItemCost.Text = string.format("COST: %d", weaponStats.WeaponCost)
    inspectGui.Damage.Amount.Text = weaponStats.Damage
    inspectGui.Accuracy.Number.Text = weaponStats.MaxSpread
    inspectGui.FireRate.Number.Text = weaponStats.FireRate
    inspectGui.HeatRate.Number.Text = weaponStats.HeatRate

    local signal = Signal.new()
    local backCon
    local purchaseCon

    backCon = inspectGui.BackButton.Activated:Connect(function()
        print("back")
        signal:Fire("Back")
        backCon:Disconnect()
        purchaseCon:Disconnect()
    end)

    purchaseCon = inspectGui.Purchase.Activated:Connect(function()
        print("purchase")
        signal:Fire("Purchase")
        backCon:Disconnect()
        purchaseCon:Disconnect()
    end)

    return signal
end