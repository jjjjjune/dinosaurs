local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local loadOrder = {
	"Server/Systems/CmdrServer",

	"Shared/Systems/Particles",
	"Shared/Systems/Data",
	"Shared/Systems/Sounds",

	"Server/Systems/Loader",
	"Server/Systems/EntityWaitManager",
	"Server/Systems/CharacterWrapper",
	"Server/Systems/PlayerWrapper",
	"Server/Systems/TopbarPlus",
	"Server/Systems/ServerData",
	"Server/Systems/Gamemode",
	"Server/Systems/RespawnManager",
	"Server/Systems/Chemistry",
	"Server/Systems/Carrying",
	"Server/Systems/Classes",
	"Server/Systems/Plants",
	"Server/Systems/Seasons",
	"Server/Systems/Animations",
	"Server/Systems/SaveableObjectManager",
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
	"Server/Systems/Buildings",
	"Server/Systems/Biomes",
	"Server/Systems/MapGeneration",
	"Server/Systems/Storage",
	--"Server/Systems/Ecosystem"
	"Server/Systems/Invisibility",
	"Server/Systems/SpawnEffect",
	"Server/Systems/HeatAreas",
	"Server/Systems/Disasters",
	"Server/Systems/Fire",
	"Server/Systems/CollisionReports",
	"Server/Systems/Monsters",
	"Server/Systems/Knockback",
	"Server/Systems/Combat",
	"Server/Systems/ConstraintManager",
	"Server/Systems/Permissions",
	"Server/Systems/Gates",
	"Server/Systems/Chests",
}

for _, path in ipairs(loadOrder) do
	local system = import(path)
	system:start()
end

Messages.fireQueue()
