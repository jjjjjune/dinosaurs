--117, 218, 210
--Color3.fromRGB(192,155,117)

return {
    Winter = {
        [game.Lighting] = {
            Ambient = Color3.fromRGB(27,112,216),
            Brightness = 1.2,
            ColorShift_Bottom = Color3.fromRGB(255,0,132),
            ColorShift_Top = Color3.fromRGB(0,124,135),
            OutdoorAmbient = Color3.fromRGB(128,128,128),
            FogColor = Color3.fromRGB(161,175,255),
            FogEnd = 2000,
        },
        [workspace.Effects.Sky] = {
            Color = Color3.fromRGB(255, 201, 201),
        },
        [workspace.Effects.Water] = {
            Color = Color3.fromRGB(110, 153, 202),
        }
    },
    Spring = {
        [game.Lighting] = {
            Ambient = Color3.fromRGB(45,111,234),
            Brightness = 1,
            ColorShift_Bottom = Color3.fromRGB(0,0,0),
            ColorShift_Top = Color3.fromRGB(0, 0, 0),
            OutdoorAmbient = Color3.fromRGB(128,128,128),
            FogColor = Color3.fromRGB(192, 155, 117),
            FogEnd = 3000,
        },
        [workspace.Effects.Sky] = {
            Color = Color3.fromRGB(76,255,127),
        },
        [workspace.Effects.Water] = {
            Color = Color3.fromRGB(61, 146, 185),
        }
    },
    Summer = {
        [game.Lighting] = {
            Ambient = Color3.fromRGB(23,97,234),
            Brightness = 1,
            ColorShift_Bottom = Color3.fromRGB(0,0,0),
            ColorShift_Top = Color3.fromRGB(150,87,87),
            OutdoorAmbient = Color3.fromRGB(128,128,128),
            FogColor = Color3.fromRGB(192, 155, 117),
            FogEnd = 3500,
        },
        [workspace.Effects.Sky] = {
            Color = Color3.fromRGB(255, 89, 89),
        },
        [workspace.Effects.Water] = {
            Color = Color3.fromRGB(9, 137, 207),
        }
    },
    Fall = {
        [game.Lighting] = {
            Ambient = Color3.fromRGB(23,97,234),
            Brightness = 1,
            ColorShift_Bottom = Color3.fromRGB(0,0,0),
            ColorShift_Top = Color3.fromRGB(150,87,87),
            OutdoorAmbient = Color3.fromRGB(128,128,128),
            FogColor = Color3.fromRGB(192, 129, 104),
            FogEnd = 3500,
        },
        [workspace.Effects.Sky] = {
            Color = Color3.fromRGB(255, 89, 89),
        },
        [workspace.Effects.Water] = {
            Color = Color3.fromRGB(38, 132, 213),
        }
    },
}