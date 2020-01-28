local import = require(game.ReplicatedStorage.Shared.Import)

local loadOrder = {

}
--:epictroll: :epictroll: :epictroll: :epictroll: :epictroll:
for _, path in ipairs(loadOrder) do
	local system = import(path)
	system:start()
end
