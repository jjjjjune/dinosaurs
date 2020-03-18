local import = require(game.ReplicatedStorage.Shared.Import)

local loadOrder = {
	"Server/Systems/PlayerWrapper",
	"Server/Systems/CharacterWrapper",
	"Server/Systems/RespawnManager",
	"Server/Systems/Chemistry",
	"Server/Systems/Carrying",
	"Server/Systems/Classes",
	"Server/Systems/Seasons",
	"Server/Systems/Plants",
	"Server/Systems/Animations",
	"Server/Systems/Items",
	"Server/Systems/Particles",
	"Server/Systems/Weather",
	"Server/Systems/Stats",
	"Server/Systems/Water",
	"Server/Systems/Entities",
	"Server/Systems/ToolStorage",
	"Server/Systems/Sacrifices",

	"Shared/Systems/Data",
	"Shared/Systems/Sounds",
}

for _, path in ipairs(loadOrder) do
	local system = import(path)
	system:start()
end
