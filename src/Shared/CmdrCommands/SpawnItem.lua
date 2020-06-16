-- Teleport.lua, inside your commands folder as defined above.
return {
	Name = "spawnitem";
	Aliases = {"si"};
	Description = "Spawns an item.";
	Group = "Admin";
	Args = {
		{
			Type = "string";
			Name = "Item name";
			Description = "The name of the item";
		},
		{
			Type = "player";
			Name = "player";
			Description = "player to spawn the item at"
		},
	};
}