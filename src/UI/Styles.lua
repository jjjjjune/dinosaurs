--[[
	Contains reuseable styles to keep the look of the UI consistent.
]]

local rgb = Color3.fromRGB

local styles = {
	textSize = 16, -- px
	padding = 16, -- px

	fonts = {
		header = Enum.Font.GothamBlack,
		button = Enum.Font.GothamBold,
		text = Enum.Font.Gotham
	},

	colors = {
		background = rgb(255, 255, 255),
		text = rgb(30, 30, 30),
		placeholderText = rgb(136, 138, 136),
		bricksColor = rgb(184, 184, 184),

		toolsColor = rgb(255,0,68),
		petsColor = rgb(255,221,96),
		stickersColor = rgb(0,255,102),
		titlesColor = rgb(94,110,255),

		rare0color = rgb(200, 200, 200),
		rare1color = rgb(0,168,67),
		rare2color = rgb(80,129,255),
		rare3color = rgb(255,156,50),
		rare4color = rgb(255,0,77),
		rare5color = rgb(137,79,255),

		rare6color = rgb(255,0,150),
		rare7color = rgb(255,0,150),
		rare8color = rgb(255,0,150),
	},

	weaponIcons = {
		["SWORD"] = Vector2.new(0,0)*100,
		["BOMB"] = Vector2.new(1,0)*100,
		["Sticky Bomb"] = Vector2.new(1,1)*100,
		["ROCKET"] = Vector2.new(2,0)*100,
		["BALL"] = Vector2.new(4,0)*100,
		["TROWEL"] = Vector2.new(3,0)*100,
	},

	addComma = function(n)
		local f,k = n
		while (true) do
			f,k = string.gsub(f,"^(-?%d+)(%d%d%d)","%1,%2")
			if (k == 0) then break end
		end
		return f
	end,

	lerp = function(a, b, t)
		return a * (1-t) + (b*t)
	end,
}

return styles
