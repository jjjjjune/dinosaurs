local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local originalTransparencies = {}
local originalColors = {}
local originalMaterials = {}

local chestSounds = {
	["Common Chest"] = "SmallChest",
	["Uncommon Chest"] = "SmallChest",
	["Rare Chest"] = "MediumChest",
	["Legendary Chest"] = "LargeChest",
	["Mythic Chest"] = "LargeChest",
}

local ChestsClient = {}

function ChestsClient:start()
	Messages:hook("PlayChestEffect", function(chest)
		Messages:send("PlayParticleSystem", "Confetti", chest.PrimaryPart.Position)

		Messages:send("PlaySoundOnClient", {
			instance = game.ReplicatedStorage.Sounds[chestSounds[chest.Name]],
			part = chest.PrimaryPart
		})
	end)
end

return ChestsClient
