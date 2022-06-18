return {
    Maps = {
        "Applejack",
        -- "Homestead",
        "Cityscape",
        "Academy",
        "Spearhead"
    },
    MapImages = {
        ["Applejack"] = "rbxassetid://9865823822",
        ["Homestead"] = "",
        ["Cityscape"] = "",
        ["Academy"] = "rbxassetid://9865840740",
        ["Spearhead"] = "rbxassetid://9865854974",
    },

    Modes = {
        "Hardpoint",
        "Domination",
        "Datacore",
        -- "GunGame"
    },
    ModeImages = {
        ["Hardpoint"] = "rbxassetid://7249911905",
        ["Domination"] = "rbxassetid://7249913269",
        ["Datacore"] = "",
        ["GunGame"] = "rbxassetid://7249914794",
    },
    ModeInfo = {
        ["Hardpoint"] = {
            Points = {"A"},
            MaxScore = 450
        },

        ["Domination"] = {
            Points = {"A", "B", "C"},
            MaxScore = 900
        },

        ["Datacore"] = {
            Points = {"D"},
            MaxScore = 450
        },

        ["GunGame"] = {
            Points = {},
            MaxScore = 20
        }
    }
}