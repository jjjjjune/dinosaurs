local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

return function (_, monsterID, position)
	if typeof(position) == "Instance" then
		position = position.Character.Head.Position
	end
	Messages:send("SpawnMonster", monsterID, position + Vector3.new(0,3,0))
	return "spawned: "..monsterID
end
