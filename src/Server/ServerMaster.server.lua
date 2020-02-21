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
}

for _, path in ipairs(loadOrder) do
	local system = import(path)
	system:start()
end
