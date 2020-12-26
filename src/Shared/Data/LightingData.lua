--117, 218, 210
--Color3.fromRGB(192,155,117)

return {
	Desert = {
		Day = {
			[game.Lighting] = {
				Brightness = 1,
				Ambient = Color3.fromRGB(23, 97, 234),
				ColorShift_Bottom = Color3.fromRGB(0,0,0),
				ColorShift_Top = Color3.fromRGB(150, 87, 87),
				OutdoorAmbient = Color3.fromRGB(128,128,128),
				ClockTime = 13,
			},
			[game.Lighting.Atmosphere] = {
				Density = 0.3,
				Offset = 0,
				Color = Color3.fromRGB(44, 234, 255),
				Decay = Color3.fromRGB(255, 46, 46),
				Glare = 1,
				Haze = 2.48,
			},
			[workspace.Effects.Water] = {
				Color = Color3.fromRGB(123, 236, 214),
			}
		},
		Night = {
			[game.Lighting.Atmosphere] = {
				Density = 0.35,
				Offset = 0,
				Color = Color3.fromRGB(43, 0, 113),
				Decay = Color3.fromRGB(0,0,0),
				Glare = 1.79,
				Haze = 2.08,
			},
			[game.Lighting] = {
				Brightness = 3.86,
				Ambient = Color3.fromRGB(0,34,255),
				ColorShift_Bottom = Color3.fromRGB(0,0,0),
				ColorShift_Top = Color3.fromRGB(128,0,255),
				OutdoorAmbient = Color3.fromRGB(63,0,141),
				ClockTime = 0,
			},
			[workspace.Effects.Water] = {
				Color = Color3.fromRGB(61, 21, 133),
			},
		},
	},
	Rainforest = {
		Day = {
			[game.Lighting] = {
				Brightness = .25,
				Ambient = Color3.fromRGB(23, 97, 234),
				ColorShift_Bottom = Color3.fromRGB(0,0,0),
				ColorShift_Top = Color3.fromRGB(150, 87, 87),
				OutdoorAmbient = Color3.fromRGB(128,128,128),
				ClockTime = 13,
			},
			[game.Lighting.Atmosphere] = {
				Density = 0.25,
				Offset = 0,
				Color = Color3.fromRGB(131, 203, 157),
				Decay = Color3.fromRGB(0, 76, 31),
				Glare = 0.47,
				Haze = 10,
			},
			[workspace.Effects.Water] = {
				Color = Color3.fromRGB(40, 127, 71),
			},
		},
		Night = {
			[game.Lighting.Atmosphere] = {
				Density = 0.45,
				Offset = 0,
				Color = Color3.fromRGB(40, 0, 113),
				Decay = Color3.fromRGB(0,0,0),
				Glare = 1.79,
				Haze = 2.08,
			},
			[game.Lighting] = {
				Brightness = 3.86,
				Ambient = Color3.fromRGB(0,34,255),
				ColorShift_Bottom = Color3.fromRGB(0,0,0),
				ColorShift_Top = Color3.fromRGB(128,0,255),
				OutdoorAmbient = Color3.fromRGB(63,0,141),
				ClockTime = 0,
			},
			[workspace.Effects.Water] = {
				Color = Color3.fromRGB(61, 21, 133),
			}
		},
	},
    --[[Rain = {
        [game.Lighting] = {
            Ambient = Color3.fromRGB(142, 114, 255),
            Brightness = .2,
            ColorShift_Bottom = Color3.fromRGB(0,0,0),
            ColorShift_Top = Color3.fromRGB(0,0,0),
            OutdoorAmbient = Color3.fromRGB(128,128,128),
            FogColor = Color3.fromRGB(52,58,63),
            FogEnd = 1800,
        },
        [workspace.Effects.Sky] = {
            Color = Color3.fromRGB(27,42,53),
        },
        [workspace.Effects.Water] = {
            Color = Color3.fromRGB(79,81,91),
        }
    },--]]
}
