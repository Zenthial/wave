local Players = game:GetService("Players")

local Player = Players.LocalPlayer

type OptionHandler_T = {
    Materials: {[Instance]: Enum.Material},

    PreloadMaterials: (OptionHandler_T) -> (),
    ToggleMaterials: (OptionHandler_T, boolean) -> ()
}

local OptionHandler: OptionHandler_T = {}

function OptionHandler:Start()
    self.Materials = {}

    Player:GetAttributeChangedSignal("NoMaterialsOption"):Connect(function()
        -- shouldnt need to type assert here because if the option is changing then it must be set to a bool
        self:ToggleMaterials(Player:GetAttribute("NoMaterialsOption"))
    end)
end

function OptionHandler:PreloadMaterials()
    for _, thing in pairs(workspace:GetDescendants()) do
        if thing:IsA("BasePart") then
            thing = thing :: BasePart
            self.Materials[thing] = thing.Material
        end
    end
end

function OptionHandler:ToggleMaterials(toggle: boolean)
    for part, material in pairs(self.Materials) do
        task.spawn(function()
            part.Material = if toggle then material else Enum.Material.SmoothPlastic
        end)
    end
end

return OptionHandler