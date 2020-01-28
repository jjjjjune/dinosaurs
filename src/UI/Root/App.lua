local import = require(game.ReplicatedStorage.Shared.Import)

local Notifications = import "UI/Components/Notifications/Notifications"

local function App()
	return Roact.createElement(RoactRodux.StoreProvider, { store = Store }, {
		Roact.createElement("ScreenGui", {ResetOnSpawn = false}, {
			Notifications = Roact.createElement(Notifications, {}),
		})
	})
end

return App
