-- Teleport.lua, inside your commands folder as defined above.
return {
	Name = "spawnmonster";
	Aliases = {"si"};
	Description = "Spawns a monster.";
	Group = "Admin";
	Args = {
		{
			Type = "string";
			Name = "monster name";
			Description = "The name of the monster";
		},
		{
			Type = "player";
			Name = "player";
			Description = "player to spawn it at"
		},
	};
}
