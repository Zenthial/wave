local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local Hats = Assets:WaitForChild("Hats")

return {
    ["Riflemen"] = {
        Default = true,
        ClassDetail = "Light Combatant",
        ["Primaries"] = {"W17", "W18", "X11"},
        ["Secondaries"] = {"Y14", "Y14[S]", "SKP"},
        ["Gadgets"] = {"NDG", "C0S"},
        ["Skills"] = {"ENHC-S"},
        Hat = Hats.Riflemen,
    },
    ["Warmonger"] = {
        Default = false,
        PlayerLimit = 3,
        ClassDetail = "Heavy Combatant",
        ["Primaries"] = {"W18", "X11", "E31"},
        ["Secondaries"] = {"Y14", "H23", "2xH23"},
        ["Gadgets"] = {"NDG", "STK"},
        ["Skills"] = {"ENHC-S", "FIEL-X"},
        Hat = Hats.Warmonger,
    },
    ["Phantom"] = {
        Default = false,
        PlayerLimit = 1,
        ClassDetail = "Stealth Combatant",
        ["Primaries"] = {"B67", "S13", "SUF"},
        ["Secondaries"] = {"Y14[S]", "SKP-B", "SKP", "2xSKP"},
        ["Gadgets"] = {"D4K"},
        ["Skills"] = {"INVI-C"}, 
        Hat = Hats.Phantom
    },
    ["Devil"] = {
        Default = false,
        PlayerLimit = 1,
        ClassDetail = "Health Manipulator",
        ["Primaries"] = {""},
        ["Secondaries"] = {""},
        ["Gadgets"] = {""},
        ["Skills"] = {"SIPH-N"},
        Hat = Hats.Devil
    }
}