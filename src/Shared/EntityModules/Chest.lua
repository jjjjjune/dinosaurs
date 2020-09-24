local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local Chest = {}

function Chest.clientUse(entityInstance)

end

function Chest.serverUse(player, entityInstance)
	local chest = entityInstance
	local lastUse = chest.LastUse.Value
	local useInterval = chest.UseInterval.Value
	local endTime = lastUse + useInterval
	local currentTime = os.time()
	local timeLeft = math.max(0, endTime - currentTime)
	if timeLeft <= 0 then
		entityInstance.LastUse.Value = currentTime
		Messages:send("ClaimChest", player, entityInstance)
	end
end

return Chest
