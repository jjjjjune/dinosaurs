local PlantDrops ={}

PlantDrops.Pine = {
    {name = "Apple", min = 1, max = 2, chance = 50},
    {name = "Log",min = 1, max = 2, chance = 75},
    {name = "Pine Seed", min = 1, max = 2, chance = 55},
}

PlantDrops["Blue Mushroom"] = {
    {name = "Blue Mushroom", min = 1, max = 3, chance = 50},
}


PlantDrops["Wood Tree"] = {
    {name = "Log",min = 2, max = 4, chance = 75},
    {name = "Acorn", min = 1, max = 2, chance = 55},
}

PlantDrops["Banana Tree"] = {
    {name = "Log",min = 1, max = 2, chance = 45},
    {name = "Banana", min = 1, max = 2, chance = 50},
    {name = "Banana Seed", min = 0, max = 1, chance = 55},
}

return PlantDrops