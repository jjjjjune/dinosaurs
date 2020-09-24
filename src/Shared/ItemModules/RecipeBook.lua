--[[
    Messages:reproOnClients(player, "PlaySound", "HeavyWhoosh", item.PrimaryPart.Position)
]]
local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")

local CraftingRecipes = import "Shared/Data/CraftingRecipes"

local GetCharacter = import "Shared/Utils/GetCharacter"

local Tool = {}

function Tool.clientUse(item)

end

function Tool.serverUse(player, item)
	local ServerData = import "Server/Systems/ServerData"
	local playerRecipes = ServerData:getPlayerValue(player, "unlockedRecipes")
	local type = item.Type.Value
	local allUnlockableRecipesForType = {}
	for _, recipe in pairs(CraftingRecipes[type]) do
		if not recipe.default then
			if not playerRecipes[type][recipe.product] then
				table.insert(allUnlockableRecipesForType, recipe.product)
			end
		end
	end
	if #allUnlockableRecipesForType > 0 then
		local recipeToUnlock = allUnlockableRecipesForType[math.random(1, #allUnlockableRecipesForType)]
		playerRecipes[type][recipeToUnlock] = true
		ServerData:setPlayerValue(player, "unlockedRecipes", playerRecipes)
		Messages:send("PlayParticleSystem", "Confetti", player.Character.Head.Position)

		Messages:send("PlaySound", "RecipeUnlock", item.PrimaryPart.Position)
		Messages:send("PlaySound", "NewPop1", item.PrimaryPart.Position)

		Messages:sendClient(player, "Notify", "HEALTH_COLOR", "SPRING", "YOU HAVE LEARNED TO MAKE: ".. recipeToUnlock)
		return true
	else
		Messages:sendClient(player, "Notify", "HUNGER_COLOR_DARK", "ANGRY", "YOU HAVE LEARNED ALL THIS BOOK HAS TO OFFER.")
		return false
	end
end

function Tool.clientEquip(item)
end

function Tool.serverEquip(player, item)
end

function Tool.clientUnequip(item)
end

function Tool.serverUnequip(player, item)
end

return Tool
