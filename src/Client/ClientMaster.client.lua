local import = require(game.ReplicatedStorage.Shared.Import)
local player = game.Players.LocalPlayer
local FastSpawn = import "Shared/Utils/FastSpawn"

local loadOrder = {
	"Client/Systems/ClientInit",
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

	"Client/Systems/LavaBubbles",
	--"Client/Systems/Data"

	"Shared/Systems/Particles",
}

local ui = {
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
	FastSpawn(function() 
		system:start(player.PlayerGui)
	end)
end