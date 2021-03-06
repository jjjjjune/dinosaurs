local import = require(game.ReplicatedStorage.Shared.Import)
local player = game.Players.LocalPlayer
local FastSpawn = import "Shared/Utils/FastSpawn"

local Messages = import "Shared/Utils/Messages"

local loadOrder = {

	"Client/Systems/Lighting",
	"Client/Systems/Footsteps",
	"Client/Systems/ClientSound",
	"Client/Systems/ClientStats",
	"Client/Systems/Binds",
	"Client/Systems/ClientAnimations",
	"Client/Systems/Items",
	"Client/Systems/Entities",
	"Client/Systems/ToolStorage",
	"Client/Systems/Building",
	"Client/Systems/DamageEffects",
	"Client/Systems/Knockback",
	"Client/Systems/Combat",
	"Client/Systems/Riding",
	"Client/Systems/BuildMode",
	"Client/Systems/ChestsClient",

	"Client/Systems/ClientCollisions",

	"Client/Systems/BiomeEffects",
	"Client/Systems/ClientEffects",
	"Client/Systems/LavaBubbles",
	"Client/Systems/ScrollingTextures",
	--"Client/Systems/Data"

	"Shared/Systems/Particles",

	"Client/Systems/CmdrClient",
}

local ui = {
	--"Client/Ui/TopbarPlus",
	"Client/Ui/Button",
	"Client/Ui/MultipleOption",
	"Client/Ui/Checkbox",
	"Client/Ui/Label",
	"Client/Ui/Tooltips",
	--"Client/Ui/SeasonBar",
	"Client/Ui/RadialProgress",
	"Client/Ui/StatsUi",
	"Client/Ui/ContextualBinds",
	"Client/Ui/Tools",
	"Client/Ui/SacrificeUi",
	"Client/Ui/Crafting",
	"Client/Ui/Notifications",
	"Client/Ui/ItemPlacementHelper",
	"Client/Ui/Permissions",
	"Client/Ui/DamageIndicators",
}

for _, path in ipairs(loadOrder) do
	local system = import(path)
	local lastStart = time()
	system:start()
	if time() - lastStart > .1 then
		warn(path, " IS YIELDING????")
	end
end

repeat wait() until player:FindFirstChild("PlayerGui")

for _, path in ipairs(ui) do
	local system = import(path)
	system:start(player.PlayerGui)
end

import("Client/Systems/XboxSelectionClient"):start()

Messages.fireQueue()

local init = import "Client/Systems/ClientInit"
init:start()
