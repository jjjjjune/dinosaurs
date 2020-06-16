local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

return function (_, itemID, position)
	if typeof(position) == "Instance" then
		position = position.Character.Head.Position
	end
	Messages:send("CreateItem", itemID, position + Vector3.new(0,3,0))
	return "spawned: "..itemID
end
