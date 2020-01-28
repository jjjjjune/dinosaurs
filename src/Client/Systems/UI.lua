local import = require(game.ReplicatedStorage.Shared.Import)

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local Roact = import "Roact"
local App = import "UI/Root/App"

local client = Players.LocalPlayer

local UI = {}

function UI:start()
	Roact.mount(
		Roact.createElement(App),
		client:WaitForChild("PlayerGui"),
		"GameUI"
	)
end

return UI
