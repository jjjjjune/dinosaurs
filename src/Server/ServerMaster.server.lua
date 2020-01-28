local import = require(game.ReplicatedStorage.Shared.Import)

local loadOrder = {
	"Server/Systems/Chemistry",
	--"Server/Systems/OwnershipBull"
}

for _, path in ipairs(loadOrder) do
	local system = import(path)
	system:start()
end
