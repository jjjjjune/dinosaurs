local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local originalTransparencies = {}
local originalColors = {}
local originalMaterials = {}

local ChestsClient = {}

function ChestsClient:start()
	Messages:hook("PlayChestEffect", function(chest)
		Messages:send("PlayParticleSystem", "Confetti", chest.PrimaryPart.Position)
		Messages:send("PlaySoundOnClient", {
			instance = game.ReplicatedStorage.Sounds.SmallChest,
			part = chest.PrimaryPart
		})
	end)
end

return ChestsClient
