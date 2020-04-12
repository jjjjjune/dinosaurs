local import = require(game.ReplicatedStorage.Shared.Import)

local loadOrder = {
	"Server/Systems/ServerData",
	"Server/Systems/Gamemode",
	"Server/Systems/CharacterWrapper",
	"Server/Systems/PlayerWrapper",
	"Server/Systems/RespawnManager",
	"Server/Systems/Chemistry",
	"Server/Systems/Carrying",
	"Server/Systems/Classes",
	"Server/Systems/Seasons",
	"Server/Systems/Plants",
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
	"Server/Systems/Ecosystem",
	
	"Shared/Systems/Particles",
	"Shared/Systems/Data",
	"Shared/Systems/Sounds",
}

for _, path in ipairs(loadOrder) do
	local system = import(path)
	system:start()
end
