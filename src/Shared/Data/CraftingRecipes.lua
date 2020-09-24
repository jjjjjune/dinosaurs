local Recipes = {}

Recipes.Workbench = {
    {
        product = "Bucket",
        ingredient = "Log",
        default = true,
    },
    {
        product = "Pickaxe",
        ingredient = "Log",
        default = true,
	},
	{
        product = "Axe",
        ingredient = "Iron Bar",
        default = false,
    },
    {
        product = "Iron Pickaxe",
        ingredient = "Iron Bar",
        default = false,
    },
    {
        product = "Torch",
        ingredient = "Coal",
        default = true,
	},
	{
        product = "Taming Potion",
        ingredient = "Bone",
        default = false,
    },
    {
        product = "Workbench",
        ingredient = "Log",
        default = true,
        building = true,
	},
	{
        product = "Pallet",
        ingredient = "Log",
        default = true,
        building = true,
    },
    {
        product = "Small Bin",
        ingredient = "Log",
        default = true,
        building = true,
    },
    {
        product = "Campfire",
        ingredient = "Log",
        default = true,
        building = true,
    },
    {
        product = "Cistern",
        ingredient = "Clay Brick",
        default = false,
		building = true,
	},
	{
        product = "Wood Wall",
        ingredient = "Log",
        default = true,
        building = true,
	},
	{
        product = "Stone Wall",
        ingredient = "Stone",
        default = true,
        building = true,
	},
}

return Recipes
