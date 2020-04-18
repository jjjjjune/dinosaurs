local import = require(game.ReplicatedStorage.Shared.Import)

local loadOrder = {
	"Server/Systems/CharacterWrapper",
	"Server/Systems/PlayerWrapper",
	"Server/Systems/ServerData",
	"Server/Systems/Gamemode",
	"Server/Systems/RespawnManager",
	"Server/Systems/Chemistry",
	"Server/Systems/Carrying",
	"Server/Systems/Classes",
	"Server/Systems/Plants",
	"Server/Systems/Seasons",
	"Server/Systems/Animations",
	"Server/Systems/Items",
	"Server/Systems/Weather",
	"Server/Systems/Stats",
	"Server/Systems/Water",
	"Server/Systems/Entities",
	"Server/Systems/ToolStorage",
	"Server/Systems/Sacrifices",
	"Server/Systems/Rocks",
	"Server/Systems/Masks",
	"Server/Systems/Crafting",
	"Server/Systems/Ocean",
	"Server/Systems/Buildings",
	"Server/Systems/MapGeneration",
	"Server/Systems/Storage",
	--"Server/Systems/Ecosystem",
	"Server/Systems/Biomes",
	"Server/Systems/Invisibility",
	"Server/Systems/SpawnEffect",
	"Server/Systems/HeatAreas",
	
	"Shared/Systems/Particles",
	"Shared/Systems/Data",
	"Shared/Systems/Sounds",
}

for _, path in ipairs(loadOrder) do
	local system = import(path)
	system:start()
end
