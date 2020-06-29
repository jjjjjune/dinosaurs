
local rocks = {
	[0] = {
		{name = "Coal", chance = 50},

		{name = "Iron",  chance = 55},
	},
	[1] = {
		{name = "Coal", chance = 50},

		{name = "Iron",  chance = 55},
	},
	[2] = {
		{name = "Coal", chance = 50},

		{name = "Iron",  chance = 55},
	},
	[3] = {
		{name = "Coal", chance = 50},

		{name = "Stone",  chance = 50},

		{name = "Iron",  chance = 50},
	},
	[4] = {
		{name = "Coal", chance = 80},

		{name = "Stone",  chance = 55},
	},
	[5] = {
		{name = "Coal", chance = 10},

		{name = "Clay", chance = 50},

		{name = "Stone",  chance = 75},
	},
	[6] = {
		{name = "Clay", chance = 75},

		{name = "Stone",  chance = 75},
	},
}

local function random(min, max)
    local randomObj = Random.new()
    return randomObj:NextInteger(min, max)
end

return function(yLevel)
	local choices = rocks[yLevel]
	local tab = {}
	for _, choice in pairs(choices) do
		for i = 1, choice.chance do
			table.insert(tab, choice.name)
		end
	end
	return tab[random(1, #tab)]
end
