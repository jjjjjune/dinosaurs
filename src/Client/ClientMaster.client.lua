local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local loadOrder = {
	"Client/Systems/ClientInit",
	"Client/Systems/Carrying",
	"Client/Systems/Lighting",
	"Client/Systems/Footsteps",
	"Client/Systems/ClientSound",

	"Client/Ui/SeasonBar",
	"Client/Ui/RadialProgress",
	--"UI/UiMain",
}

for _, path in ipairs(loadOrder) do
	local system = import(path)
	local lastStart = time()
	system:start()
	--print("LOADED "..path)
	if time() - lastStart > .1 then
		warn(path, " IS YIELDING????")
	end
end
