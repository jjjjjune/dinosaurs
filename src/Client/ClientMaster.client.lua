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

	"Client/Systems/ClientCollisions",

	"Client/Systems/BiomeSounds",
	"Client/Systems/ClientEffects",
	"Client/Systems/LavaBubbles",
	--"Client/Systems/Data"

	"Shared/Systems/Particles",
}

local ui = {
	--"Client/Ui/TopbarPlus",
	"Client/Ui/Button",
	"Client/Ui/Tooltips",
	--"Client/Ui/SeasonBar",
	"Client/Ui/RadialProgress",
	"Client/Ui/StatsUi",
	"Client/Ui/ContextualBinds",
	"Client/Ui/Tools",
	"Client/Ui/SacrificeUi",
	"Client/Ui/Crafting",
	"Client/Ui/Notifications",
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

Messages.fireQueue()

local init = import "Client/Systems/ClientInit"
init:start()