local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local SaveableObjectManager = import "Server/Systems/SaveableObjectManager"

local Loader = {}

function Loader:start()
	Messages:hook("FirstMapRenderComplete", function()
		SaveableObjectManager.loadTag("SaveableMapEntity")
		SaveableObjectManager.loadTag("Building")
		SaveableObjectManager.loadTag("Item")
	end)
end

return Loader
