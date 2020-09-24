
local rocks = { -- REMEMBER: these start high and work their way DOWN
	[0] = {
		{name = "Mineral", chance = 100},
	},
	[1] = {
		{name = "Organic", chance = 100},
	},
	[2] = {
		{name = "Organic", chance = 100},
	},
	[3] = {
		{name = "Organic", chance = 100},
	},
	[4] = {
		{name = "Organic", chance = 100},
	},
	[5] = {
		{name = "Organic", chance = 100},
	},
	[6] = {
		{name = "Organic", chance = 100},
	},
	[7] = {
		{name = "Mineral", chance = 50},
		{name = "Organic", chance = 50},
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
