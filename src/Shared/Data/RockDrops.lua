local RockDrops ={}

RockDrops.Coal = {
    {name = "Coal", min = 1, max = 3, chance = 50},
	{name = "Iron", min = 0, max = 1, chance = 15},
    {name = "Stone", min = 0, max = 1, chance = 55},
}

RockDrops.Stone = {
	{name = "Stone", min = 1, max = 3, chance = 45},
	{name = "Iron", min = 0, max = 1, chance = 15},
}

RockDrops.Clay = {
    {name = "Clay", min = 1, max = 3, chance = 45},
    {name = "Stone", min = 0, max = 1, chance = 25},
}

RockDrops.Iron = {
    {name = "Iron", min = 1, max = 3, chance = 45},
    {name = "Stone", min = 0, max = 1, chance = 25},
}

return RockDrops
